//
//  LiveActivityManager.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import Foundation
import ActivityKit
import SwiftUI

/// Manager for Live Activities (Dynamic Island)
@available(iOS 16.1, *)
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    @Published var currentActivity: Activity<HabitActivityAttributes>?
    
    private init() {}
    
    /// Start a Live Activity for habit tracking
    /// - Parameters:
    ///   - completedToday: Number of habits completed today
    ///   - totalHabits: Total number of habits
    ///   - currentStreak: Current longest streak
    func startActivity(completedToday: Int, totalHabits: Int, currentStreak: Int) {
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled")
            return
        }
        
        // End existing activity first
        endActivity()
        
        let attributes = HabitActivityAttributes(userName: "User")
        let contentState = HabitActivityAttributes.ContentState(
            completedToday: completedToday,
            totalHabits: totalHabits,
            currentStreak: currentStreak,
            lastUpdated: Date()
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: contentState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    /// Update the Live Activity with new data
    /// - Parameters:
    ///   - completedToday: Updated number of completed habits
    ///   - totalHabits: Updated total habits
    ///   - currentStreak: Updated streak
    func updateActivity(completedToday: Int, totalHabits: Int, currentStreak: Int) {
        guard let activity = currentActivity else {
            // If no activity exists, start one
            startActivity(completedToday: completedToday, totalHabits: totalHabits, currentStreak: currentStreak)
            return
        }
        
        let updatedState = HabitActivityAttributes.ContentState(
            completedToday: completedToday,
            totalHabits: totalHabits,
            currentStreak: currentStreak,
            lastUpdated: Date()
        )
        
        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
            print("✅ Live Activity updated")
        }
    }
    
    /// End the current Live Activity
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            // Use new API: end with content parameter
            let currentState = activity.content.state
            await activity.end(ActivityContent(state: currentState, staleDate: nil), dismissalPolicy: .immediate)
            currentActivity = nil
            print("✅ Live Activity ended")
        }
    }
    
    /// End activity after a delay
    /// - Parameter seconds: Delay in seconds before ending
    func endActivityAfterDelay(seconds: TimeInterval = 4) {
        guard let activity = currentActivity else { return }
        
        Task {
            // Use new API: end with content parameter
            let currentState = activity.content.state
            await activity.end(
                ActivityContent(state: currentState, staleDate: nil),
                dismissalPolicy: .after(.now + seconds)
            )
            currentActivity = nil
            print("✅ Live Activity will end in \(seconds) seconds")
        }
    }
}




