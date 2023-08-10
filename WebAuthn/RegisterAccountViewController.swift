//
//  RegisterAccountViewController.swift
//  WebAuthn
//
//  Created by leven on 2023/8/10.
//

import Foundation
import UIKit
class RegisterAccountViewController: BaseViewController {
    
    lazy var titleLabel = UILabel(40.scale, weight: .bold, textColor: UIColor.color_333333, text: "Sign In")
    
    lazy var switchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("sign up", for: .normal)
        button.setTitle("sign in", for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.color_828282, for: .normal)
        button.addTarget(self, action: #selector(self.switchSignIn), for: .touchUpInside)
        return button

    }()
    

    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Configm", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.color_171717
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.clickconfirm), for: .touchUpInside)
        return button
    }()
    
    lazy var nameInput: UITextField = {
        let input = UITextField()
        input.placeholder = "Input name"
        input.font = UIFont.systemFont(ofSize: 16.scale)
        input.borderStyle = .roundedRect
        input.attributedPlaceholder = NSAttributedString(string: "Input name", attributes: [.font: UIFont.systemFont(ofSize: 16.scale), .foregroundColor: UIColor(hexString: "#AAAAAA")!])
        input.backgroundColor = UIColor(hexString: "#EEEEEE")
        return input
    }()
    
    lazy var passwordInput: UITextField = {
        let input = UITextField()
        input.font = UIFont.systemFont(ofSize: 16.scale)
        input.borderStyle = .roundedRect
        input.attributedPlaceholder = NSAttributedString(string: "Input password", attributes: [.font: UIFont.systemFont(ofSize: 16.scale), .foregroundColor: UIColor(hexString: "#AAAAAA")!])
        input.backgroundColor = UIColor(hexString: "#EEEEEE")
        return input
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.titleLabel.addedOn(self.view).snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(120.scale)
        }
        
        nameInput.addedOn(self.view).snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(100.scale)
            make.width.equalTo(300.scale)
            make.height.equalTo(48.scale)
        }
        self.passwordInput.alpha = 0
        self.passwordInput.addedOn(self.view).snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.height.equalTo(self.nameInput)
            make.top.equalTo(self.nameInput.snp.bottom).offset(12.scale)
        }

        
        
        self.confirmButton.addedOn(self.view).snp.makeConstraints { make in
            make.left.equalTo(20.scale)
            make.centerX.height.equalTo(nameInput)
            make.bottom.equalTo(-50.scale)
        }
        self.switchButton.addedOn(self.view).snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.confirmButton.snp.top).offset(-16.scale)
        }
        
        self.view.addTap { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
        }
    }
    
    @objc func switchSignIn() {
        self.switchButton.isSelected = !self.switchButton.isSelected
        self.titleLabel.text = self.switchButton.isSelected ? "Sign Up" : "Sign In"
        UIView.animate(withDuration: 0.2) {
            if self.switchButton.isSelected {
                self.passwordInput.alpha = 1
            } else {
                self.passwordInput.alpha = 0
            }
        }
    }
    
    @objc func clickconfirm() {
        if self.switchButton.isSelected {
            self.signUp()
        } else {
            self.signIn()
        }
    }
    
    func signUp() {
        guard let name = self.nameInput.text, name.trimmed().count > 0 else {
            UIWindow.toast("please input name")
            return
        }
        
        guard let password = self.passwordInput.text, password.trimmed().count > 0 else {
            UIWindow.toast("please input password")
            return
        }
        UIWindow.showLoading()
        DfnsManager.shared.register(username: name, password: password).done { [weak self]json in
            guard let self = self else { return }
            if let name = json["username"].string {
                UIWindow.toast("Go to sign in")
                self.switchSignIn()
                self.nameInput.text = name
            } else {
                UIWindow.toast(json.rawString() ?? "")
            }
        }.ensure {
            UIWindow.hideLoading()
        }.catch { error in
            UIWindow.toast(error.localizedDescription)
        }
    }
    
    func signIn() {
        guard let name = self.nameInput.text, name.trimmed().count > 0 else {
            UIWindow.toast("please input name")
            return
        }
        
        UIWindow.showLoading()
        DfnsManager.shared.signIn(username: name).done { [weak self]json in
            guard let self = self else { return }
            if let name = json["username"].string {
                
                UserDefaults.standard.set(name, forKey: "user_name")
                let window = UIApplication.shared.keyWindow!
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    let oldState = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    window.rootViewController = UINavigationController(rootViewController: AccountViewController(username: name))
                    UIView.setAnimationsEnabled(oldState)
                })
            } else {
                UIWindow.toast(json.rawString() ?? "")
            }
        }.ensure {
            UIWindow.hideLoading()
        }.catch { error in
            UIWindow.toast(error.localizedDescription)
        }
    }
    
    func getWallets() {
        DfnsManager.shared.listWallets().done { json in
          print(json)
        }.catch { error in
            
        }
    }
}
extension RegisterAccountViewController {
    
}
