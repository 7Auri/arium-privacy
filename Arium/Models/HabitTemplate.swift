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
    let isPopular: Bool
    let isPremium: Bool
    
    static let templates: [HabitTemplate] = [
        // HEALTH & FITNESS (Popular)
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.exercise.title"),
            description: L10n.t("template.exercise.description"),
            category: .health,
            suggestedGoalDays: 30,
            icon: "figure.run",
            isPopular: true,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.water.title"),
            description: L10n.t("template.water.description"),
            category: .health,
            suggestedGoalDays: 21,
            icon: "drop.fill",
            isPopular: true,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.sleep.title"),
            description: L10n.t("template.sleep.description"),
            category: .health,
            suggestedGoalDays: 21,
            icon: "moon.fill",
            isPopular: true,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.yoga.title"),
            description: L10n.t("template.yoga.description"),
            category: .health,
            suggestedGoalDays: 30,
            icon: "figure.mind.and.body",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.walk.title"),
            description: L10n.t("template.walk.description"),
            category: .health,
            suggestedGoalDays: 30,
            icon: "figure.walk",
            isPopular: false,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.vitamins.title"),
            description: L10n.t("template.vitamins.description"),
            category: .health,
            suggestedGoalDays: 60,
            icon: "pills.fill",
            isPopular: false,
            isPremium: true
        ),
        
        // PERSONAL DEVELOPMENT (Popular)
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.meditate.title"),
            description: L10n.t("template.meditate.description"),
            category: .personal,
            suggestedGoalDays: 21,
            icon: "brain.head.profile",
            isPopular: true,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.journal.title"),
            description: L10n.t("template.journal.description"),
            category: .personal,
            suggestedGoalDays: 30,
            icon: "book.fill",
            isPopular: true,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.gratitude.title"),
            description: L10n.t("template.gratitude.description"),
            category: .personal,
            suggestedGoalDays: 30,
            icon: "heart.fill",
            isPopular: false,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.nosocial.title"),
            description: L10n.t("template.nosocial.description"),
            category: .personal,
            suggestedGoalDays: 21,
            icon: "hand.raised.fill",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.morning.title"),
            description: L10n.t("template.morning.description"),
            category: .personal,
            suggestedGoalDays: 21,
            icon: "sunrise.fill",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.affirmation.title"),
            description: L10n.t("template.affirmation.description"),
            category: .personal,
            suggestedGoalDays: 30,
            icon: "quote.bubble.fill",
            isPopular: false,
            isPremium: true
        ),
        
        // LEARNING & PRODUCTIVITY (Popular)
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.read.title"),
            description: L10n.t("template.read.description"),
            category: .learning,
            suggestedGoalDays: 30,
            icon: "book.closed.fill",
            isPopular: true,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.language.title"),
            description: L10n.t("template.language.description"),
            category: .learning,
            suggestedGoalDays: 60,
            icon: "globe",
            isPopular: false,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.code.title"),
            description: L10n.t("template.code.description"),
            category: .work,
            suggestedGoalDays: 30,
            icon: "chevron.left.forwardslash.chevron.right",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.podcast.title"),
            description: L10n.t("template.podcast.description"),
            category: .learning,
            suggestedGoalDays: 21,
            icon: "headphones",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.study.title"),
            description: L10n.t("template.study.description"),
            category: .learning,
            suggestedGoalDays: 60,
            icon: "graduationcap.fill",
            isPopular: false,
            isPremium: true
        ),
        
        // WORK & CAREER
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.noEmail.title"),
            description: L10n.t("template.noEmail.description"),
            category: .work,
            suggestedGoalDays: 14,
            icon: "envelope.badge.fill",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.deepWork.title"),
            description: L10n.t("template.deepWork.description"),
            category: .work,
            suggestedGoalDays: 30,
            icon: "brain.fill",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.networking.title"),
            description: L10n.t("template.networking.description"),
            category: .work,
            suggestedGoalDays: 60,
            icon: "person.2.fill",
            isPopular: false,
            isPremium: true
        ),
        
        // FINANCE
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.money.title"),
            description: L10n.t("template.money.description"),
            category: .finance,
            suggestedGoalDays: 90,
            icon: "banknote.fill",
            isPopular: false,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.budget.title"),
            description: L10n.t("template.budget.description"),
            category: .finance,
            suggestedGoalDays: 30,
            icon: "chart.pie.fill",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.noShopping.title"),
            description: L10n.t("template.noShopping.description"),
            category: .finance,
            suggestedGoalDays: 30,
            icon: "cart.fill.badge.minus",
            isPopular: false,
            isPremium: true
        ),
        
        // SOCIAL & RELATIONSHIPS
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.family.title"),
            description: L10n.t("template.family.description"),
            category: .social,
            suggestedGoalDays: 7,
            icon: "phone.fill",
            isPopular: false,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.friends.title"),
            description: L10n.t("template.friends.description"),
            category: .social,
            suggestedGoalDays: 14,
            icon: "person.3.fill",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.kindness.title"),
            description: L10n.t("template.kindness.description"),
            category: .social,
            suggestedGoalDays: 21,
            icon: "hand.thumbsup.fill",
            isPopular: false,
            isPremium: true
        ),
        
        // ADDITIONAL HABITS
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.clean.title"),
            description: L10n.t("template.clean.description"),
            category: .personal,
            suggestedGoalDays: 7,
            icon: "sparkles",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.noAlcohol.title"),
            description: L10n.t("template.noAlcohol.description"),
            category: .health,
            suggestedGoalDays: 30,
            icon: "wineglass",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.stretch.title"),
            description: L10n.t("template.stretch.description"),
            category: .health,
            suggestedGoalDays: 21,
            icon: "figure.flexibility",
            isPopular: false,
            isPremium: true
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.teeth.title"),
            description: L10n.t("template.teeth.description"),
            category: .health,
            suggestedGoalDays: 21,
            icon: "mouth.fill",
            isPopular: true,
            isPremium: false
        ),
        HabitTemplate(
            id: UUID(),
            title: L10n.t("template.skincare.title"),
            description: L10n.t("template.skincare.description"),
            category: .health,
            suggestedGoalDays: 30,
            icon: "face.smiling.fill",
            isPopular: false,
            isPremium: true
        ),
    ]
    
    // Filter templates by category
    static func templates(for category: HabitCategory) -> [HabitTemplate] {
        templates.filter { $0.category == category }
    }
    
    // Get popular templates
    static var popularTemplates: [HabitTemplate] {
        templates.filter { $0.isPopular }
    }
    
    // Get free templates
    static var freeTemplates: [HabitTemplate] {
        templates.filter { !$0.isPremium }
    }
    
    // Get premium templates
    static var premiumTemplates: [HabitTemplate] {
        templates.filter { $0.isPremium }
    }
}
