//
//  AppDelegate.swift
//  MTPT
//
//  Created by yan zheng on 2025/3/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    // 使用iOS 15兼容的方式设置浅色模式
    // 在iOS 15之前使用旧API，在iOS 15及之后使用新API
    if #available(iOS 15.0, *) {
      // iOS 15及以上使用新API
      for scene in UIApplication.shared.connectedScenes {
        if let windowScene = scene as? UIWindowScene {
          for window in windowScene.windows {
            window.overrideUserInterfaceStyle = .light
          }
        }
      }
    } else {
      // iOS 15以下使用旧API
      UIApplication.shared.windows.forEach { window in
        window.overrideUserInterfaceStyle = .light
      }
    }
    
    // 打印当前语言环境进行调试
    let currentLocale = Locale.current
    print("当前语言: \(currentLocale.identifier)")
    print("首选语言: \(Locale.preferredLanguages)")
    
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

