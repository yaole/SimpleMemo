//
//  AppDelegate.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    let mainController = MemoListViewController()
    let navController = UINavigationController(rootViewController: mainController)
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = UIColor.white
    window?.rootViewController = navController
    window?.makeKeyAndVisible()

    return true
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    var coredataStack = CoreDataStack()
    coredataStack.saveContext()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    var coredataStack = CoreDataStack()
    coredataStack.saveContext()
  }

}

