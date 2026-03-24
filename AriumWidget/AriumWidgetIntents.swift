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
        var responseText = ""
        
        if habit.dailyRepetitions > 1 {
            // Multi-repetition logic
            if habit.isFullyCompletedToday {
                // Undo last repetition
                if let lastIndex = habit.todayCompletions.max() {
                    habits[index].toggleRepetitionCompletion(at: lastIndex)
                    responseText = "\(habit.title) progress updated"
                }
            } else {
                // Complete next available repetition
                for i in 0..<habit.dailyRepetitions {
                    if !habit.todayCompletions.contains(i) {
                        habits[index].toggleRepetitionCompletion(at: i)
                        let newCount = habits[index].todayCompletions.count
                        responseText = "\(habit.title) (\(newCount)/\(habit.dailyRepetitions))"
                        break
                    }
                }
            }
        } else {
            // Single repetition logic
            let wasCompleted = habit.isCompletedToday
            habits[index].toggleCompletion()
            
            if wasCompleted {
                responseText = "\(habit.title) marked as incomplete"
            } else {
                responseText = "\(habit.title) completed! 🔥"
            }
        }
        
        // Recalculate streaks and save
        habits[index].calculateStreak()
        
        if let encoded = try? CodingCache.compactEncoder.encode(habits) {
            sharedDefaults.set(encoded, forKey: "SavedHabits")
        }
        
        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "AriumWidget")
        
        return .result(dialog: IntentDialog(stringLiteral: responseText))
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

