//
//  GGNavigationBar.swift
//  MaoTiSwift
//
//  Created by J Labs
//  Copyright © 2020 sowell.com. All rights reserved.
//

import UIKit
// import UIKitExtension
import SnapKit

import YYKit
/****
 lazy var gg_navigationBar:GGNavigationBar = {
     let naviView =  GGNavigationBar(frame: CGRect(x: 0, y: 0, width: pp_screenWidth, height: pp_screen_navbar_height))
     self.view.addSubview(naviView)
     naviView.delegate = self
     naviView.dataSource = self
     return naviView
 }()

 override func viewDidLayoutSubviews() {
     super.viewDidLayoutSubviews()
     gg_navigationBar.width = pp_screenWidth
     view.bringSubviewToFront(gg_navigationBar)
 }
 */


public protocol GGNavigationBarDelegate: AnyObject {
    func leftButtonEvent(sender:UIButton, _ navigationBar: GGNavigationBar)
    func rightButtonEvent(sender:UIButton, _ navigationBar: GGNavigationBar)
    func titleClickEvent(sender:UILabel, _ navigationBar: GGNavigationBar)
}

public protocol GGNavigationBarDataSource: AnyObject{
    func gg_navigationBarTitle(_ navigationBar:GGNavigationBar) -> NSMutableAttributedString?
    func gg_navigationBarBackgroundImage(_ navigationBar:GGNavigationBar) -> UIImage?
     func gg_navigationBackgroundColor(_ navigationBar:GGNavigationBar) -> UIColor?
     func gg_navigationIsHideBottomLine(_ navigationBar:GGNavigationBar) -> Bool?
     func gg_navigationHeight(_ navigationBar:GGNavigationBar) -> CGFloat?
     func gg_navigationBarLeftView(_ navigationBar:GGNavigationBar) -> UIView?
     func gg_navigationBarRightView(_ navigationBar:GGNavigationBar) -> UIView?
     func gg_navigationBarTitleView(_ navigationBar:GGNavigationBar) -> UIView?
     func gg_navigationBarLeftButtonImage(_ navigationBar:GGNavigationBar) -> UIImage?
     func gg_navigationBarRightButtonImage(_ navigationBar:GGNavigationBar) -> UIImage?
}

public extension GGNavigationBarDelegate {
    
    func leftButtonEvent(sender:UIButton, _ navigationBar: GGNavigationBar){}
    
    func rightButtonEvent(sender:UIButton, _ navigationBar: GGNavigationBar){}
    
    func titleClickEvent(sender:UILabel, _ navigationBar: GGNavigationBar){}
}

public extension GGNavigationBarDataSource {
    func gg_navigationBarTitle(_ navigationBar:GGNavigationBar) -> NSMutableAttributedString? { return nil }
    func gg_navigationBarBackgroundImage(_ navigationBar:GGNavigationBar) -> UIImage? { return nil }
    func gg_navigationBackgroundColor(_ navigationBar:GGNavigationBar) -> UIColor? { return nil }
    func gg_navigationIsHideBottomLine(_ navigationBar:GGNavigationBar) -> Bool? { return true }
    func gg_navigationHeight(_ navigationBar:GGNavigationBar) -> CGFloat? { return nil }
    func gg_navigationBarLeftView(_ navigationBar:GGNavigationBar) -> UIView? { return nil }
    func gg_navigationBarRightView(_ navigationBar:GGNavigationBar) -> UIView? { return nil }
    func gg_navigationBarTitleView(_ navigationBar:GGNavigationBar) -> UIView? { return nil }
    func gg_navigationBarLeftButtonImage(_ navigationBar:GGNavigationBar) -> UIImage? { return nil }
    func gg_navigationBarRightButtonImage(_ navigationBar:GGNavigationBar) -> UIImage? { return nil }
}

private let NaviViewMargin:CGFloat = 5
private let GGNaviLeftMargin:CGFloat = 0
private let GGNaviRightMargin:CGFloat = 0
public let GGNaviSmallTouchSizeHeight:CGFloat = 44
public let GGLeftRightViewSizeMinWidth:CGFloat = 60

