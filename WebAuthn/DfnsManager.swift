//
//  DfnsManager.swift
//  Shiny
//
//  Created by leven on 2023/7/31.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON
import SwiftyRSA
import CryptoKit
import CommonCrypto
import AuthenticationServices
//import WebAuthnKit
//import ASN1Decoder
class DfnsManager {
    
    let request: Request

    static let shared = DfnsManager()
    
    init() {
        self.request = Request()
//        let userConsentUI = UserConsentUI(viewController: UIApplication.shared.keyWindow!.rootViewController!)
//        let authenticator = InternalAuthenticator(ui: userConsentUI)
//        WAKLogger.available = true
//        self.webAuthnClient = WebAuthnClient(
//            origin:        "localhost:8000.com",
//            authenticator: authenticator
//        )
    }
    
    
    func register(username: String, password: String) -> Promise<JSON> {
        return request.request(path: "register/init", method: .post, params: ["username" : username, "password": password]).then { json in
//            var options = PublicKeyCredentialCreationOptions()
//            options.rp = PublicKeyCredentialRpEntity(id: json["rp"]["id"].stringValue, name: json["rp"]["name"].stringValue)
//            options.user = PublicKeyCredentialUserEntity(id: Bytes.fromString(json["user"]["id"].stringValue), displayName: json["user"]["displayName"].stringValue, name: json["user"]["name"].stringValue)
//            options.challenge = Bytes.fromString(json["challenge"].stringValue)
//            options.pubKeyCredParams = json["pubKeyCredParams"].arrayValue.compactMap({ _ in
//                return PublicKeyCredentialParameters(alg: .es256)
//            })
//            options.authenticatorSelection = AuthenticatorSelectionCriteria(requireResidentKey: json["authenticatorSelection"]["requireResidentKey"].boolValue, userVerification: UserVerificationRequirement.init(rawValue: json["authenticatorSelection"]["userVerification"].stringValue)!)
//            options.attestation = AttestationConveyancePreference.init(rawValue: json["attestation"].stringValue) ?? AttestationConveyancePreference.direct
            return Promise.value(json)
        }
    }
}

extension DfnsManager {
    class Request {
        private var headers: [String: Any] = [:]
        
        private var host: String = ""
        private let USERACTION_HEADER_KEY: String = "X-DFNS-USERACTION"

        private var applicationOrigin: String = ""
        private var authToken: String = ""
        private var appId: String = ""
        private var credentialPrivateKey: String = ""

        init() {
            if let url = Bundle.main.url(forResource: "dfns", withExtension: "json"), let data = try? Data(contentsOf: url), let json = try? JSON(data: data), let values = json["values"].array {
                if let authToken = values.first(where: {$0["key"].stringValue == "authToken"})?["value"].string {
                    self.authToken = authToken
                    headers["Authorization"] = "Bearer " + authToken
                }
                
                if let applicationId = values.first(where: {$0["key"].stringValue == "applicationId"})?["value"].string {
                    self.appId = applicationId
                    headers["X-DFNS-APPID"] = applicationId
                }
                
                if let host = values.first(where: {$0["key"].stringValue == "dfnsApiDomain"})?["value"].string {
                    self.host = host
                }
                
                if let applicationOrigin = values.first(where: {$0["key"].stringValue == "applicationOrigin"})?["value"].string {
                    self.applicationOrigin = applicationOrigin
                }
                
                
                if let credentialPrivateKey = values.first(where: {$0["key"].stringValue == "credentialPrivateKey"})?["value"].string {
                    self.credentialPrivateKey = credentialPrivateKey.replacingOccurrences(of: "\\n", with: "\n")
                }
            }
        }
        
        func generateNonce() -> String? {
            let uuid = UUID().uuidString
            let dateString = Date().ISO8601Format()
            if let data = try? JSONSerialization.data(withJSONObject: [
                "uuid" : uuid,
                "date" : dateString
            ]) {
                return data.base64EncodedString()
            }
            return nil
        }

        
        func resendEmail(email: String) -> Promise<JSON> {
            return request(path: "auth/manage/users/send-registration-email", method: .put ,params: ["username": email, "orgId": "or-1jrr0-ao48r-8dg8b63gst7upr9v"])
        }
        
