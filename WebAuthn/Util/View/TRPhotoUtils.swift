//
//  TRPhotoUtils.swift
//
//

import UIKit
import Foundation
import MobileCoreServices
import Photos

private var photoUtils: TRPhotoUtils?

public class TRPhotoUtils: NSObject {
    var parentVC: UIViewController?
    var clipImg: Bool = false
    var completion: ((UIImage?) -> Void)?
    
    static var isWorking: Bool {
        photoUtils != nil
    }
    
    public static func openAlbum(from parentVC: UIViewController, clipImg: Bool, completion: ((UIImage?) -> Void)?) {
        doInMain {
            p_openAlbum(from: parentVC, clipImg: clipImg, completion: completion)
        }
    }
    
    private static func p_openAlbum(from parentVC: UIViewController, clipImg: Bool, completion: ((UIImage?) -> Void)?) {
        if isWorking {
            return
        }
        guard isAlbumAvailable else {
            return
        }
        let utils = TRPhotoUtils()
        photoUtils = utils
        utils.parentVC = parentVC
        utils.clipImg = clipImg
        utils.completion = completion
        
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = .photoLibrary
        pickerVC.navigationBar.tintColor = sColor_RGB(51, 51, 51)
        pickerVC.navigationBar.barTintColor = .white
        pickerVC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        pickerVC.mediaTypes = [kUTTypeImage as String]
        pickerVC.delegate = utils
        if Screen_IPAD {
            pickerVC.sourceType = .photoLibrary
            pickerVC.allowsEditing = false
            let popover = UIPopoverController(contentViewController: pickerVC)

            let popWidth = Screen_Width - 100;
            let popHeight = Screen_Height - 100;
            popover.present(from: CGRect(x: 0, y: 0, width: popWidth, height: popHeight),
                            in: parentVC.view,
                            permittedArrowDirections: .any,
                            animated: true)
        } else {
            parentVC.present(pickerVC, animated: true, completion: nil)
        }
    }
    
    public static func takePhoto(in parentVC: UIViewController, clipImg: Bool, completion: ((UIImage?) -> Void)?) {
        doInMain {
            p_takePhoto(in: parentVC, clipImg: clipImg, completion: completion)
        }
    }
    
    private static func p_takePhoto(in parentVC: UIViewController, clipImg: Bool, completion: ((UIImage?) -> Void)?) {
        if isWorking {
            return
        }
        guard isCameraAvailable, supportTakingPhoto else {
            return
        }
        let utils = TRPhotoUtils()
        photoUtils = utils
        utils.parentVC = parentVC
        utils.clipImg = clipImg
        utils.completion = completion
        
        let controller = UIImagePickerController()
        controller.allowsEditing = true
        controller.sourceType = .camera
        controller.navigationBar.barStyle = .default
        controller.mediaTypes = [kUTTypeImage as String]
        controller.delegate = photoUtils
        parentVC.present(controller, animated: true, completion: nil)
    }
    
    public static func saveImgToAlbum(in parentVC: UIViewController, img: UIImage, completion: @escaping (Bool) -> ()) {
        requrestAuthorization(in: parentVC) { (authorized) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            }) { (success, error) in
                if success == false {
                }
                completion(success)
            }
        }
    }
    
    private static func requrestAuthorization(in parentVC: UIViewController, _ completion: @escaping  (Bool) -> ()) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                completion(status == .authorized)
            }
        case .restricted, .denied:
            var msg = "need your permission"
            TRAlert.showAlert(in: parentVC, title: nil, msg: msg, cancelTitle: nil, cancelClosure: { (_) in
                TRToast.show("You have not opened the photo album permission. You can go to settings - Privacy - photo opening later")
            }, confirmTitle: "Go Settings") { (_) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case .authorized:
            completion(true)
        default:
            break
        }
    }
}

extension TRPhotoUtils {
    private func clear() {
        parentVC = nil
        completion = nil
        photoUtils = nil
    }
}

extension TRPhotoUtils: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.completion?(img)
                self.clear()
                return
            }
            guard let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                self.completion?(nil)
                self.clear()
                return
            }
//            if self.clipImg {
//                let imgClipVC = YJSImgClipVC(img: img, clipSize: nil) { (clipedImg, clipVC) in
//                    clipVC.dismiss(animated: true, completion: nil)
//                    self.completion?(clipedImg)
//                    self.clear()
//                }
//                self.parentVC?.present(imgClipVC, animated: true, completion: nil)
//            } else {
            self.completion?(img)
            self.clear()
//            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(nil)
            self.clear()
        }
    }
}

extension TRPhotoUtils {
    static var isAlbumAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    static var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    static var supportTakingPhoto: Bool {
        cameraSupport(mediaType: kUTTypeImage as String, sourceType: .camera)
    }
    
    private static func cameraSupport(mediaType: String, sourceType: UIImagePickerController.SourceType) -> Bool {
        UIImagePickerController.availableMediaTypes(for: sourceType)?
            .contains() { $0 == mediaType }
            ?? false
    }
}
