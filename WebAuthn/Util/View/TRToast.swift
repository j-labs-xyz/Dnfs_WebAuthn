//
//  TRToast.swift
//

import Foundation
import UIKit

public struct TRToast {
    private static var tasks: [ToastTask] = []
    
    public typealias ToastCompletion = () -> ()
    
    public static func show(_ toast: String?) {
        show(toast, delay: nil, topThanCenter: nil, completion: nil)
    }
    
    public static func show(_ toast: String?, completion: (() -> Void)?) {
        show(toast, delay: nil, topThanCenter: nil, completion: completion)
    }
    
    public static func show(_ toast: String?, delay: CGFloat) {
        show(toast, delay: delay, topThanCenter: nil, completion: nil)
    }
    
    public static func show(_ toast: String?, topThanCenter: CGFloat) {
        show(toast, delay: nil, topThanCenter: topThanCenter, completion: nil)
    }
    
    public static func show(_ toast: String?, delay: CGFloat?, topThanCenter: CGFloat?, completion: (() -> Void)?) {
        guard let toast = toast else {
            return
        }
        addToastTask(content: toast, duration: delay, topThanCenter: topThanCenter, completion: completion)
    }
        
    private static func p_show(_ toast: String, delay: CGFloat?, completion: ToastCompletion?, topThanCenter: CGFloat?) {
        guard let window = UIDevice.getWindow(), !toast.isEmpty else {
            return
        }
        existedToast(on: window)?.removeFromSuperview()
        
        let duration = delay ?? 2.0
        let label = TRToastLabel()
        label.tag = 6783
        label.backgroundColor = Color_HexA(0, alpha: 0.65)
        label.textColor = .white
        label.text = toast
        label.layer.cornerRadius = 10.0
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingHead
        
        window.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(window.frame.height * 1.0 / 6.0 - (topThanCenter ?? 0))
        }
        
        label.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.1) {
            label.transform = CGAffineTransform(scaleX: 1, y: 1)
            label.layoutIfNeeded()
        }
        doAfterInMain(seconds: duration) {
            label.removeFromSuperview()
            completion?()
            doNextToastTask()
        }
    }
}

class TRToastLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        let origin = super.intrinsicContentSize
        return CGSize(width: origin.width + 18, height: origin.height + 18)
    }
}

extension TRToast {
    fileprivate struct ToastTask {
        let content: String
        let duration: CGFloat?
        let topThanCenter: CGFloat?
        let completion: TRToast.ToastCompletion?
    }
    
    fileprivate static func canShowToastNow(onView superView: UIView) -> Bool {
        tasks.count == 0 && existedToast(on: superView) == nil
    }
    
    fileprivate static func existedToast(on superView: UIView) -> UILabel? {
        superView.subviews.first { (subview) -> Bool in
            subview.tag == 6783 && (subview is UILabel)
        } as? UILabel
    }
    
    static func addToastTask(content: String?, duration: CGFloat?, topThanCenter: CGFloat?, completion: TRToast.ToastCompletion?, force: Bool = false) {
        guard let content = content else {
            return
        }
        doInMain {
            guard let view = UIDevice.getWindow() else {
                return
            }
            if force {
                tasks.removeAll()
                existedToast(on: view)?.removeFromSuperview()
            }
            if canShowToastNow(onView: view) {
                p_show(content, delay: duration, completion: completion, topThanCenter: topThanCenter)
            } else {
                let task = ToastTask(content: content, duration: duration, topThanCenter: topThanCenter, completion: completion)
                tasks.append(task)
            }
        }
    }
    
    static func doNextToastTask() {
        guard let task = tasks.first else {
            return
        }
        tasks.removeFirst()
        p_show(task.content,
               delay: task.duration,
               completion: task.completion,
               topThanCenter: task.topThanCenter)
    }
}

extension TRToast {
    public static func forceShow(_ toast: String?, delay: CGFloat?, topThanCenter: CGFloat?, completion: (() -> Void)?) {
        guard let toast = toast else {
            return
        }
        addToastTask(content: toast, duration: delay, topThanCenter: topThanCenter, completion: completion, force: true)
    }
}
