//
//  UserDefault.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation
extension UserDefaults {
    var hasSetProfile: Bool {
        set {
           setValue(newValue, forKey: "hasSetProfile")
        }
        
        get {
            value(forKey: "hasSetProfile") as? Bool ?? false
        }
    }
}
