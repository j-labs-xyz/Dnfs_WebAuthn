//
//  ThirdSDK.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation
import AuthenticationServices

import PromiseKit
import SVProgressHUD
class ThirdSDK {
    static func setup() {
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(UIColor.black.withAlphaComponent(0.8))
        SVProgressHUD.setMinimumSize(CGSize(width: 150, height: 150))
        SVProgressHUD.setRingRadius(20)
    }
}
