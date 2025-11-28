//
//  CompleteHabitIntent.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import AppIntents
import SwiftUI

/// Siri Shortcut: Complete a habit
struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Mark a habit as completed for today")
    
    @Parameter(title: "Habit Name")
    var habitName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Complete \(\.$habitName)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Load habits from App Groups
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              var habits = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            return .result(dialog: "Couldn't find any habits")
        }
        
        // Find habit by name (case insensitive)
        guard let index = habits.firstIndex(where: { 
            $0.title.localizedCaseInsensitiveContains(habitName) 
        }) else {
            return .result(dialog: "Couldn't find habit '\(habitName)'")
        }
        
        let habit = habits[index]
        
        // Check if already completed
        if habit.isCompletedToday {
            return .result(dialog: "'\(habit.title)' is already completed today!")
        }
        
        // Toggle completion
        habits[index].toggleCompletion()
        
        // Save back
        if let encoded = try? CodingCache.compactEncoder.encode(habits) {
            sharedDefaults.set(encoded, forKey: "SavedHabits")
            sharedDefaults.synchronize()
        }
        
        return .result(dialog: "Great job! '\(habit.title)' is completed for today!")
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
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
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
                "Complete my \(\.$habitName) habit in \(.applicationName)",
                "Mark \(\.$habitName) as done in \(.applicationName)",
                "Finish \(\.$habitName) in \(.applicationName)"
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

