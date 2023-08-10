//
//  UIDevice+Info.swift
//  YouShaQi
//
//  Created by J Labs
//

import UIKit
import CoreTelephony

extension UIDevice {
    @objc class public func yjs_screenResolution() -> String {
        let rect = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let width = rect.width * scale
        let height = rect.height * scale
        return "\(width)*\(height)"
    }
    
    class public func getWindow() -> UIWindow? {
        guard let optional = UIApplication.shared.delegate?.window, let window = optional else {
            return nil
        }
        return window
    }
    
    @objc class public func yjs_safeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            guard let safeAreaInsets = getWindow()?.safeAreaInsets else {
                return UIEdgeInsets.zero
            }
            
            return safeAreaInsets
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    @objc class public func yjs_isFullScreen() -> Bool {
        let safeAreaInsets = UIDevice.yjs_safeAreaInsets()
        return safeAreaInsets.bottom > 0
    }
    
    @objc class public func yjs_systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    @objc class public func yjs_platform() -> String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        return platform
    }

    class public func yjs_carrierCode() -> String {
        let telephonyInfo = CTTelephonyNetworkInfo()
        let carrier = telephonyInfo.subscriberCellularProvider
        return carrier?.mobileNetworkCode ?? ""
    }
    
    class public func yjs_imsi() -> String {
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        let mcc = carrier?.mobileCountryCode ?? ""
        let mnc = carrier?.mobileNetworkCode ?? ""
        let imsi = "\(mcc)\(mnc)"
        return imsi
    }
    
}
