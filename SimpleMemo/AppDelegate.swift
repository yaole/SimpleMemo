//
//  AppDelegate.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import UIKit
import CoreData
import EvernoteSDK
import SMKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    let mainController = MemoListViewController()
    navigationController = UINavigationController(rootViewController: mainController)
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = UIColor.white
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    loadDefaultMemos()

    let evernoteKey = "xxxx"
    let evernoteSecret = "xxxxxx"
    // Need a `EvernoteKey.swift` file, and init `evernoteKey` and `evernoteSecret`.
    ENSession.setSharedSessionConsumerKey(evernoteKey, consumerSecret: evernoteSecret, optionalHost: nil)

    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: SMColor.title]

    return true
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    let didHandle = ENSession.shared.handleOpenURL(url)
    return didHandle
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    CoreDataStack.default.saveContext()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    CoreDataStack.default.saveContext()
  }

  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    var handle = false
    if let _ = shortcutItem.localizedTitle as String? {
      handle = true
      let memoVC =  MemoViewController()
      navigationController?.pushViewController(memoVC, animated: true)
    }
    completionHandler(handle)
  }

}

private extension AppDelegate {

  func loadDefaultMemos() {
    let oldVersion = UserDefaults.standard.object(forKey: "MemoVersion") as? String
    if oldVersion != nil {
      return
    }

    let dict = Bundle.main.infoDictionary!
    if let version = dict["CFBundleShortVersionString"] as? String {
      UserDefaults.standard.set(version, forKey: "MemoVersion")
    }
    guard let path = Bundle.main.path(forResource: "DefaultMemos", ofType: "plist"),
      let memos = NSArray(contentsOfFile: path) as? [String] else {
      return
    }

    for memoText in memos {
      let memo = Memo.newMemo()
      memo.text = memoText
      CoreDataStack.default.saveContext()
    }
  }

}
