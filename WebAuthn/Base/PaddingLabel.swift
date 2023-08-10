//
//  PaddingLabel.swift
//  GuitarWorld
//
//  Created by J Labs
//  Copyright © 2022 GuitarWorld. All rights reserved.
//

import Foundation
import UIKit
open class PaddingLabel: UILabel {
   public var padding: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }
    open override func drawText(in rect: CGRect) {
        super.drawText(in: CGRect(x: padding.left, y: padding.top, width: width - padding.left - padding.right, height: height - padding.top - padding.bottom))
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right, height: size.height + padding.top + padding.bottom)
    }
}
