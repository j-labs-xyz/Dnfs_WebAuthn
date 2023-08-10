//
//  AddWalletViewController.swift
//  WebAuthn
//
//  Created by leven on 2023/8/10.
//

import Foundation
import UIKit
class AddWalletViewController: BaseViewController {
    
    lazy var netInput: UITextField = {
        let input = UITextField()
        input.font = UIFont.systemFont(ofSize: 16.scale)
        input.borderStyle = .roundedRect
        input.attributedPlaceholder = NSAttributedString(string: "Input network", attributes: [.font: UIFont.systemFont(ofSize: 16.scale), .foregroundColor: UIColor(hexString: "#AAAAAA")!])
        input.backgroundColor = UIColor(hexString: "#EEEEEE")
        return input
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Wallet"
        self.netInput.addedOn(self.view).snp.makeConstraints { make in
            make.left.equalTo(20.scale)
            make.right.equalTo(-20.scale)
            make.top.equalTo(gg_navigationBar.snp.bottom).offset(30.scale)
            make.height.equalTo(48.scale)
        }
        
        self.confirmButton.addedOn(self.view).snp.makeConstraints { make in
            make.left.equalTo(20.scale)
            make.centerX.height.equalTo(netInput)
            make.bottom.equalTo(-50.scale)
        }
        
    }
    
    @objc func clickconfirm() {
        guard let net = self.netInput.text, net.trimmed().count > 0 else {
            UIWindow.toast("please input network")
            return
        }
        
        UIWindow.showLoading()
        DfnsManager.shared.createWallet(net: "EthereumSepolia").done { json in
            UIWindow.toast("Succeed!")
            self.navigationController?.popViewController(animated: true)
        }.ensure {
            UIWindow.hideLoading()
        }.catch { err in
            UIWindow.toast(err.localizedDescription)
        }
        
        
    }
    
}

