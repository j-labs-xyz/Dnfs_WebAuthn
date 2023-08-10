//
//  Debounce.swift
//  Reversible_iOS
//
//  Created by J Labs
//  Copyright © 2022 gaoguang. All rights reserved.
//

import Foundation
import UIKit
private var debounceDict = [String: Date]()

public func debounce(_ target: NSObject, key: String? = nil, interval: TimeInterval = 1) -> Bool {
    
    let hashKey = "\(target.hashValue)" + (key ?? "")
    if let lastDate = debounceDict[hashKey] {
        let diff = fabs(lastDate.timeIntervalSince1970 - Date().timeIntervalSince1970)
        if diff > interval  {
            debounceDict[hashKey] = Date()
            print("DIFF: \(diff)")
            return true
        }
        
    } else {
        debounceDict[hashKey] = Date()
        target.whenDispose {
            debounceDict[hashKey] = nil
        }
        print("DIFF: DEBOUNCE")
        return true
    }
    return false
}


private var delayDebounceDict: [Int : Int] = [:]
public func delayDebounce(_ target: NSObject, delay: TimeInterval = 0.5, callback: @escaping (() -> Void)) {
    let nowValue = (delayDebounceDict[target.hashValue] ?? 0) + 1
    delayDebounceDict[target.hashValue] = nowValue
    delaySecond(delay) {
        if delayDebounceDict[target.hashValue] == nowValue {
            callback()
        }
    }
}

public func unDebounce(_ target: NSObject, key: String? = nil) {
    let hashKey = "\(target.hashValue)" + (key ?? "")
    debounceDict.removeValue(forKey: hashKey)
}

public extension NSObject {
    public func wait(_ key: String) -> Bool {
        return debounce(self, key: key, interval: TimeInterval(MAXFLOAT))
    }
    
    public func unwait(_ key: String) {
        unDebounce(self, key: key)
    }
}
