//
//  ViewController.swift
//  WebAuthn
//
//  Created by leven on 2023/7/31.
//

import UIKit

import SnapKit
import SwiftyJSON
import AuthenticationServices
class ViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {


    lazy var createUserButton = UIButton(type: .custom)
    
    lazy var registerUserButton = UIButton(type: .custom)

    lazy var resendUserButton = UIButton(type: .custom)

    lazy var webAuthnUserButton = UIButton(type: .custom)

    lazy var registerCodeInput = UITextField()
    
    lazy var statusLabel = UILabel()
    
    let email = "13487241707@163.com"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        createUserButton.setTitle("1. Create User", for: .normal)
        createUserButton.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(self.createUserButton)
        self.createUserButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(14)
            make.height.equalTo(44)
            make.top.equalTo(80)
        }
        self.createUserButton.addTarget(self, action: #selector(self.createUser), for: .touchUpInside)
        
        resendUserButton.setTitle("Resend Email To User", for: .normal)
        resendUserButton.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(self.resendUserButton)
        
        self.resendUserButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(14)
            make.height.equalTo(44)
            make.top.equalTo(self.createUserButton.snp.bottom).offset(20)
        }
        self.resendUserButton.addTarget(self, action: #selector(self.resendUser), for: .touchUpInside)
        
        registerUserButton.setTitle("2. Register User", for: .normal)
        registerUserButton.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(self.registerUserButton)
        
        self.registerUserButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(14)
            make.height.equalTo(44)
            make.top.equalTo(self.resendUserButton.snp.bottom).offset(20)
        }
        self.registerUserButton.addTarget(self, action: #selector(self.registerUser), for: .touchUpInside)
        
        
        webAuthnUserButton.setTitle("3. WebAuthn User", for: .normal)
        webAuthnUserButton.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(self.webAuthnUserButton)
        
        self.webAuthnUserButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(14)
            make.height.equalTo(44)
            make.top.equalTo(self.registerUserButton.snp.bottom).offset(20)
        }
        self.webAuthnUserButton.addTarget(self, action: #selector(self.webAuthnRegister), for: .touchUpInside)
        
        self.registerCodeInput.borderStyle = .bezel
        self.registerCodeInput.backgroundColor = UIColor.white
        self.registerCodeInput.textColor = UIColor.black
        self.registerCodeInput.attributedPlaceholder = NSAttributedString(string: "input registeration code", attributes: [.foregroundColor: UIColor.lightGray])
        self.view.addSubview(self.registerCodeInput)
        self.registerCodeInput.textAlignment = .center
        self.registerCodeInput.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.webAuthnUserButton.snp.bottom).offset(40)
            make.height.equalTo(36)
        }
        self.statusLabel.text = "-----"
        self.view.addSubview(self.statusLabel)
        self.statusLabel.numberOfLines = 0
        self.statusLabel.textColor = UIColor.lightGray
        self.statusLabel.font = UIFont.systemFont(ofSize: 14)
        self.statusLabel.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.registerCodeInput.snp.bottom).offset(20)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        self.view.addGestureRecognizer(tap)
    }
    @objc func tapView() {
        self.registerCodeInput.resignFirstResponder()
    }
    
    @IBAction func createUser() {
        self.statusLabel.text = "sending user email..."
        DfnsManager.shared.request.createUser(email: self.email).done { json in
            self.statusLabel.text = "sending user email succeed!"
        }.catch { error in
            print(error)
            self.statusLabel.text = "sending user email failed! \n" + error.localizedDescription
        }
    }
    
    @IBAction func resendUser() {
        self.statusLabel.text = "resending user email..."

        DfnsManager.shared.request.resendEmail(email: self.email).done { json in
            self.statusLabel.text = "resending user email succeed!"
        }.catch { error in
            print(error)
            self.statusLabel.text = "resending user email failed! \n" + error.localizedDescription
        }
    }
    
    var registerRes: JSON?
    @IBAction func registerUser() {
        let code = self.registerCodeInput.text ?? ""
        if code.count > 0 {
            self.statusLabel.text = "create registeration challenge..."
            DfnsManager.shared.request.registerUser(json: JSON(), code: code, email: self.email).done { json in
                self.registerRes = json
                print(json)
                self.statusLabel.text = "registeration challenge received!"
            }.catch { error in
                print(error)
                self.statusLabel.text = "registeration challenge failed! \n" + error.localizedDescription
            }
        } else {
            self.statusLabel.text = "please input registeration code"
        }
    }
    
    @IBAction func webAuthnRegister() {
        let domain = "j-labs.xyz"
        let username = self.registerRes?["user"]["name"].stringValue ?? ""

        let challenge = (self.registerRes?["challenge"].stringValue ?? "").decodeBase64Url() ?? Data()
        let userID = (self.registerRes?["user"]["id"].stringValue ?? "").decodeBase64Url() ?? Data()

        
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)

        let registrationRequest = publicKeyCredentialProvider.createCredentialRegistrationRequest(challenge: challenge,
                                                                                                  name: username, userID: userID)
