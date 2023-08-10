//
//  AccountViewController.swift
//  WebAuthn
//
//  Created by leven on 2023/8/10.
//

import Foundation
import UIKit
import Reusable
import SwiftyJSON
import PromiseKit
class AccountViewController: BaseTableViewController {
    
    lazy var userHeaderView = AccountHeaderView()
    
    var wallets: [JSON] = []
    
    var isLogin: Bool = false
    let username: String
    
    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarType = .hidden
        self.tableView.register(cellType: WalletCell.self)
        self.userHeaderView.nameLabel.text = self.username
        self.userHeaderView.frame = CGRect(x: 0, y: 0, width: 375.scale, height: 140.scale)
        self.tableView.tableHeaderView = self.userHeaderView
        self.tableView.backgroundColor = UIColor(hexString: "#F7F7F7")
        self.userHeaderView.logoutLabel.addTap { [weak self] in
            guard let self = self else { return }
            self.appDelegate.gotoLogin()
        }
        
        self.login().done { [weak self] _ in
            guard let self = self else { return }
            self.loadWallets()
            self.isLogin = true
        }.catch { error in
            UIWindow.toast(error.localizedDescription)
        }
    }
    
    func login() -> Promise<JSON> {
        return DfnsManager.shared.signIn(username: username)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isLogin  {
            self.loadWallets()
        }
    }
    func loadWallets() {
        DfnsManager.shared.listWallets().done { [weak self]json in
            guard let self = self else { return }
            self.wallets = json["items"].arrayValue
            self.tableView.reloadData()
        }.catch { error in
            UIWindow.toast(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.scale
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType:  WalletCell.self)
        let data = self.wallets[indexPath.row]
        cell.idLabel.text = "ID: " + data["id"].stringValue
        cell.netLabel.text = "Network: " + data["network"].stringValue
        cell.addressLabel.text = "Address: " +  data["address"].stringValue
        cell.timeLabel.text = "Date: " +  data["dateCreated"].stringValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .white
        let label = UILabel(16.scale, weight: .medium, textColor: UIColor.color_151515, text: "Wallets")
        label.addedOn(v).snp.makeConstraints { make in
            make.left.equalTo(14.scale)
            make.top.equalTo(12.scale)
        }
        let createLabel = UILabel(16.scale, weight: .medium, textColor: UIColor.white, text: "Create")
        createLabel.textAlignment  = .center
        createLabel.backgroundColor = UIColor.color_333333
        createLabel.layer.cornerRadius = 4
        createLabel.layer.masksToBounds = true
        createLabel.addedOn(v).snp.makeConstraints { make in
            make.right.equalTo(-14.scale)
            make.top.equalTo(10.scale)
            make.width.equalTo(60.scale)
            make.height.equalTo(30.scale)
        }
        createLabel.addTap { [weak self] in
            guard let self = self else { return }
            let vc = AddWalletViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let lineV = UIView()
        lineV.backgroundColor = UIColor(hexString: "#F7F7F7")
        lineV.addedOn(v).snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(10.scale)
        }
        return v
    }
}

extension AccountViewController {
    class AccountHeaderView : BaseView {
        lazy var nameLabel = UILabel(24.scale, weight: .semibold, textColor: UIColor.black, text: "--")
        
        lazy var logoutLabel = UILabel(16.scale, weight: .regular, textColor: UIColor(hexString: "#666666"), text: "Logout")
        override func setupUI() {
            super.setupUI()
            self.backgroundColor = .white
            nameLabel.addedOn(self).snp.makeConstraints { make in
                make.left.equalTo(14.scale)
                make.centerY.equalToSuperview()
            }
            logoutLabel.textAlignment = .right
            logoutLabel.addedOn(self).snp.makeConstraints { make in
                make.right.equalTo(-14.scale)
                make.top.equalTo(20.scale)
                make.width.equalTo(80.scale)
                make.height.equalTo(40.scale)
            }
        }
    }
}

extension AccountViewController {
    
    class WalletCell: BaseTableViewCell, Reusable {
        
        lazy var idLabel = UILabel(16.scale, weight: .medium, textColor: UIColor.color_333333)
        
        lazy var netLabel = UILabel(16.scale, weight: .medium, textColor: UIColor.color_333333)

        lazy var addressLabel = UILabel(16.scale, weight: .medium, textColor: UIColor.color_333333)

        lazy var timeLabel = UILabel(16.scale, weight: .regular, textColor: UIColor.color_333333)

        override func createUI() {
            super.createUI()
            
            idLabel.addedOn(self.contentView).snp.makeConstraints { make in
                make.left.equalTo(14.scale)
                make.top.equalTo(10.scale)
                make.centerX.equalToSuperview()
            }
            
            netLabel.addedOn(self.contentView).snp.makeConstraints { make in
                make.left.equalTo(14.scale)
                make.top.equalTo(idLabel.snp.bottom).offset(10.scale)
                make.centerX.equalToSuperview()
            }
            
            addressLabel.addedOn(self.contentView).snp.makeConstraints { make in
                make.left.equalTo(14.scale)
                make.top.equalTo(netLabel.snp.bottom).offset(10.scale)
                make.centerX.equalToSuperview()
            }
            
            timeLabel.addedOn(self.contentView).snp.makeConstraints { make in
                make.left.equalTo(14.scale)
                make.top.equalTo(addressLabel.snp.bottom).offset(10.scale)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-10.scale)
            }
            
            let lineV = UIView()
            lineV.backgroundColor = UIColor(hexString: "EAEAEA")
            lineV.addedOn(self.contentView).snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }
    }
}
