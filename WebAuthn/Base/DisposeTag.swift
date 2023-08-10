//
//  DisposeTag.swift
//  Reversible_iOS
//
//  Created by J Labs
//  Copyright © 2022 gaoguang. All rights reserved.
//

import Foundation
import UIKit

public protocol DisposeObservable: NSObjectProtocol, Hashable {
    func whenDispose(_ callback: @escaping ()-> Void)
}

extension NSObject: DisposeObservable {
    
    public func whenDispose(_ callback: @escaping ()-> Void) {
        if let tag = self.disposeTag {
            tag.disposeCallbacks.append(callback)
            self.disposeTag = tag
        } else {
            let tag = DisposeTag()
            tag.disposeCallbacks.append(callback)
            self.disposeTag = tag
        }
    }
    private struct RuntimeKey {
        static let disposeTag = UnsafeRawPointer.init(bitPattern: "disposeTag".hashValue)
    }
    var disposeTag: DisposeTag? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.disposeTag!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.disposeTag!) as? DisposeTag
        }
    }
    
    
    
    class DisposeTag: NSObject {
        var disposeCallbacks: [()-> Void] = []
        
        deinit {
            disposeCallbacks.forEach { $0() }
        }
    }
}
