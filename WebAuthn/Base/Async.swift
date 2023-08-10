//
//  async.swift
//  DarkRiver
//
//

import Foundation

public func asyncMain(_ callback: @escaping ()-> Void) {
    DispatchQueue.main.async(execute: callback);
}

public func asyncGlobal(_ callback: @escaping ()-> Void) {
    DispatchQueue.global().async(execute: callback);
}

public func delaySecond(_ second: Double, callback: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + second) {
        callback()
    }
}
