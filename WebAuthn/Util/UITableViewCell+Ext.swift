//
//  UITableViewCell+Ext.swift
//  Tethers
//
//  Created by J Labs
//

import UIKit

extension UITableViewCell {
    static var CellReuseIdentifier: String {
        return "ID_\(Self.self)"
    }
}

extension UICollectionViewCell {
    static var CellReuseIdentifier: String {
        return "ID_\(Self.self)"
    }
}