        func createUser(email: String) -> Promise<JSON> {
            return request(path: "auth/users", method: .post ,params: ["email": email, "kind": "EndUser"], headers: [USERACTION_HEADER_KEY : ""])
        }
        
        func registerUser(json: JSON, code: String, email: String) -> Promise<JSON> {
//            if let name = json["username"].string, let orgId = json["orgId"].string {
                let p = ["username": email, "registrationCode": code, "orgId" : "or-1jrr0-ao48r-8dg8b63gst7upr9v"]
                return request(path: "auth/registration/init", method: .post ,params: p)
//            } else {
//                return Promise<JSON>.init(error: WebAuthnError.message("invalid params"))
//            }
        }
        
        func completeRegister(params: [String: Any], headers: [String: String]) -> Promise<JSON> {
            return request(path: "register/complete", method: .post ,params: ["signedChallenge": params, "temporaryAuthenticationToken" : headers["Authorization"]!], headers: [:])

//            return request(path: "auth/registration", method: .post ,params: params, headers: headers)
        }
        
        
        
        
        func request(path: String, method: HTTPMethod = .get, params: [String: Any] = [:], headers: [String: String] = [:]) -> Promise<JSON> {
            return signAction(headers[USERACTION_HEADER_KEY] == "", path: path, method: method, params: params).then { userAction in
//                let url = URL(string: "https://" + self.host + "/" + path)!
                let url = URL(string: "http://" + "dfns-api.j-labs.xyz:8000" + "/" + path)!
//                let url = URL(string: "http://" + "localhost:8000" + "/" + path)!

//            https://dfns-api.j-labs.xyz:8000/
                var defaultHeader = self.getRequestHeaders()
                defaultHeader.merge(headers, uniquingKeysWith: { $1 })
                if userAction.count > 0 {
                    defaultHeader[self.USERACTION_HEADER_KEY] = userAction
                }
                let httpHeaders = HTTPHeaders(defaultHeader)
                return AF.request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: httpHeaders).promiseResponse()
            }
        }
        
        func signAction(_ enable: Bool,path: String, method: HTTPMethod, params: [String: Any] = [:]) -> Promise<String> {
            if enable == false {
                return Promise.value("")
            }
            var challenge: JSON = JSON()
            var clientDataString: String = ""
            
            let content: [String: Any] = [
                "userActionPayload": JSON(params).rawString() ?? "",
                "userActionHttpPath": "/" + path,
                "userActionHttpMethod": method.rawValue,
                "userActionServerKind": "Api"
            ]

            return request(path: "auth/action/init", method: .post, params: content).then { [weak self] json -> Promise<String> in
                guard let self = self else {
                    return Promise<String>.init(error: WebAuthnError.message("self deinit"))
                }
                if let errorMessage = json["error"]["message"].string {
                    return Promise<String>.init(error: WebAuthnError.message(errorMessage))

                }
               challenge = json
                let clientData = [
                    "type": "key.get",
                    "challenge": challenge["challenge"].stringValue,
                    "origin": self.applicationOrigin
                ]
               
                if let data = try? JSONSerialization.data(withJSONObject: clientData), let jsonString = String(data: data, encoding: String.Encoding.utf8) {
                    clientDataString = jsonString
                    return trySignPayload(dataString: jsonString)
                } else {
                    return Promise<String>.init(error: WebAuthnError.message("invalid challenge string"))
                }
           }.then { signature -> Promise<JSON> in
               
               let signedChallenge: [String: Any] = [
                "kind": "Key",
                "credentialAssertion": [
                    "credId": challenge["allowCredentials"]["key"].arrayValue.first?["id"].stringValue,
                    "clientData": clientDataString.decodeBase64Url()?.toBase64Url() ?? "",
                    "signature": signature
                    ]
               ]
               let parms: [String: Any] = [
                "challengeIdentifier": challenge["challengeIdentifier"].stringValue,
                "firstFactor": signedChallenge
               ]
               return self.request(path: "auth/action", method: .post, params: parms)

               
//               if let data = try? JSONSerialization.data(withJSONObject: parms), let jsonString = String(data: data, encoding: String.Encoding.utf8) {
//               } else {
//                   return Promise<JSON>.init(error: WebAuthnError.message("invalid signedChallenge"))
//               }
               
           }.then { json -> Promise<String> in
               return Promise.value(json["userAction"].stringValue)
           }
        }
        
