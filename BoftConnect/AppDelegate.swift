//
//  AppDelegate.swift
//  BoftConnect
//
//  Created by Лекс Лютер on 20/04/2019.
//  Copyright © 2019 Лекс Лютер. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let font = UIFont(name: "Banana Yeti", size: 36) {
            let navigationBarAppearace = UINavigationBar.appearance()

            navigationBarAppearace.tintColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            navigationBarAppearace.barTintColor = UIColor(red:0.76, green:0.40, blue:0.40, alpha:1.0)
            navigationBarAppearace.setBackgroundImage(UIImage(), for: .default)
            navigationBarAppearace.isTranslucent = true

            let attributes = [
                NSAttributedString.Key.strokeColor: UIColor.black,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.strokeWidth: -1.0]
                as [NSAttributedString.Key : Any]

            navigationBarAppearace.titleTextAttributes = attributes

        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

//extension UINavigationBar {
//    open override func sizeThatFits(_ size: CGSize) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width, height: 51)
//    }
//}

