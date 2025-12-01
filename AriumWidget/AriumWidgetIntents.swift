//
//  AriumWidgetIntents.swift
//  AriumWidget
//
//  Created by Zorbey on 23.11.2025.
//

import AppIntents
import WidgetKit
import Foundation

struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Habit"
    static var description = IntentDescription("Complete or uncomplete a habit")
    static var openAppWhenRun: Bool = false  // Don't open app for interactive widgets
    
    @Parameter(title: "Habit ID")
    var habitId: String
    
    init(habitId: String) {
        self.habitId = habitId
    }
    
    init() {
        self.habitId = ""
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Load habits from App Groups
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              var habits = try? CodingCache.decoder.decode([Habit].self, from: data),
              let index = habits.firstIndex(where: { $0.id.uuidString == habitId }) else {
            throw IntentError.habitNotFound
        }
        
        let habit = habits[index]
        let wasCompleted = habit.isCompletedToday
        
        // Toggle completion
        habits[index].toggleCompletion()
        habits[index].calculateStreak()
        
        // Save back to App Groups
        if let encoded = try? CodingCache.compactEncoder.encode(habits) {
            sharedDefaults.set(encoded, forKey: "SavedHabits")
        }
        
        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "AriumWidget")
        
        // Return dialog
        if wasCompleted {
            return .result(dialog: "\(habit.title) marked as incomplete")
        } else {
            return .result(dialog: "\(habit.title) completed! 🔥")
        }
    }
}

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case habitNotFound
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .habitNotFound:
            return "Habit not found"
        }
    }
}

