//
//  Array+FTZSCategory.swift
//  YouShaQi
//
//  Created by J Labs
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation

extension Array {
    ///
    ///     testArr[safely:1]
     public subscript (safely index: Int) -> Element? {
        get {// Get Index
            if (self.startIndex..<self.endIndex).contains(index) {
                return self[index]
            } else {
                return nil
            }
        }
        set {// Set Index
            if let newValue = newValue {
                if (self.startIndex ..< self.endIndex).contains(index) {
                    self[index] = newValue
                }
            }
        }
    }
}

extension Collection {
    public func jsonString() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        if let jsonData = jsonData {
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } else {
            return nil
        }
    }
}

extension Array where Element: Equatable {
    mutating public func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

extension Dictionary {
    public func getStrValue(_ key: Key) -> String? {
        self[key] as? String
    }
    
    public func getIntValue(_ key: Key) -> Int? {
        self[key] as? Int
    }
    
    public func getBoolValue(_ key: Key) -> Bool? {
        self[key] as? Bool
    }
    
    public func getNumValue(_ key: Key) -> NSNumber? {
        self[key] as? NSNumber
    }
    
    public func getJsonValue(_ key: Key) -> [String : Any]? {
        self[key] as? [String : Any]
    }
}

extension Sequence {
    public func doIn(_ loop: (Element) -> ()) {
        for item in self {
            loop(item)
        }
    }
}

extension Array {
    /// Array<A> + Array<B> -> Array<(A, B)>

    ///
    ///     let a = ["1", "2"]
    ///     let b = ["一", "二", "三"]
    ///     a.zip(b)
    ///     // [("1", "一"), ("2", "二")]
    public func zip<B>(_ b: Array<B>) -> Array<(Element, B)> {
        let minCount = Swift.min(count, b.count)
        let zipped: [(Element, B)] = (0..<minCount).reduce(into: []) { (result, index) in
            let aElement = self[index]
            let bElement = b[index]
            result.append((aElement, bElement))
        }
        return zipped
    }
    
    public func iDoIn(_ loop: (Element, Int) -> ()) {
        var index = 0
        for item in self {
            loop(item, index)
            index += 1
        }
    }
    
    public func iMap<T>(_ transform: (Element, Int) throws -> T) rethrows -> [T] {
        var index = 0
        return try map { (element) -> T in
            let result = try transform(element, index)
            index += 1
            return result
        }
    }
    
    public func iFlatMap<SegmentOfResult>(_ transform: (Element, Int) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {
        var index = 0
        return try flatMap { (element) -> SegmentOfResult in
            let result = try transform(element, index)
            index += 1
            return result
        }
    }
    
    public func iCompactMap<ElementOfResult>(_ transform: (Element, Int) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        var index = 0
        return try compactMap { (element) -> ElementOfResult? in
            let result = try transform(element, index)
            index += 1
            return result
        }
    }
}
