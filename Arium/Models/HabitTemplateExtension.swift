//
//  HabitTemplateExtension.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation

extension HabitTemplate {
    /// Convert template to Habit
    func toHabit() -> Habit {
        Habit(
            title: self.title,
            notes: self.description,
            themeId: categoryToThemeId(category),
            goalDays: self.suggestedGoalDays,
            category: self.category,
            dailyRepetitions: self.dailyRepetitions,
            repetitionLabels: self.repetitionLabels
        )
    }
    
    /// Map category to theme ID
    private func categoryToThemeId(_ category: HabitCategory) -> String {
        switch category {
        case .health: return "red"
        case .personal: return "green"
        case .learning: return "purple"
        case .work: return "blue"
        case .finance: return "orange"
        case .social: return "pink"
        }
    }
}