        func trySignPayload(dataString: String) -> Promise<String> {
            return Promise { resolver in
                if let key = self.getBaseEncodePrivateKey() {
                    let signature = try self.signWithPrivateKey(dataString, key)
                    resolver.fulfill(signature ?? "")
                } else {
                    resolver.reject(WebAuthnError.message("invalid private key"))
                }
               
            }
        }
        
        private func signWithPrivateKey(_ text: String, _ key: SecKey) throws -> String? {
            var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            let data = text.data(using: .utf8)!

            let _ = digest.withUnsafeMutableBytes { digestBytes in
                data.withUnsafeBytes { dataBytes in
                    CC_SHA256(dataBytes, CC_LONG(data.count), digestBytes)
                }
            }

            var signature = Data(count: SecKeyGetBlockSize(key) * 4)
            var signatureLength = signature.count

            let result = signature.withUnsafeMutableBytes { signatureBytes in
                digest.withUnsafeBytes { digestBytes in
                    SecKeyRawSign(key,
                                  SecPadding.PKCS1SHA256,
                                  digestBytes,
                                  digest.count,
                                  signatureBytes,
                                  &signatureLength)
                }
            }

            let count = signature.count - signatureLength
            signature.removeLast(count)

            guard result == noErr else {
                throw WebAuthnError.message("Could not sign data: \(result)")
            }

            return signature.base64EncodedString()
        }
        
        func getApi(path: String) -> URL {
            return URL(string: "https://" + self.host + "/" + path)!
        }
        
        func getRequestHeaders() -> [String: String] {
            return [
                "Content-Type" : "application/json",
                "X-DFNS-APPID" : self.appId,
                "X-DFNS-NONCE" : self.generateNonce() ?? "",
                "Authorization": "Bearer " + self.authToken
            ]
        }

        
        /// https://stackoverflow.com/questions/75072057/pem-encoded-elliptic-curve-public-key-conversion-ios
        func createSecKeyWithPEMSecp256r1Private(_ pem: String) throws -> SecKey? {
            let privateKeyCK = try P256.Signing.PrivateKey(pemRepresentation: pem)
            let x963Data = privateKeyCK.x963Representation
            var errorQ: Unmanaged<CFError>? = nil
            let privateKeySF = try? SecKeyCreateWithData(x963Data as NSData, [
                kSecAttrKeyType: kSecAttrKeyTypeEC,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            ] as NSDictionary, &errorQ)
            return privateKeySF
        }

        
        func getBaseEncodePrivateKey() -> SecKey? {
            let key = try? self.createSecKeyWithPEMSecp256r1Private(self.credentialPrivateKey)
            return key
        }
    }
    
    
}

extension DfnsManager {

    class WebAuhn {
        
        let rpId: String
        init(rpId: String) {
            self.rpId = rpId
        }

    }
    
    
}

extension Data {
    func toBase64Url() -> String {
        return self.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }
}


extension String {
    
    func decodeBase64Url() -> Data? {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return Data(base64Encoded: self)
    }
    
    var hexData: Data? {
          var data = Data(capacity: count / 2)
          let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
          regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
              let byteString = (self as NSString).substring(with: match!.range)
              let num = UInt8(byteString, radix: 16)!
              data.append(num)
          }
          guard data.count > 0 else { return nil }
          return data
      }
    
}

extension DataRequest {
    
    func promiseResponse() -> Promise<JSON> {
        return Promise<JSON> { resover in
            let _ = self.response { res in
                switch res.result {
                case .success(let data):
                    if let data = data, let json = try? JSON(data: data) {
                        resover.fulfill(json)
                    } else {
                        print(String(data: data ?? Data(), encoding: .utf8))
                        resover.reject(WebAuthnError.message("invalid response data"))
                    }
                case .failure(let err):
                    resover.reject(err)
                }
            }
        }
    }

}

enum WebAuthnError: Error {
    case message(String)
}