//        if let attestation = self.registerRes?["attestation"].stringValue, attestation.count > 0  {
//            registrationRequest.attestationPreference = ASAuthorizationPublicKeyCredentialAttestationKind.init(rawValue: attestation)
//        }
//
        if let userVerification = self.registerRes?["authenticatorSelection"]["userVerification"].stringValue, userVerification.count > 0 {
            registrationRequest.userVerificationPreference = ASAuthorizationPublicKeyCredentialUserVerificationPreference.init(rawValue: userVerification)
        }
        self.statusLabel.text = "authorization requesting..."

        let authController = ASAuthorizationController(authorizationRequests: [ registrationRequest ] )
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
        
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentialRegistration as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            // After the webapp has verified the registration and created the user account, sign the user in with the new account.
            print(credentialRegistration)
            let token = self.registerRes?["temporaryAuthenticationToken"].stringValue ?? ""

            let rawClientDataJSON = String(data: credentialRegistration.rawClientDataJSON, encoding: .utf8) ?? ""
            let rawAttestationObject = String(data: credentialRegistration.rawAttestationObject ?? Data(), encoding: .utf8) ?? ""
            let credentialID = String(data: credentialRegistration.credentialID, encoding: .utf8) ?? ""

            let p: [String: Any] = [
                "firstFactorCredential": [
                    "credentialKind": "Fido2",
                    "credentialInfo": [
                        "credId" : credentialRegistration.credentialID.toBase64Url(),
                        "clientData": credentialRegistration.rawClientDataJSON.toBase64Url(),
                        "attestationData": credentialRegistration.rawAttestationObject?.toBase64Url() ?? ""
                    ],
                ] as [String : Any]
            ]
            DfnsManager.shared.request.completeRegister(params: p, headers: ["Authorization": "Bearer " + token]).done { json in
                print(json)
                if let errorMsg = json["error"]["message"].string {
                    self.statusLabel.text = "authorization request failed \n" + errorMsg
                }
            }.catch { error in
                print(error)
                self.statusLabel.text = "authorization request failed \n" + error.localizedDescription
            }
            

        case let credentialAssertion as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            // After the server has verified the assertion, sign the user in.
            print(credentialAssertion)

        default:
            fatalError("Received unknown authorization type.")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let authorizationError = ASAuthorizationError.Code(rawValue: (error as NSError).code) else {
            return
        }
        self.statusLabel.text = "authorization request failed \n" + error.localizedDescription

        if authorizationError == .canceled {
            // Either no credentials were found and the request silently ended, or the user canceled the request.
            // Consider asking the user to create an account.
        } else {
            // Other ASAuthorization error.
            // The userInfo dictionary should contain useful information.
        }
    }
    

}

