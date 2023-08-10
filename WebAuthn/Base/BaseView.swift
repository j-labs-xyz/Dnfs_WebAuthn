//
//  BaseView.swift
//  GuitarWorld
//
//  Created by J Labs
//  Copyright © 2022 GuitarWorld. All rights reserved.
//

import Foundation
import UIKit
class BaseView: UIView {
    private(set) var isSetup: Bool = false
    
    open func setupUI() {
        isSetup = true
    }
    
    override public init(frame: CGRect) {

        super.init(frame: frame)
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    override open  func awakeFromNib() {

        super.awakeFromNib()

          setupUI()
    }
    
    open class func nibInstance() -> Self {
        return Bundle.main.loadNibNamed(String(NSStringFromClass(self.classForCoder()).split(separator: ".").last ?? ""), owner: nil, options: nil)?.first as! Self
    }
    
    open var enableTouchFeedback: Bool = false
    static var coverView :UIView = UIView()
    
    private weak var scrollView: UIScrollView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {       
        let v = super.hitTest(point, with: event)
        let hasTap = v?.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer}) != nil
        if self.bounds.contains(point) && enableTouchFeedback {
            if (v is BaseView) == false && hasTap {
                removeCoverView()
            } else {
                BaseView.coverView.isUserInteractionEnabled = false;
                BaseView.coverView.backgroundColor = UIColor(hexString: "0xF6F6f6")
                self.insertSubview(BaseView.coverView, at: 0)
                BaseView.coverView.frame = self.bounds
                self.observSrollView()
            }
        } else {
            removeCoverView()
        }
       return v
    }
    
    func observSrollView() {
        var scr: UIScrollView?
        var v: UIView? = self
        while v != nil {
            if let s = v as? UIScrollView {
                scr = s
                break
            }
            v = v?.superview
        }
        if let s = scr, scrollView != s {
            scrollView?.removeObserver(self, forKeyPath: "contentOffset")
            scrollView = s
            scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        BaseView.coverView.removeFromSuperview()
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
        scrollView = nil
    }
    
    func removeCoverView() {
        if (enableTouchFeedback && BaseView.coverView.superview == self) {
            BaseView.coverView.removeFromSuperview()
            scrollView?.removeObserver(self, forKeyPath: "contentOffset")
            scrollView = nil
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let res = super.point(inside: point, with: event)
        if res == false && enableTouchFeedback {
            removeCoverView()
        }
        return res
    }
    
    

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeCoverView()
        super.touchesEnded(touches, with: event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeCoverView()
        super.touchesCancelled(touches, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        removeCoverView()
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)
        removeCoverView()
    }
}


//extension UIView {
//    static var enableTouchFeedbackKey = "enableTouchFeedbackKey"
//    var enableTouchFeedback: Bool {
//        set {
//            objc_setAssociatedObject(self, &UIView.enableTouchFeedbackKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
//        }
//        get {
//            return objc_getAssociatedObject(self, &UIView.enableTouchFeedbackKey) as? Bool ?? false
//        }
//    }
//    static var touchFeedbackKey = "touchFeedbackKey"
//    var touchFeedback: UIView {
//        set {
//            objc_setAssociatedObject(self, &UIView.touchFeedbackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            if let v = objc_getAssociatedObject(self, &UIView.touchFeedbackKey) as? UIView {
//                return v
//            }
//            let v = UIView()
//            self.touchFeedback = v
//            return v
//        }
//    }
//}
