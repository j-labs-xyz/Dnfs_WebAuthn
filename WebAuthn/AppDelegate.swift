//
//  AppDelegate.swift
//  WebAuthn
//
//  Created by leven on 2023/7/31.
//

import UIKit


var appDelegate: AppDelegate!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        appDelegate = self
        ThirdSDK.setup()
        self.window = UIWindow()
        if let name = UserDefaults.standard.value(forKey: "user_name") as? String {
            self.window?.rootViewController = UINavigationController(rootViewController: AccountViewController(username: name))
        } else {
            self.window?.rootViewController = RegisterAccountViewController()
        }
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func gotoLogin() {
        UserDefaults.standard.removeObject(forKey: "user_name")
        let window = UIApplication.shared.keyWindow!
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            window.rootViewController = RegisterAccountViewController()
            UIView.setAnimationsEnabled(oldState)
        })
    }
    
    
}

