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
    @StateObject private var habitStore = HabitStore()
    @StateObject private var appThemeManager = AppThemeManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var quickAction: QuickAction?
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
                    .environmentObject(habitStore)
                    .environmentObject(appThemeManager)
                    .task {
                        // Update habits status on app launch (async, non-blocking)
                        habitStore.updateTodayStatus()
                        
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
