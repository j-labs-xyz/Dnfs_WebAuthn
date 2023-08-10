//
//  Extension.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation
import Kingfisher
import UIKit
import YYKit
extension UIView {
    @discardableResult
    func addTap(_ callback: @escaping () -> Void) -> UITapGestureRecognizer {
        self.isUserInteractionEnabled = true
        self.gestureRecognizers?.removeAll(where: { tap in
            tap is UITapGestureRecognizer
        })
        let tap = UITapGestureRecognizer { _ in
            callback()
        }
        self.addGestureRecognizer(tap)
        return tap
    }

    @discardableResult
    func addedOn(_ superView: UIView?) -> UIView {
        if let superView = superView {
            superView.addSubview(self)
        }
        return self
    }
    
    /// Returns Navigation Bar's height
    var navigationBarHeight: CGFloat {
        return self.topViewController()?.navigationController?.navigationBar.height ?? 44
    }
}

extension UILabel {
    convenience init(_ fontSize: CGFloat,
                     weight: UIFont.Weight = .regular,
                     textColor: UIColor? = UIColor.black,
                     text: String? = nil,
                     numberOfLines: Int = 1,
                     align: NSTextAlignment = .left)
    {
        self.init()
        self.textColor = textColor
        self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        self.text = text
        self.numberOfLines = numberOfLines
        self.textAlignment = align
    }
}

extension UIImageView {
    func kfSetImageUrl(_ urlString: String?) {
        if let url = URL(string: urlString ?? "") {
            self.kf.setImage(with: url)
        }
    }
}

extension Array where Element: UIView {
    func addTap(_ callback: @escaping (UIView) -> Void) {
        self.forEach { v in
            v.addTap { [weak v] in
                guard let v = v else { return }
                callback(v)
            }
        }
    }
}

public extension String {
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Converts String to Int
    func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    /// Converts String to Double
    func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    /// Converts String to Float
    func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    
    /// Converts String to Bool
    func toBool() -> Bool? {
        let trimmedString = self.trimmed().lowercased()
        if trimmedString == "true" || trimmedString == "false" {
            return (trimmedString as NSString).boolValue
        }
        return nil
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func docDir() -> String {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        return (docPath as NSString).appendingPathComponent((self as NSString).pathComponents.last!)
    }
    
    static func uuid() -> String {
        var uuid = UserDefaults.standard.string(forKey: "UUID")
        if (uuid?.count ?? 0) > 0 {
            return uuid!
        } else {
            uuid = UUID().uuidString
            UserDefaults.standard.setValue(uuid, forKey: "UUID")
            UserDefaults.standard.synchronize()
            return uuid!
        }
    }
    
    static func randomUUID() -> String {
        return UUID().uuidString
    }
    
    /// EZSE: Converts String to NSString
    var toNSString: NSString { return self as NSString }
}

public extension UIImageView {
    /// 快捷生成UIImageView
    class func aspectFitImageView(radius: CGFloat = 0, image: UIImage? = nil) -> Self {
        let imageView = Self()
        imageView.image = image
        imageView.layer.cornerRadius = radius
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    /// 快捷生成UIImageView
    class func aspectFillImageView(tag: Int? = nil) -> Self {
        let imageView = Self()
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = tag ?? 0
        return imageView
    }
}

extension Int {
    /// EZSE: Checks if the integer is even.
    var isEven: Bool { return (self % 2 == 0) }

    /// EZSE: Checks if the integer is odd.
    var isOdd: Bool { return (self % 2 != 0) }

    /// EZSE: Checks if the integer is positive.
    var isPositive: Bool { return (self > 0) }

    /// EZSE: Checks if the integer is negative.
    var isNegative: Bool { return (self < 0) }

    /// EZSE: Converts integer value to Double.
    var toDouble: Double { return Double(self) }

    /// EZSE: Converts integer value to Float.
    var toFloat: Float { return Float(self) }

    /// EZSE: Converts integer value to CGFloat.
    var toCGFloat: CGFloat { return CGFloat(self) }

    /// EZSE: Converts integer value to String.
    var toString: String { return String(self) }

    /// EZSE: Converts integer value to UInt.
    var toUInt: UInt { return UInt(self) }

    /// EZSE: Converts integer value to Int32.
    var toInt32: Int32 { return Int32(self) }
    
    #if os(iOS)
    var scale: CGFloat {
        return CGFloat(self) * (UIScreen.main.bounds.size.width / 375.0)
    }

    var scaleHeight: CGFloat {
        return CGFloat(self) * (UIScreen.main.bounds.size.height / 815)
    }
    #endif

    /// EZSE: Converts integer value to a 0..<Int range. Useful in for loops.
    var range: CountableRange<Int> { return 0 ..< self }
}

public extension UInt {
    /// EZSE: Convert UInt to Int
    var toInt: Int { return Int(self) }
    
    /// EZSE: Greatest common divisor of two integers using the Euclid's algorithm.
    /// Time complexity of this in O(log(n))
    static func gcd(_ firstNum: UInt, _ secondNum: UInt) -> UInt {
        let remainder = firstNum % secondNum
        if remainder != 0 {
            return self.gcd(secondNum, remainder)
        } else {
            return secondNum
        }
    }
    
    /// EZSE: Least common multiple of two numbers. LCM = n * m / gcd(n, m)
    static func lcm(_ firstNum: UInt, _ secondNum: UInt) -> UInt {
        return firstNum * secondNum / UInt.gcd(firstNum, secondNum)
    }
}

extension NSObject {
    func topViewController() -> UIViewController? {
        guard let myWindow = UIApplication.shared.keyWindow else { return nil }
        var topViewController = myWindow.rootViewController
        while true {
            if (topViewController?.presentedViewController) != nil {
                topViewController = topViewController?.presentedViewController
            } else if topViewController is UINavigationController {
                let nav = topViewController as! UINavigationController
                topViewController = nav.topViewController
            } else if topViewController is UITabBarController {
                let tab = topViewController as! UITabBarController
                topViewController = tab.selectedViewController
            } else {
                break
            }
        }
        return topViewController
    }

    func showTips(tip: String!) {
        let alert = UIAlertController(title: "Tips", message: tip, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(sureAction)
        self.topViewController()?.present(alert, animated: true, completion: nil)
    }
}


