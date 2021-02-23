//
//  AppDelegate.swift
//  TBux
//
//  Created by Pavle Mijatovic on 09/02/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setRootVC()
        return true
    }

    private func setRootVC() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: UIStoryboard.startScreenVC)
    }
}
