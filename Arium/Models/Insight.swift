//
//  Insight.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI

enum InsightType {
    case streakMaster // Long streak
    case needsFocus // Low completion
    case weekendWarrior // High weekend activity
    case earlyBird // Morning completions
    case nightOwl // Night completions
    case consistent // High overall completion
    case warning // Dropping streak or other negative trend
    case moodBooster // Positive sentiment
    case challengingHabit // Negative sentiment
    case productiveDay // Best day of week
    case monthlyTrendUp // Improving vs last month
    case monthlyTrendDown // Declining vs last month
    case sentimentTrendUp // Mood improving
    case sentimentTrendDown // Mood declining
    // New insight types
    case consistencyChampion // Most consistent habit
    case comebackKid // Recovered from decline
    case timeOptimizer // Most productive time of day
    case categoryMaster // Best performing category
    case goalAchiever // Completed goal challenges
    case socialButterfly // Social habits success
    case healthHero // Health habits excellence
    case learningLeader // Learning habits mastery
    // New predictive insights
    case streakRisk // Streak kaybetme riski
    case habitChain // Alışkanlık zinciri
    case recovery // Toparlanma pattern'i
    // Measurement insights
    case measurementTrendUp // Ölçüm trendi yukarı
    case measurementTrendDown // Ölçüm trendi aşağı
    case habitMeasurementCorrelation // Alışkanlık-ölçüm korelasyonu
    // Forecasting insights (premium)
    case streakBreakForecast // 7-gün streak kırılma tahmini (Holt-Winters)
    
    var color: Color {
        switch self {
        case .streakMaster, .consistent, .earlyBird, .weekendWarrior, .nightOwl, .moodBooster, .productiveDay, .monthlyTrendUp, .sentimentTrendUp, .consistencyChampion, .comebackKid, .timeOptimizer, .categoryMaster, .goalAchiever, .socialButterfly, .healthHero, .learningLeader, .habitChain, .recovery, .measurementTrendUp:
            return .green
        case .needsFocus, .warning, .challengingHabit, .monthlyTrendDown, .sentimentTrendDown, .streakRisk, .measurementTrendDown, .streakBreakForecast:
            return .orange
        case .habitMeasurementCorrelation:
            return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .streakMaster: return "flame.fill"
        case .needsFocus: return "target"
        case .weekendWarrior: return "figure.outdoor.cycle"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .consistent: return "chart.bar.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .moodBooster: return "face.smiling.fill"
        case .challengingHabit: return "face.dashed"
        case .productiveDay: return "calendar.day.timeline.left"
        case .monthlyTrendUp: return "chart.line.uptrend.xyaxis"
        case .monthlyTrendDown: return "chart.line.downtrend.xyaxis"
        case .sentimentTrendUp: return "arrow.up.heart.fill"
        case .sentimentTrendDown: return "arrow.down.heart.fill"
        case .consistencyChampion: return "checkmark.circle.fill"
        case .comebackKid: return "arrow.clockwise.circle.fill"
        case .timeOptimizer: return "clock.fill"
        case .categoryMaster: return "star.fill"
        case .goalAchiever: return "flag.checkered"
        case .socialButterfly: return "person.2.fill"
        case .healthHero: return "heart.fill"
        case .learningLeader: return "book.fill"
        case .streakRisk: return "exclamationmark.triangle.fill"
        case .habitChain: return "link"
        case .recovery: return "arrow.up.circle.fill"
        case .measurementTrendUp: return "chart.line.uptrend.xyaxis"
        case .measurementTrendDown: return "chart.line.downtrend.xyaxis"
        case .habitMeasurementCorrelation: return "arrow.triangle.merge"
        case .streakBreakForecast: return "chart.line.downtrend.xyaxis.circle"
        }
    }
}

struct Insight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let relatedHabitId: UUID?
    let date: Date = Date()
    let suggestedActions: [InsightAction] // Actionable insights
    let confidence: Double // ML confidence score (0.0 - 1.0)
    
    init(type: InsightType, title: String, message: String, relatedHabitId: UUID? = nil, suggestedActions: [InsightAction] = [], confidence: Double = 0.8) {
        self.type = type
        self.title = title
        self.message = message
        self.relatedHabitId = relatedHabitId
        self.suggestedActions = suggestedActions
        self.confidence = confidence
    }
}

// Actionable insights - suggested actions for each insight
enum InsightAction: Identifiable {
    case focusOnHabit(UUID)
    case updateGoal(UUID)
    case setReminder(UUID)
    case adjustSchedule(UUID)
    case reviewProgress(UUID)
    case celebrateAchievement
    case tryNewApproach(UUID)
    
    var id: String {
        switch self {
        case .focusOnHabit(let id): return "focus-\(id)"
        case .updateGoal(let id): return "goal-\(id)"
        case .setReminder(let id): return "reminder-\(id)"
        case .adjustSchedule(let id): return "schedule-\(id)"
        case .reviewProgress(let id): return "review-\(id)"
        case .celebrateAchievement: return "celebrate"
        case .tryNewApproach(let id): return "approach-\(id)"
        }
    }
    
    var habitId: UUID? {
        switch self {
        case .focusOnHabit(let id), .updateGoal(let id), .setReminder(let id),
             .adjustSchedule(let id), .reviewProgress(let id), .tryNewApproach(let id):
            return id
        case .celebrateAchievement:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .focusOnHabit: return L10n.t("insight.action.focus")
        case .updateGoal: return L10n.t("insight.action.updateGoal")
        case .setReminder: return L10n.t("insight.action.setReminder")
        case .adjustSchedule: return L10n.t("insight.action.adjustSchedule")
        case .reviewProgress: return L10n.t("insight.action.reviewProgress")
        case .celebrateAchievement: return L10n.t("insight.action.celebrate")
        case .tryNewApproach: return L10n.t("insight.action.tryNewApproach")
        }
    }
    
    var icon: String {
        switch self {
        case .focusOnHabit: return "target"
        case .updateGoal: return "flag.fill"
        case .setReminder: return "bell.fill"
        case .adjustSchedule: return "calendar"
        case .reviewProgress: return "chart.bar.fill"
        case .celebrateAchievement: return "party.popper.fill"
        case .tryNewApproach: return "lightbulb.fill"
        }
    }
}
