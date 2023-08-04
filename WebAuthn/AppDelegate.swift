//
//  AppDelegate.swift
//  WebAuthn
//
//  Created by leven on 2023/7/31.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow()
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
        return true
    }
}

