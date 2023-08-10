//
//  BaseTableViewCell.swift
//  GuitarWorld
//
//  Created by J Labs
//  Copyright © 2022 GuitarWorld. All rights reserved.
//
import UIKit
class BaseTableViewCell: UITableViewCell {
    
    class public func cell(tableView:UITableView) -> Self {
        var cell = tableView.deqCell(c:self)
        if cell == nil {
            cell = self.init(id:reuseId())
            cell!.selectionStyle = .none
            cell!.createUI()
        }
        return cell!
    }
    
    private var touchbackView = BaseView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createUI()
    }
    
    var enableTouchBack: Bool = false {
        didSet {
            if enableTouchBack == false {
                touchbackView.removeFromSuperview()
            } else {
                touchbackView
                    .enableTouchFeedback = true
                contentView.insertSubview(touchbackView, at: 0)
                touchbackView.addedOn(contentView).snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if enableTouchBack {
            contentView.insertSubview(touchbackView, at: 0)
        } else {
            touchbackView.removeFromSuperview()
        }
    }
    
    required public init(id:String) {
        super.init(style:.default,reuseIdentifier:id)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createUI()
    }

    
    
    
    open func createUI() {
        selectionStyle = .none
    }

}

public protocol LXReuseIdProtocol {
    static func reuseId() -> String
}

public extension LXReuseIdProtocol {
    static func reuseId() -> String {
        let id = "\(type(of:self))" as NSString
        let reuseId = id.substring(to:id.length-5)
        return reuseId
    }
}

extension UITableViewCell: LXReuseIdProtocol {
    public static func reuseId() -> String {
        return String(NSStringFromClass(Self.classForKeyedUnarchiver()))
    }
}
extension UITableViewHeaderFooterView: LXReuseIdProtocol {}

public extension UITableView {
    func deqCell<T: LXReuseIdProtocol>(c:T.Type) -> T? {
        return self.dequeueReusableCell(withIdentifier:c.reuseId()) as? T
    }

    func deqHeader<T: LXReuseIdProtocol>(h:T.Type) -> T? {
        return self.dequeueReusableHeaderFooterView(withIdentifier:h.reuseId()) as? T
    }
    
}
