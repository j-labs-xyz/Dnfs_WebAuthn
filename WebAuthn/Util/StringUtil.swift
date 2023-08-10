//
//  StringUtil.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation
import UIKit

public func textAutoWidth(string: String, font: UIFont) -> CGFloat {
    let strWidth = (string as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 17), options: .truncatesLastVisibleLine, attributes: [NSAttributedString.Key.font:font], context: nil).size.width + 2
    return strWidth
}
