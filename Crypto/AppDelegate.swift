//
//  AppDelegate.swift
//  Crypto
//
//  Created by Yuki Okudera on 2021/11/13.
//

import UIKit
import DataSource

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var backgroundCompletionHandler: (() -> Void)?

    @Injected(\.applicationContainerProvider)
    private var applicationContainer: ApplicationContainerProviding

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        NotificationCenter.default.addObserver(self, selector: #selector(downloadCompleted), name: .downloadCompleted, object: nil)

        // ダウンロードファイルを保存するためのディレクトリを作成する
        applicationContainer.createDownloadDataDirectory()

        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print(#function, "identifier: \(identifier)")
        backgroundCompletionHandler = completionHandler
    }

    @objc
    private func downloadCompleted() {
        DispatchQueue.main.async { [weak self] in
            print(#function)
            self?.backgroundCompletionHandler?()
            self?.backgroundCompletionHandler = nil
        }
    }
}

// MARK: - UISceneSession Lifecycle

@available(iOS 13.0, *)
extension AppDelegate {

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
