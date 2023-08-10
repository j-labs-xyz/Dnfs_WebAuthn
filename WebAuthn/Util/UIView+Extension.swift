//
//  UIView+Extention.swift
//

import UIKit
import SVProgressHUD
import Toast_Swift
extension UIView {
     var origin:CGPoint {
         get {
             return self.frame.origin
         }
         set(newValue) {
             var rect = self.frame
             rect.origin = newValue
             self.frame = rect
         }
     }
     
     var size:CGSize {
         get {
             return self.frame.size
         }
         set(newValue) {
             var rect = self.frame
             rect.size = newValue
             self.frame = rect
         }
     }
     
     var left:CGFloat {
         get {
             return self.frame.origin.x
         }
         set(newValue) {
             var rect = self.frame
             rect.origin.x = newValue
             self.frame = rect
         }
     }
     
     var y:CGFloat {
         get {
             return self.frame.origin.y
         }
         set(newValue) {
             var rect = self.frame
             rect.origin.y = newValue
             self.frame = rect
         }
     }
     
     var right:CGFloat {
         get {
             return (self.frame.origin.x + self.frame.size.width)
         }
         set(newValue) {
             var rect = self.frame
             rect.origin.x = (newValue - self.frame.size.width)
             self.frame = rect
         }
     }
     
     var bottom:CGFloat {
         get {
             return (self.frame.origin.y + self.frame.size.height)
         }
         set(newValue) {
             var rect = self.frame
             rect.origin.y = (newValue - self.frame.size.height)
             self.frame = rect
         }
     }
    
    //MARK:-size
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set(newValue) {
            var rect = self.frame
            rect.size.width = newValue
            self.frame = rect
        }
    }

    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set(newValue) {
            var rect = self.frame
            rect.size.height = newValue
            self.frame = rect
        }
    }
    public func currentViewController() -> (UIViewController?) {
       var window = UIApplication.shared.keyWindow
       if window?.windowLevel != UIWindow.Level.normal{
         let windows = UIApplication.shared.windows
         for  windowTemp in windows{
           if windowTemp.windowLevel == UIWindow.Level.normal{
              window = windowTemp
              break
            }
          }
        }
       let vc = window?.rootViewController
       return currentVC(vc)
    }

     private func currentVC(_ vc :UIViewController?) -> UIViewController? {
       if vc == nil {
          return nil
       }
       if let presentVC = vc?.presentedViewController {
          return currentVC(presentVC)
       }
       else if let tabVC = vc as? UITabBarController {
          if let selectVC = tabVC.selectedViewController {
              return currentVC(selectVC)
           }
           return nil
        }
        else if let naiVC = vc as? UINavigationController {
           return currentVC(naiVC.visibleViewController)
        }
        else {
           return vc
        }
     }
    
    public func cornerRadius(position: UIRectCorner, cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect:self.bounds, byRoundingCorners: position, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        self.layer.mask = layer
    }
    
    func impactFeedbackGenerator() {
        if #available(iOS 10.0, *) {
            let feedBackGenertor = UIImpactFeedbackGenerator(style: .light)
            feedBackGenertor.prepare()
            feedBackGenertor.impactOccurred()
        }
    }

    func addScaleAnimation() {
        let basicAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        basicAnimation.duration = 0.2
        basicAnimation.values = [NSNumber(value: 1.0), NSNumber(value: 1.08), NSNumber(value: 1.0)]
        basicAnimation.duration = 0.25
        basicAnimation.calculationMode = .cubic
        layer.add(basicAnimation, forKey: nil)
    }
    var classNameString: String {
        var className = NSStringFromClass(type(of: self))
        if className.contains("."){
            className = className.components(separatedBy: ".").last!
        }
        return className
    }
}
extension UIView {
    func toImage () -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension UIView {
    func toast(_ msg: String) {
        self.makeToast(msg, position: .center)
    }
}
extension UIWindow {
    static func toast(_ msg: String) {
        UIApplication.shared.keyWindow?.toast(msg)
    }
    
    static func showLoading() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
    }
    
    
    static func hideLoading() {
        SVProgressHUD.dismiss()
    }
    
}
