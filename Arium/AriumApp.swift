//
//  AriumApp.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI
import AppIntents

@main
struct AriumApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var habitStore = HabitStore()
    @StateObject private var appThemeManager = AppThemeManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var quickAction: QuickAction?
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .environmentObject(habitStore)
                    .environmentObject(appThemeManager)
                    .environmentObject(FontManager.shared)
                    .task {
                        // Prepare haptic generators for better performance
                        HapticManager.prepare()
                        
                        // Track app launch
                        AnalyticsManager.shared.trackAppLaunch()
                        
                        // Update habits status on app launch (async, non-blocking)
                        await habitStore.updateTodayStatus()
                        
                        // Setup Quick Actions
                        QuickActionManager.shared.setupQuickActions()
                        
                        // Note: iCloud sync is now manual-only for better user control and privacy
                        // Users can sync via "Sync Now" or "Load from iCloud" buttons in Settings
                    }
                    .onOpenURL { url in
                        handleQuickAction(url: url)
                    }
            } else {
                OnboardingView()
                    .environmentObject(habitStore)
                    .environmentObject(appThemeManager)
                    .environmentObject(FontManager.shared)
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh completion status when app becomes active
                Task {
                    await habitStore.updateTodayStatus()
                    await NotificationManager.shared.clearBadge()
                }
                
                // Note: iCloud sync is now manual-only for better user control and privacy
                // Users can sync via "Sync Now" or "Load from iCloud" buttons in Settings
            }
            
            // Handle memory warnings
            if newPhase == .background {
                MemoryOptimization.handleMemoryWarning()
            }
        }
    }
    
    // MARK: - Quick Action Handling
    
    private func handleQuickAction(url: URL) {
        // Handle deep links from Quick Actions
        if url.scheme == "arium" {
            switch url.host {
            case "addHabit":
                quickAction = .addHabit
            case "statistics":
                quickAction = .viewStatistics
            case "today":
                quickAction = .todayHabits
            default:
                break
            }
        }
    }
}

// MARK: - App Delegate for Remote Notifications
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        
        // Handle quick action from cold launch
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            handleShortcutItem(shortcutItem)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle silent push
        let result = CloudSyncManager.shared.handleNotification(userInfo: userInfo)
        completionHandler(result)
    }
    
    /// Handle Home Screen Quick Actions (3D Touch / Long Press)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }
    
    @discardableResult
    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(rawValue: shortcutItem.type) else { return false }
        
        // Post notification so the UI can respond
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(
                name: .quickActionTriggered,
                object: nil,
                userInfo: ["action": action.rawValue]
            )
        }
        return true
    }
}

extension Notification.Name {
    static let quickActionTriggered = Notification.Name("quickActionTriggered")
}
