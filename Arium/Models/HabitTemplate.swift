//
//  HabitTemplate.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import Foundation

struct HabitTemplate: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: HabitCategory
    let suggestedGoalDays: Int
    let icon: String
    
    static let templates: [HabitTemplate] = [
        HabitTemplate(
            id: UUID(),
            title: "Meditate",
            description: "Daily meditation practice",
            category: .personal,
            suggestedGoalDays: 21,
            icon: "brain.head.profile"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Exercise",
            description: "Physical activity or workout",
            category: .health,
            suggestedGoalDays: 30,
            icon: "figure.run"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Read Books",
            description: "Read for at least 20 minutes",
            category: .learning,
            suggestedGoalDays: 30,
            icon: "book.closed.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Drink Water",
            description: "Drink 8 glasses of water",
            category: .health,
            suggestedGoalDays: 21,
            icon: "drop.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Journal",
            description: "Write in your journal",
            category: .personal,
            suggestedGoalDays: 30,
            icon: "book.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Learn Language",
            description: "Practice a new language",
            category: .learning,
            suggestedGoalDays: 60,
            icon: "globe"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Save Money",
            description: "Save a fixed amount daily",
            category: .finance,
            suggestedGoalDays: 90,
            icon: "banknote.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Call Family",
            description: "Call a family member",
            category: .social,
            suggestedGoalDays: 7,
            icon: "phone.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: "No Social Media",
            description: "Avoid social media before bed",
            category: .personal,
            suggestedGoalDays: 21,
            icon: "hand.raised.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: "Gratitude",
            description: "Write 3 things you're grateful for",
            category: .personal,
            suggestedGoalDays: 30,
            icon: "heart.fill"
        )
    ]
    
    func toHabit() -> Habit {
        Habit(
            title: self.title,
            notes: self.description,
            themeId: categoryToThemeId(category),
            goalDays: self.suggestedGoalDays,
            category: self.category
        )
    }
    
    private func categoryToThemeId(_ category: HabitCategory) -> String {
        switch category {
        case .work: return "blue"
        case .health: return "green"
        case .learning: return "purple"
        case .personal: return "pink"
        case .finance: return "orange"
        case .social: return "purple"
        }
    }
}

