//
//  Button+Extension.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation
import UIKit
extension UIButton {
    func setBackgroundColor(_ color:UIColor,selectedColor:UIColor) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if var context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorLightImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorLightImage, for: .normal)
        }
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if var context = UIGraphicsGetCurrentContext() {
            context.setFillColor(selectedColor.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorLightImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorLightImage, for: .selected)
        }
    }
}
