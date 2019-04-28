//
//  AppDelegate.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 25/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow()
    let crosswordVC = CrosswordViewController()
//    let navigationVC = UINavigationController(rootViewController: crosswordVC)
    window?.rootViewController = crosswordVC
    window?.makeKeyAndVisible()
    
    return true
  }


}

