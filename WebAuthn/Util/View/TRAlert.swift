//
//  TRAlert.swift
//

import Foundation
import UIKit

public struct TRAlert {
    public static func showAlert(in parentVC: UIViewController, title: String?, msg: String?, cancelTitle: String = "cancel", cancelClosure: ((UIAlertAction) -> Void)? = nil) {
        showAlert(in: parentVC, title: title, msg: msg, cancelTitle: cancelTitle, cancelClosure: cancelClosure, confirmTitle: nil, confirmClosure: nil)
    }
    
    public static func showAlert(in parentVC: UIViewController, title: String?, msg: String?, cancelTitle: String?, cancelClosure: ((UIAlertAction) -> Void)?, confirmTitle: String?, confirmClosure: ((UIAlertAction) -> Void)?) {
        doInMain {        
            let alert = TRAlertController(title: title, message: msg, preferredStyle: .alert)
            if let cancel = cancelTitle {
                alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: cancelClosure))
            }
            if let confirm = confirmTitle {
                alert.addAction(UIAlertAction(title: confirm, style: .default, handler: confirmClosure))
            }
            parentVC.present(alert, animated: true, completion: nil)
        }
    }
}

open class TRAlertController: UIAlertController {
    open override var shouldAutorotate: Bool {
        false
    }
}
