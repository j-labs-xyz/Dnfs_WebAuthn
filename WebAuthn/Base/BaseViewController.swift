//
//  BaseViewController.swift
//  Reversible_iOS
//
//  Created by J Labs
//  Copyright © 2021 gaoguang. All rights reserved.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift
public enum GGNavBarType : Int {
  
    case system
    
    case custom
    
    case hidden
}

open class BaseViewController: UIViewController, GGNavigationBarDelegate, GGNavigationBarDataSource {
    
    public var shouldUseIQKeyboard = true
    
    public var shouldShowNavigationBarBottomLine = false
    
    public var navBarType: GGNavBarType = .custom
   
    public var pageAlreadyShow: Bool = false


    
    public lazy var gg_navigationBar: GGNavigationBar = {
        let topHeight = 44 + UIApplication.shared.statusBarFrame.size.height
        let naviView =  GGNavigationBar(frame: CGRect(x: 0, y: 0,
                                                      width: UIScreen.main.bounds.size.width,
                                                      height: topHeight ))
        naviView.delegate = self
        naviView.dataSource = self
        view.addSubview(naviView)
        return naviView
    }()
    
    lazy var hudView: EmptyPlacehoderView = {
        let hudView = EmptyPlacehoderView(frame: self.view.bounds)
        hudView.backgroundColor = .clear
        return hudView
    }()
    
    lazy var classNameString : String = {
        var className = NSStringFromClass(type(of: self))
        if className.contains("."){
            className = className.components(separatedBy: ".").last!
        }
        return className
    }()
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageAlreadyShow = true
        
    }
    
    @objc func goBack() {
        if let viewControllers: [UIViewController] = navigationController?.viewControllers {
            guard viewControllers.count <= 1 else {
                navigationController?.popViewController(animated: true)
                return
            }
        }
        
        if (presentingViewController != nil) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if navBarType == .custom {
            gg_navigationBar.width = UIScreen.main.bounds.width
            view.bringSubviewToFront(gg_navigationBar)
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navBarType == .system {
            navigationController?.setNavigationBarHidden(false, animated:false)
            navigationController?.navigationBar.shadowImage = shouldShowNavigationBarBottomLine ? nil : UIImage()
        } else {
            navigationController?.setNavigationBarHidden(true, animated:false)
        }
        IQKeyboardManager.shared.enable = shouldUseIQKeyboard
        IQKeyboardManager.shared.shouldResignOnTouchOutside = shouldUseIQKeyboard
    }
    
    deinit {
        print("deinit:\((title ?? "?")) \(classNameString))")
    }
    
    open override var title: String? {
        didSet {
            if self.isViewLoaded == false {
                return
            }
            self.gg_navigationBar.title = self.gg_navigationBarTitle(self.gg_navigationBar)
        }
    }
        
    open func leftButtonEvent(sender:UIButton, _ navigationBar: GGNavigationBar) {
        guard navigationController?.viewControllers.count ?? 0 > 1 else { return }
        navigationController?.popViewController(animated: true)
    }
    
    open func gg_navigationBarTitle(_ navigationBar: GGNavigationBar) -> NSMutableAttributedString? {
        guard let navtitle = title else { return nil }
        let f = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let c = UIColor(hexString: "0x333333")
        return NSMutableAttributedString(string: navtitle,attributes: [NSAttributedString.Key.font:f,
                                                                       NSAttributedString.Key.foregroundColor:c])
    }
    
    open func gg_navigationHeight(_ navigationBar:GGNavigationBar) -> CGFloat? {
        return 44 + UIApplication.shared.statusBarFrame.size.height
    }
    
    open func gg_navigationBarLeftView(_ navigationBar:GGNavigationBar) -> UIView? {
        guard navigationController?.viewControllers.count ?? 0 > 1 else { return nil }

        let leftV = UIView()
        let backImage = UIImageView()
        backImage.contentMode = .scaleAspectFit
        backImage.image = gg_navigationBarLeftButtonImage(navigationBar) ?? UIImage(named: "detail_back")
        backImage.addedOn(leftV).snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 27, height: 27))
        }
        leftV.frame = CGRect(x: 0, y: 0, width: 48, height: 44)
        leftV.isUserInteractionEnabled = true
        leftV.addTap { [weak self] in
            guard let self = self else { return }
            self.didClickLeft()
        }
        return leftV
    }
    @objc func didClickLeft() {
        guard navigationController?.viewControllers.count ?? 0 > 1 else { return }
        navigationController?.popViewController(animated: true)
    }
    open func gg_navigationBarBackgroundImage(_ navigationBar: GGNavigationBar) -> UIImage? { return nil }
    
    open func gg_navigationIsHideBottomLine(_ navigationBar:GGNavigationBar) -> Bool? { return true }
    
    open func gg_navigationBarLeftButtonImage(_ navigationBar:GGNavigationBar) -> UIImage? {
        return nil
    }
    
    open func rightButtonEvent(sender:UIButton, _ navigationBar: GGNavigationBar){}
    
    open func titleClickEvent(sender:UILabel, _ navigationBar: GGNavigationBar){}
    
    open func gg_navigationBackgroundColor(_ navigationBar:GGNavigationBar) -> UIColor? { return nil }
    
    open func gg_navigationBarRightView(_ navigationBar:GGNavigationBar) -> UIView? { return nil }
    
    open func gg_navigationBarTitleView(_ navigationBar:GGNavigationBar) -> UIView? { return nil }
    
    open func gg_navigationBarRightButtonImage(_ navigationBar:GGNavigationBar) -> UIImage? { return nil }
    
    
    // MARK: - JHUD -
    
    open func showHUD(isCover:Bool = false, isMask:Bool = false) {
        hudView.messageLabel.text = ""
        hudView.backgroundColor = isCover ? UIColor.white : UIColor.clear
        hudView.show(at: view)
    }

    open func hiddenHUD() {
        hudView.hide()
    }

    open func showJHudExceptionsHandleBlock(_ exceptionsHandleBlock:@escaping () -> Void) {
        hudView.retryLoadHandler = exceptionsHandleBlock
    }

    open func showHUDFailure() {
        hudView.backgroundColor = .white
        view.bringSubviewToFront(hudView)
    }
    
    open var pageName: String? {
        return nil
    }
    open var pageProperties: [String: AnyHashable]? {
        return nil
    }
}


#warning("WildToDo")
extension String {
    
    var localized: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
}

class EmptyPlacehoderView: UIView {
    
    var retryLoadHandler: (()->())?
    
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Network unavailable".localized
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("reload".localized, for: .normal)
        button.backgroundColor = UIColor.black
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .highlighted)
        button.addTarget(self, action: #selector(actionButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var placehoderImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "jiazaishibai")
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(messageLabel)
        addSubview(actionButton)
        addSubview(placehoderImageView)
        
        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        placehoderImageView.snp.makeConstraints { make in
            make.bottom.equalTo(messageLabel.snp.top).inset(10)
            make.centerX.equalTo(messageLabel)
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerX.equalTo(messageLabel)
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
        }
    }
    
    
    @objc func actionButtonAction() {
        retryLoadHandler?()
    }
    
    func show(at view: UIView) {
        self.removeFromSuperview()
        view.addSubview(self)
        view.bringSubviewToFront(self)
    }
    
    func hide() {
        self.isHidden = true
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
