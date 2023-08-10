//
//  ImageTextView.swift
//  Tethers
//
//  Created by J Labs
//

import Foundation
import UIKit
public class ImageTextView: UILabel {
   public enum ImageDirection{
        case left
        case right
        case top
        case bottom
    }
    

    public lazy var imageView = UIImageView.aspectFitImageView()
    
    public var contentPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    
    var fixedPadding: UIEdgeInsets {
        let imageSize = self.imageSize ??  CGSize(width: font.lineHeight, height: font.lineHeight)
        switch imageDirection {
        case .top:
            return UIEdgeInsets(top: contentPadding.top + imageSize.height + space, left: contentPadding.left, bottom: contentPadding.bottom, right: contentPadding.right)
        case .bottom:
            return UIEdgeInsets(top: contentPadding.top, left: contentPadding.left, bottom: contentPadding.bottom + space + imageSize.height, right: contentPadding.right)
        case .left:
            return UIEdgeInsets(top: contentPadding.top, left: contentPadding.left + imageSize.width + space, bottom: contentPadding.bottom, right: contentPadding.right)

        case .right:
            return UIEdgeInsets(top: contentPadding.top, left: contentPadding.left, bottom: contentPadding.bottom, right: contentPadding.right + imageSize.width + space)

        }
    }
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + ceil(fixedPadding.left) +  ceil(fixedPadding.right), height: size.height +  ceil(fixedPadding.top) +  ceil(fixedPadding.bottom))
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: CGRect(x: ceil(fixedPadding.left), y: ceil(fixedPadding.top), width: rect.size.width - ceil(fixedPadding.left) - ceil(fixedPadding.right), height:  rect.size.height - ceil(fixedPadding.top) - ceil(fixedPadding.bottom)))
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    
    public var imageSize: CGSize? {
        didSet {
            let padding = self.contentPadding
            self.contentPadding = padding
            updateUI()
        }
    }
    
    public var imageDirection: ImageDirection = .left {
        didSet {
            updateUI()
        }
    }
    public var space: CGFloat = 4 {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    func initUI() {
        self.addSubview(imageView)
        self.textAlignment = .center
    }
    
    func updateUI() {
        let imageSize = self.imageSize ?? CGSize(width: self.font.lineHeight, height: self.font.lineHeight)
      
        switch imageDirection {
        case .left:
            imageView.frame = CGRect(x: contentPadding.left, y: contentPadding.top, width: imageSize.width, height: imageSize.height)
            self.imageView.top = (self.height - imageView.height) / 2.0

        case .right:
            imageView.frame = CGRect(x: width - imageSize.width - contentPadding.right, y: contentPadding.top, width: imageSize.width, height: imageSize.height)
            self.imageView.top = (self.height - imageView.height) / 2.0

        case .top:
            imageView.frame = CGRect(x: contentPadding.left, y: contentPadding.top, width: imageSize.width, height: imageSize.height)
            self.imageView.left = (self.width - imageView.width) / 2.0
        case .bottom:
            imageView.frame = CGRect(x: contentPadding.left, y:height - contentPadding.bottom - imageSize.height, width: imageSize.width, height: imageSize.height)
            self.imageView.left = (self.width - imageView.width) / 2.0
        }
        if self.textAlignment == .natural {
            self.textAlignment = .center
        }
    }
}
