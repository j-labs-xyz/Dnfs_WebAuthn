//
//  EventBus.swift
//  GuitarWorld
//
//  Created by J Labs
//  Copyright © 2022 GuitarWorld. All rights reserved.
//

import Foundation
import SwiftEventBus
import ObjectiveC
open class Event: NSObject {
    
}

open class EventBus {
    static let shared = EventBus()
        
    public static func on<T>(_ event: T.Type, target: AnyObject, callback: @escaping ((T) -> Void)) {
        on(EventBus.Name(rawValue: NSStringFromClass(event as! AnyClass)), target: target) { value in
            if let ev = value as? T {
                callback(ev)
            }
        }
    }
    
    public static func onceOn(_ name: EventBus.Name, target: AnyObject, callback: @escaping ((Any?) -> Void)) {
        on(name, target: target, callback: { value in
            callback(value)
            delete(name, target: target)
        })
    }
    
    public static func  on(_ name: EventBus.Name, target: AnyObject, callback: @escaping ((Any?) -> Void)) {
        let targetToken = TargetToken(name: name)
        targetToken.attach(to: target)
        targetToken.didDispose = { token in
            SwiftEventBus.unregister(token)
        }
        SwiftEventBus.on(targetToken, name: name.rawValue, sender: nil, queue: .main) { notify in
            if let dict = notify?.userInfo as? [AnyHashable: Any] {
                callback(dict["data"])
            }
        }
    }
    
    public static func fire(_ event: Event) {
        print("Fire: \n  \(event.debugDescription)")
        SwiftEventBus.post(EventBus.Name(rawValue: NSStringFromClass(event.classForCoder)).rawValue, sender: nil, userInfo: ["data" : event])
    }
    
    public static func fire(_ name: EventBus.Name, value: Any?) {
        SwiftEventBus.post(name.rawValue, sender: nil, userInfo: ["data" : value])
    }
    
    public static func delete(_ name:  EventBus.Name, target: AnyObject) {
        (target as? NSObject)?.eventBusTokens?.forEach({ token in
            if token.eventName.rawValue == name.rawValue {
                SwiftEventBus.unregister(token, name: name.rawValue)
            }
        })
    }
}

public extension EventBus {
   public struct Name: RawRepresentable {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
   }
}

private var TargetTokenKey: UInt8 = 0
    

extension NSObject {
    var eventBusTokens: [EventBus.TargetToken]? {
        if let tokens = objc_getAssociatedObject(self, &TargetTokenKey) as? [EventBus.TargetToken] {
            return tokens
        }
        return nil
    }
}

extension EventBus {
    class TargetToken {
        var didDispose: ((TargetToken) -> Void)?
        let eventName: EventBus.Name
        init(name: EventBus.Name) {
            self.eventName = name
        }
        deinit {
            didDispose?(self)
        }
        
        func attach(to target: AnyObject) {
            if var tokens = objc_getAssociatedObject(target, &TargetTokenKey) as? [TargetToken] {
                tokens.append(self)
                objc_setAssociatedObject(target, &TargetTokenKey, tokens, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(target, &TargetTokenKey, [self], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}