open class GGNavigationBar: UIView {
    /// dataSource
    weak var dataSource:GGNavigationBarDataSource? {
        didSet{
            setupDataSourceUI()
        }
    }
    /// delegate
    weak var delegate:GGNavigationBarDelegate?
    lazy var bottomBlackLineView:UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hexString: "0x999999")
        lineView.frame = CGRect(x: 0, y: self.height, width: self.width, height: 0.5)
        addSubview(lineView)
        return lineView
    }()
    /// backgroundImage
    var backgroundImage:UIImage? {
        didSet{
            layer.contents = backgroundImage?.cgImage
        }
    }
    /// titleView
    public var titleView:UIView? {
        didSet{
            oldValue?.removeFromSuperview()
            configureTitleView()
        }
    }
    /// leftView
    public var leftView:UIView? {
        didSet{
            oldValue?.removeFromSuperview()
            configureLeftView()
        }
    }
    /// rightView
    public var rightView:UIView? {
        didSet{
            oldValue?.removeFromSuperview()
            configureRightView()
        }
    }
    /// title
    public var title:NSMutableAttributedString? {
        didSet{
            configureTitle()
        }
    }
    
    public var isTitleViewCovered = false
    
    var isCenterHitTest = false
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if isCenterHitTest {
            if (point.x < rightView?.left ?? 0) && (point.x > leftView?.right ?? 0) {
                return nil
            }
        }
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBarUIOnce()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupNavigationBarUIOnce()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        superview?.bringSubviewToFront(self)
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        var leftViewFrame = CGRect.zero
        var rightViewFrame = CGRect.zero
        var titleViewFrame = CGRect.zero
        
        if leftView != nil {
            leftViewFrame = CGRect(x: 0,
                                   y: statusBarHeight,
                                   width: leftView!.width,
                                   height: leftView!.height)
            leftView!.frame = leftViewFrame
        }
        
        if rightView != nil {
            rightViewFrame = CGRect(x: self.width - rightView!.width,
                                    y: statusBarHeight,
                                    width: rightView!.width,
                                    height: rightView!.height)
            rightView!.frame = rightViewFrame
        }
        
        if titleView != nil {
            ///super.layoutSubview
            var topY = statusBarHeight + (self.height - statusBarHeight - titleView!.height) * 0.5
            if topY + titleView!.height >  self.height {
                topY = self.height - titleView!.height
            }
            if isTitleViewCovered {
                let minWidth = self.width - leftViewFrame.width - max(rightViewFrame.width, NaviViewMargin) - NaviViewMargin * 2
                titleViewFrame = CGRect(x: 0,
                                        y: topY ,
                                        width: minWidth,
                                        height: titleView!.height)
                titleViewFrame.origin.x = leftViewFrame.width + NaviViewMargin
                titleView!.frame = titleViewFrame
                
            } else {
                let minWidth = self.width - max(leftViewFrame.width,rightViewFrame.width) * 2 - NaviViewMargin * 2
                titleViewFrame = CGRect(x: 0,
                                        y: topY ,
                                        width: minWidth,
                                        height: titleView!.height)
                titleViewFrame.origin.x = self.width * 0.5 - titleView!.width * 0.5
                titleView!.frame = titleViewFrame
            }
        }
        bottomBlackLineView.frame = CGRect(x: 0, y: self.height, width: self.width, height: 0.5)
    }
    
    private func configureLeftView() {
        leftView?.removeFromSuperview()
        if let newLeftView = leftView {
            addSubview(newLeftView)
            if newLeftView is UIButton {
                let btn = newLeftView as? UIButton
                btn?.addTarget(self, action: #selector(leftBtnClick(_:)), for: .touchUpInside)
            }
            layoutIfNeeded()
        }
    }
    
    private func configureRightView() {
        rightView?.removeFromSuperview()
        if let newRightView = rightView {
            addSubview(newRightView)
            if newRightView is UIButton {
                let btn = newRightView as? UIButton
                btn?.addTarget(self, action: #selector(rightBtnClick(_ :)), for: .touchUpInside)
            }
            layoutIfNeeded()
        }
    }
    
    private func configureTitleView(){
        titleView?.removeFromSuperview()
        if let newTitleView = titleView {
            titleView?.isUserInteractionEnabled = true
            addSubview(newTitleView)
            var isHaveTapGes = false
            if let gestureRecognizers = titleView?.gestureRecognizers {
                for item in gestureRecognizers where item is UITapGestureRecognizer{
                    isHaveTapGes = true
                    break
                }
            }
            if isHaveTapGes == false {
                let tap = UITapGestureRecognizer(target: self, action: #selector(titleClick(_ :)))
                titleView?.addGestureRecognizer(tap)
            }
            layoutIfNeeded()
        }
    }
    
    private func configureTitle(){
        if titleView is UILabel {
            (titleView as! UILabel).attributedText = title
        }else{
            let navTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width * 0.4, height: 44))
            navTitleLabel.attributedText = title
            navTitleLabel.textAlignment = .center
            navTitleLabel.backgroundColor = UIColor.clear
            navTitleLabel.isUserInteractionEnabled = true
            navTitleLabel.lineBreakMode = .byTruncatingTail
            titleView = navTitleLabel
        }
    }
    
    // MARK: - event
    @objc private func leftBtnClick(_ sender: UIButton){
        delegate?.leftButtonEvent(sender: sender, self)
    }
    
    @objc private func rightBtnClick(_ sender: UIButton){
        delegate?.rightButtonEvent(sender: sender, self)
    }
    
    @objc private func titleClick(_ tap: UIGestureRecognizer){
        let tapView = tap.view
        if let newTapView = tapView as? UILabel {
            delegate?.titleClickEvent(sender: newTapView, self)
        }
    }
    
    
    private func setupDataSourceUI() {
        if let navigationHeight = dataSource?.gg_navigationHeight(self)  {
            self.size = CGSize(width: UIScreen.main.bounds.width, height: navigationHeight)
        }else{
            self.size = CGSize(width: UIScreen.main.bounds.width,
                               height: (self.navigationBarHeight) + (UIApplication.shared.statusBarFrame.height))
        }
        
        if let navigationIsHideBottomLine = dataSource?.gg_navigationIsHideBottomLine(self) {
            bottomBlackLineView.isHidden = navigationIsHideBottomLine
        }
        
        if let navigationBarBackgroundImage = dataSource?.gg_navigationBarBackgroundImage(self){
            backgroundImage = navigationBarBackgroundImage
        }
        
        if let navigationBackgroundColor = dataSource?.gg_navigationBackgroundColor(self) {
            backgroundColor = navigationBackgroundColor
        }
        
        if let navigationBarTitleView = dataSource?.gg_navigationBarTitleView(self) {
            titleView = navigationBarTitleView
        } else if let navigationBarTitle = dataSource?.gg_navigationBarTitle(self) {
            self.title = navigationBarTitle
        }
        
        if let navigationBarLeftView = dataSource?.gg_navigationBarLeftView(self) {
            leftView = navigationBarLeftView
        } else if let navigationBarLeftButtonImage = dataSource?.gg_navigationBarLeftButtonImage(self) {
            let btn = UIButton(frame: CGRect(x: 0,
                                             y: 0,
                                             width: GGNaviSmallTouchSizeHeight,
                                             height: GGNaviSmallTouchSizeHeight))
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            btn.setImage(navigationBarLeftButtonImage, for: .normal)
            leftView = btn
        }

        if let navigationBarRightView = dataSource?.gg_navigationBarRightView(self) {
            rightView = navigationBarRightView
        } else if let navigationBarRightButtonImage = dataSource?.gg_navigationBarRightButtonImage(self) {
            let btn = UIButton(frame: CGRect(x: 0,
                                             y: 0,
                                             width: GGLeftRightViewSizeMinWidth,
                                             height: GGNaviSmallTouchSizeHeight))
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            btn.setImage(navigationBarRightButtonImage, for: .normal)
            rightView = btn
        }
    }
    
    private func setupNavigationBarUIOnce() {
        backgroundColor =  UIColor.white
    }
    
}
