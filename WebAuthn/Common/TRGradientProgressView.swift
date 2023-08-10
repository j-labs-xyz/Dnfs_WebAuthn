//
//  TRGradientProgressView.swift
//  Tethers
//
//  Created by J Labs
//

import UIKit

open class TRGradientProgressView: UIView {
    
    public var progressColors: [UIColor] = [.blue] {
        didSet {
            if progressColors.count == 0 {
                gradientLayer.colors = nil
            } else if progressColors.count == 1 {
                let color = progressColors[0]
                gradientLayer.colors = [color, color].map { $0.cgColor }
            } else {
                gradientLayer.colors = progressColors.map { $0.cgColor }
            }
        }
    }
    
    public var progressCornerRadius: CGFloat = 0 {
        didSet {
            maskLayer.cornerRadius = progressCornerRadius
        }
    }
    
    
    
    public let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.anchorPoint = .zero
        layer.startPoint = .zero
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        return layer
    }()
    
    public var animationDuration: TimeInterval = 0.3
    
    public var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .default)
    
    private var privateProgress: Float = 0
    private let maskLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }()
    
    open override var backgroundColor: UIColor? {
        didSet {
            maskLayer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    public var progress: Float {
        get {
            return privateProgress
        }
        set {
            setProgress(newValue, animated: false)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        let color = progressColors[0]
        gradientLayer.colors = [color, color].map { $0.cgColor }
        gradientLayer.mask = maskLayer
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds.inset(by: .zero)
        var bounds = gradientLayer.bounds
        bounds.size.width *= CGFloat(progress)
        maskLayer.frame = bounds
    }
    
    public func setProgress(_ progress: Float, animated: Bool) {
        let validProgress = min(1.0, max(0.0, progress))
        if privateProgress == validProgress {
            return
        }
        privateProgress = validProgress
        
        var duration = animated ? animationDuration : 0
        if duration < 0 {
            duration = 0
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        
        var bounds = self.gradientLayer.bounds
        bounds.size.width *= CGFloat(validProgress)
        self.maskLayer.frame = bounds
        
        CATransaction.commit()
    }
}
