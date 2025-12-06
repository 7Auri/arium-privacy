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
    
    var color: Color {
        switch self {
        case .streakMaster, .consistent, .earlyBird, .weekendWarrior, .nightOwl, .moodBooster, .productiveDay, .monthlyTrendUp, .sentimentTrendUp:
            return .green
        case .needsFocus, .warning, .challengingHabit, .monthlyTrendDown, .sentimentTrendDown:
            return .orange
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
}
