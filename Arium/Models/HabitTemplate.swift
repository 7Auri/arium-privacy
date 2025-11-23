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
            title: L10n.t("template.meditate.title"),
            description: L10n.t("template.meditate.description"),
            category: .personal,
            suggestedGoalDays: 21,
            icon: "brain.head.profile"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.exercise.title"),
            description: L10n.t("template.exercise.description"),
            category: .health,
            suggestedGoalDays: 30,
            icon: "figure.run"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.read.title"),
            description: L10n.t("template.read.description"),
            category: .learning,
            suggestedGoalDays: 30,
            icon: "book.closed.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.water.title"),
            description: L10n.t("template.water.description"),
            category: .health,
            suggestedGoalDays: 21,
            icon: "drop.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.journal.title"),
            description: L10n.t("template.journal.description"),
            category: .personal,
            suggestedGoalDays: 30,
            icon: "book.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.language.title"),
            description: L10n.t("template.language.description"),
            category: .learning,
            suggestedGoalDays: 60,
            icon: "globe"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.money.title"),
            description: L10n.t("template.money.description"),
            category: .finance,
            suggestedGoalDays: 90,
            icon: "banknote.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.family.title"),
            description: L10n.t("template.family.description"),
            category: .social,
            suggestedGoalDays: 7,
            icon: "phone.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.nosocial.title"),
            description: L10n.t("template.nosocial.description"),
            category: .personal,
            suggestedGoalDays: 21,
            icon: "hand.raised.fill"
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.gratitude.title"),
            description: L10n.t("template.gratitude.description"),
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

