//
//  CompleteHabitIntent.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import AppIntents
import SwiftUI
import Foundation

/// Siri Shortcut: Complete a habit (opens app)
struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Open Arium to complete a habit")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Load habits to show count
        guard let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let habits = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            return .result(dialog: "Opening Arium...")
        }
        
        let remaining = habits.filter { !$0.isCompletedToday }.count
        
        if remaining == 0 {
            return .result(dialog: "All habits completed! Opening Arium...")
        } else {
            return .result(dialog: "You have \(remaining) habit\(remaining == 1 ? "" : "s") left today. Opening Arium...")
        }
    }
}

/// Siri Shortcut: Show today's habits
struct ShowTodayHabitsIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Today's Habits"
    static var description = IntentDescription("See your habits for today")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Load habits
        guard let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let habits = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            return .result(dialog: "No habits found")
        }
        
        let completed = habits.filter { $0.isCompletedToday }.count
        let total = habits.count
        
        if completed == total {
            return .result(dialog: "Amazing! You've completed all \(total) habits today!")
        } else {
            return .result(dialog: "You've completed \(completed) out of \(total) habits today")
        }
    }
}

/// App Shortcuts Provider
struct AriumShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CompleteHabitIntent(),
            phrases: [
                "Complete a habit in \(.applicationName)",
                "Mark habit as done in \(.applicationName)",
                "Finish my habit in \(.applicationName)"
            ],
            shortTitle: "Complete Habit",
            systemImageName: "checkmark.circle.fill"
        )
        
        AppShortcut(
            intent: ShowTodayHabitsIntent(),
            phrases: [
                "Show my habits in \(.applicationName)",
                "Check my progress in \(.applicationName)",
                "How am I doing in \(.applicationName)"
            ],
            shortTitle: "Show Habits",
            systemImageName: "list.bullet"
        )
    }
}

