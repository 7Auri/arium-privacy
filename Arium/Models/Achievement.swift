//
//  Achievement.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation
import SwiftUI

/// Achievement types
enum AchievementCategory: String, Codable, CaseIterable {
    case streak = "streak"
    case completion = "completion"
    case consistency = "consistency"
    case variety = "variety"
    case premium = "premium"
    case social = "social"
    
    var displayName: String {
        switch self {
        case .streak: return L10n.t("achievement.category.streak")
        case .completion: return L10n.t("achievement.category.completion")
        case .consistency: return L10n.t("achievement.category.consistency")
        case .variety: return L10n.t("achievement.category.variety")
        case .premium: return L10n.t("achievement.category.premium")
        case .social: return L10n.t("achievement.category.social")
        }
    }
    
    var icon: String {
        switch self {
        case .streak: return "🔥"
        case .completion: return "✅"
        case .consistency: return "📅"
        case .variety: return "🌈"
        case .premium: return "👑"
        case .social: return "👥"
        }
    }
    
    var color: Color {
        switch self {
        case .streak: return .orange
        case .completion: return .green
        case .consistency: return .blue
        case .variety: return .purple
        case .premium: return Color(hex: "#FFD700") // Gold
        case .social: return .pink
        }
    }
}

/// Achievement tier/level
enum AchievementTier: String, Codable, CaseIterable {
    case bronze = "bronze"
    case silver = "silver"
    case gold = "gold"
    case platinum = "platinum"
    case diamond = "diamond"
    
    var displayName: String {
        switch self {
        case .bronze: return L10n.t("achievement.tier.bronze")
        case .silver: return L10n.t("achievement.tier.silver")
        case .gold: return L10n.t("achievement.tier.gold")
        case .platinum: return L10n.t("achievement.tier.platinum")
        case .diamond: return L10n.t("achievement.tier.diamond")
        }
    }
    
    var color: Color {
        switch self {
        case .bronze: return Color(hex: "#CD7F32")
        case .silver: return Color(hex: "#C0C0C0")
        case .gold: return Color(hex: "#FFD700")
        case .platinum: return Color(hex: "#E5E4E2")
        case .diamond: return Color(hex: "#B9F2FF")
        }
    }
    
    var xpValue: Int {
        switch self {
        case .bronze: return 10
        case .silver: return 25
        case .gold: return 50
        case .platinum: return 100
        case .diamond: return 200
        }
    }
}

/// Achievement definition
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let category: AchievementCategory
    let tier: AchievementTier
    let targetValue: Int // Required value to unlock
    let icon: String // Emoji or SF Symbol
    let isPremium: Bool
    
    var xpReward: Int {
        tier.xpValue
    }
    
    // MARK: - Predefined Achievements
    
    static let allAchievements: [Achievement] = [
        // STREAK ACHIEVEMENTS
        Achievement(
            id: "streak_7",
            title: L10n.t("achievement.streak7.title"),
            description: L10n.t("achievement.streak7.description"),
            category: .streak,
            tier: .bronze,
            targetValue: 7,
            icon: "🔥",
            isPremium: false
        ),
        Achievement(
            id: "streak_30",
            title: L10n.t("achievement.streak30.title"),
            description: L10n.t("achievement.streak30.description"),
            category: .streak,
            tier: .silver,
            targetValue: 30,
            icon: "🔥",
            isPremium: false
        ),
        Achievement(
            id: "streak_100",
            title: L10n.t("achievement.streak100.title"),
            description: L10n.t("achievement.streak100.description"),
            category: .streak,
            tier: .gold,
            targetValue: 100,
            icon: "🔥",
            isPremium: false
        ),
        Achievement(
            id: "streak_365",
            title: L10n.t("achievement.streak365.title"),
            description: L10n.t("achievement.streak365.description"),
            category: .streak,
            tier: .platinum,
            targetValue: 365,
            icon: "🔥",
            isPremium: false
        ),
        
        // COMPLETION ACHIEVEMENTS
        Achievement(
            id: "complete_10",
            title: L10n.t("achievement.complete10.title"),
            description: L10n.t("achievement.complete10.description"),
            category: .completion,
            tier: .bronze,
            targetValue: 10,
            icon: "✅",
            isPremium: false
        ),
        Achievement(
            id: "complete_100",
            title: L10n.t("achievement.complete100.title"),
            description: L10n.t("achievement.complete100.description"),
            category: .completion,
            tier: .silver,
            targetValue: 100,
            icon: "✅",
            isPremium: false
        ),
        Achievement(
            id: "complete_500",
            title: L10n.t("achievement.complete500.title"),
            description: L10n.t("achievement.complete500.description"),
            category: .completion,
            tier: .gold,
            targetValue: 500,
            icon: "✅",
            isPremium: false
        ),
        Achievement(
            id: "complete_1000",
            title: L10n.t("achievement.complete1000.title"),
            description: L10n.t("achievement.complete1000.description"),
            category: .completion,
            tier: .platinum,
            targetValue: 1000,
            icon: "✅",
            isPremium: true
        ),
        
        // CONSISTENCY ACHIEVEMENTS
        Achievement(
            id: "perfect_week",
            title: L10n.t("achievement.perfectWeek.title"),
            description: L10n.t("achievement.perfectWeek.description"),
            category: .consistency,
            tier: .silver,
            targetValue: 1,
            icon: "📅",
            isPremium: false
        ),
        Achievement(
            id: "perfect_month",
            title: L10n.t("achievement.perfectMonth.title"),
            description: L10n.t("achievement.perfectMonth.description"),
            category: .consistency,
            tier: .gold,
            targetValue: 1,
            icon: "📅",
            isPremium: false
        ),
        
        // VARIETY ACHIEVEMENTS
        Achievement(
            id: "multi_category",
            title: L10n.t("achievement.multiCategory.title"),
            description: L10n.t("achievement.multiCategory.description"),
            category: .variety,
            tier: .silver,
            targetValue: 4,
            icon: "🌈",
            isPremium: false
        ),
        Achievement(
            id: "habit_master",
            title: L10n.t("achievement.habitMaster.title"),
            description: L10n.t("achievement.habitMaster.description"),
            category: .variety,
            tier: .platinum,
            targetValue: 10,
            icon: "🎯",
            isPremium: true
        ),
        
        // PREMIUM ACHIEVEMENTS
        Achievement(
            id: "premium_member",
            title: L10n.t("achievement.premiumMember.title"),
            description: L10n.t("achievement.premiumMember.description"),
            category: .premium,
            tier: .gold,
            targetValue: 1,
            icon: "👑",
            isPremium: true
        ),
        Achievement(
            id: "template_creator",
            title: L10n.t("achievement.templateCreator.title"),
            description: L10n.t("achievement.templateCreator.description"),
            category: .premium,
            tier: .silver,
            targetValue: 1,
            icon: "📝",
            isPremium: true
        ),
    ]
}

/// User's unlocked achievement
struct UnlockedAchievement: Identifiable, Codable {
    let id: UUID
    let achievementId: String
    let unlockedAt: Date
    var isNew: Bool // For showing "NEW" badge
    
    init(achievementId: String, unlockedAt: Date = Date(), isNew: Bool = true) {
        self.id = UUID()
        self.achievementId = achievementId
        self.unlockedAt = unlockedAt
        self.isNew = isNew
    }
}


