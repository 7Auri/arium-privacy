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
    
    @Parameter(title: "Habit ID")
    var habitId: String
    
    func perform() async throws -> some IntentResult {
        // Load habits from App Groups
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              var habits = try? CodingCache.decoder.decode([Habit].self, from: data),
              let index = habits.firstIndex(where: { $0.id.uuidString == habitId }) else {
            throw IntentError.habitNotFound
        }
        
        // Toggle completion
        habits[index].toggleCompletion()
        
        // Save back to App Groups
        if let encoded = try? CodingCache.compactEncoder.encode(habits) {
            sharedDefaults.set(encoded, forKey: "SavedHabits")
        }
        
        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "AriumWidget")
        
        return .result()
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

