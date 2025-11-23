//
//  AriumApp.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

@main
struct AriumApp: App {
    @StateObject private var habitStore = HabitStore()
    @StateObject private var appThemeManager = AppThemeManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
                    .environmentObject(habitStore)
                    .environmentObject(appThemeManager)
                    .task {
                        // Update habits status on app launch (async, non-blocking)
                        habitStore.updateTodayStatus()
                    }
            } else {
                OnboardingView()
                    .environmentObject(habitStore)
                    .environmentObject(appThemeManager)
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh completion status when app becomes active
                habitStore.updateTodayStatus()
                
                // Clear notification badge when app becomes active
                Task {
                    await NotificationManager.shared.clearBadge()
                }
            }
        }
    }
}
