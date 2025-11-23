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
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
                    .environmentObject(habitStore)
                    .onAppear {
                        // Update habits status on app launch
                        habitStore.updateTodayStatus()
                    }
            } else {
                OnboardingView()
                    .environmentObject(habitStore)
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
