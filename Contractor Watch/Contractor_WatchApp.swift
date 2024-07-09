//
//  Contractor_WatchApp.swift
//  Contractor Watch
//
//  Created by Edgars Yarmolatiy on 7/9/24.
//

import SwiftUI
import GoogleSignIn

@main
struct Contractor_WatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        GIDSignIn.sharedInstance.restorePreviousSignIn()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
