//
//  String+Extension.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
