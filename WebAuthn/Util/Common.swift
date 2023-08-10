//
//  Common.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation
enum TethersError: Error {
    case message(String)
}

extension Error {
    var errowMessage: String {
        if let tr = self as? TethersError {
            switch tr {
            case .message(let string):
                return string
            }
        } else {
            return ((self as NSError).userInfo["msg"] as? String) ?? (self as NSError).localizedDescription
        }
    }
}
