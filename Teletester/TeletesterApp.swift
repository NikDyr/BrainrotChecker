//
//  TeletesterApp.swift
//  Teletester
//
//  Created by MacBook on 18/11/2025.
//

import SwiftUI

@main
struct TeletesterApp: App {
    // AppDelegate will initialize Firebase and handle push registration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
