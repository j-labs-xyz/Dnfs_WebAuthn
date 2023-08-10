//
//  YJSUIDefine.swift
//  YouShaQi
//
//  Created by J Labs
//

import Foundation
import UIKit
import CoreGraphics

public func array2NSMutableArray(_ array: [Any]) -> NSMutableArray {
    let NSMutableArray: NSMutableArray = []
    for item in array {
        NSMutableArray.add(item)
    }
    return NSMutableArray
}

public func sColor_RGB(_ r: UInt, _ g: UInt, _ b: UInt) -> UIColor {
    return sColor_RGBA(r, g, b, 1.0)
}

public func sColor_RGBA(_ r: UInt, _ g: UInt, _ b: UInt, _ a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
}

public func Color_Hex(_ hexStr: String) -> UIColor {
    return Color_Hex(hexStringToInt(from: hexStr))
}

public func Color_Hex(_ rgbValue: UInt) -> UIColor {
    return Color_HexA(rgbValue, alpha: 1.0)
}

public func Color_HexA(_ hexStr: String, alpha: CGFloat) -> UIColor {
    return Color_HexA(hexStringToInt(from: hexStr), alpha: alpha)
}

public func Color_HexA(_ rgbValue: UInt, alpha: CGFloat) -> UIColor {
    let r = (rgbValue & 0xFF0000) >> 16
    let g = (rgbValue & 0x00FF00) >> 8
    let b = rgbValue & 0x0000FF
    return sColor_RGBA(r, g, b, alpha)
}

public func randrom() -> UIColor {
    let r = CGFloat(arc4random()%256)/255.0
    let g = CGFloat(arc4random()%256)/255.0
    let b = CGFloat(arc4random()%256)/255.0
    if #available(iOS 10.0, *) {
        let color = UIColor(displayP3Red: r, green: g, blue: b, alpha: 1)
        return color
    } else {
        // Fallback on earlier versions
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

fileprivate func hexStringToInt(from:String) -> UInt {
    let str = from.replacingOccurrences(of: "#", with: "").uppercased()
    var sum = 0
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48 // 0-9
        if i >= 65 {                 // A-Z
            sum -= 7
        }
    }
    return UInt(sum)
}

public let kStatusBarHeight = UIApplication.shared.statusBarFrame.height

public let Screen_Width = UIScreen.main.bounds.size.width
public let Screen_Height = UIScreen.main.bounds.size.height
public let Screen_SafeBottomHeight : CGFloat =  UIDevice.yjs_safeAreaInsets().bottom
public let Screen_SafeTopHeight : CGFloat = (Screen_FullScreenIphone) ? 24.0 : 0.0

public let Screen_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
public let Screen_IPHONE = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone)
public let Screen_FullScreen = UIDevice.yjs_safeAreaInsets().bottom > 0.0 ? true : false
public let Screen_FullScreenIphone = Screen_IPHONE && Screen_FullScreen
public let Screen_FullScreenIpad = Screen_IPAD && Screen_FullScreen
public let Screen_NavHeight : CGFloat = (Screen_FullScreenIphone) ? 88.0 : 64.0
public let Screen_BigNavHeight : CGFloat = Screen_IPAD ? 80.0 : Screen_NavHeight
public let Screen_NavItemY : CGFloat = (Screen_FullScreenIphone) ? 44.0 : 20.0

public let TRNotificationLoginSuccess = "TYNotificationLoginSuccess"


