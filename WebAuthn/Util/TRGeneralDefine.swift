///
///

import Foundation
import UIKit

public var System_version_iOS10: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 10.0
}()
public var System_version_iOS11: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 11.0
}()
public var System_version_iOS12: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 12.0
}()
public var ystem_version_iOS13: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 13.0
}()

public func doInGlobal(_ block:@escaping () -> ()) {
    DispatchQueue.global().async(execute: block)
}

public func doInMain(_ block:@escaping () -> ()) {
    DispatchQueue.main.async(execute: block)
}

public func doAfterInMain(seconds delay: CGFloat, _ workItem: @escaping () -> ()) {
    let mDelay = Int(delay * 1000)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(mDelay), execute: workItem)
}

func debugLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        print(items, separator: separator, terminator: terminator)
    #endif
}

public extension Optional {
    func doIfSome(_ closure: (Wrapped) -> ()) {
        if let w = self {
            closure(w)
        }
    }
}
