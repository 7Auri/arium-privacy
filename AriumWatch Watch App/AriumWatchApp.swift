//
//  AriumWatchApp.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 22.11.2025.
//

import SwiftUI
import WatchKit

@main
struct AriumWatchApp: App {
    @WKApplicationDelegateAdaptor(ComplicationDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class ComplicationDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        // Complication controller is set up automatically
    }
}
