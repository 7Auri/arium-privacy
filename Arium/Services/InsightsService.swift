//
//  InsightsService.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import Foundation
import SwiftUI

class InsightsService {
    static let shared = InsightsService()
    
    private init() {}
    
    func analyze(habits: [Habit]) -> [Insight] {
        var insights: [Insight] = []
        
        // 1. Streak Master
        if let bestStreakHabit = habits.max(by: { $0.streak < $1.streak }), bestStreakHabit.streak > 7 {
            insights.append(Insight(
                type: .streakMaster,
                title: L10n.t("insights.streakMaster.title"),
                message: String(format: L10n.t("insights.streakMaster.message"), bestStreakHabit.streak, bestStreakHabit.title),
                relatedHabitId: bestStreakHabit.id
            ))
        }
        
        // 2. Needs Focus
        // Filter habits older than 7 days AND not completed today
        let activeHabits = habits.filter { $0.createdAt < Date().addingTimeInterval(-7*24*3600) && !$0.isCompletedToday }
        if let strugglingHabit = activeHabits.min(by: { calculateWeeklyRate($0) < calculateWeeklyRate($1) }) {
            let rate = calculateWeeklyRate(strugglingHabit)
            if rate < 0.5 && rate > 0 {
                insights.append(Insight(
                    type: .needsFocus,
                    title: L10n.t("insights.needsFocus.title"),
                    message: String(format: L10n.t("insights.needsFocus.message"), strugglingHabit.title),
                    relatedHabitId: strugglingHabit.id
                ))
            }
        }
        
        // 3. Time of Day Analysis
        let (isEarlyBird, isNightOwl) = analyzeTimePatterns(habits: habits)
        if isEarlyBird {
            insights.append(Insight(
                type: .earlyBird,
                title: L10n.t("insights.earlyBird.title"),
                message: L10n.t("insights.earlyBird.message"),
                relatedHabitId: nil
            ))
        } else if isNightOwl {
            insights.append(Insight(
                type: .nightOwl,
                title: L10n.t("insights.nightOwl.title"),
                message: L10n.t("insights.nightOwl.message"),
                relatedHabitId: nil
            ))
        }
        
        // 4. Weekend Warrior
        if isWeekendWarrior(habits: habits) {
            insights.append(Insight(
                type: .weekendWarrior,
                title: L10n.t("insights.weekendWarrior.title"),
                message: L10n.t("insights.weekendWarrior.message"),
                relatedHabitId: nil
            ))
        }
        
        // 5. Sentiment Analysis (Per Habit)
        for habit in habits {
            // Analyze static notes for now (or latest completion note if we prefer)
            // Ideally we'd average the last few completion notes
            let sentimentScore = SentimentAnalyzer.analyzeSentiment(for: habit.notes)
            
            if sentimentScore > 0.6 {
                insights.append(Insight(
                    type: .moodBooster,
                    title: L10n.t("insights.moodBooster.title"),
                    message: String(format: L10n.t("insights.moodBooster.message"), habit.title),
                    relatedHabitId: habit.id
                ))
            } else if sentimentScore < -0.6 {
                insights.append(Insight(
                    type: .challengingHabit,
                    title: L10n.t("insights.challenging.title"),
                    message: String(format: L10n.t("insights.challenging.message"), habit.title),
                    relatedHabitId: habit.id
                ))
            }
        }
        
        // 6. Global Producitve Day
        if let productiveDayInsight = analyzeProductiveDay(habits: habits) {
            insights.append(productiveDayInsight)
        }
        
        // 7. Monthly Trend
        if let monthlyTrendInsight = analyzeMonthlyTrend(habits: habits) {
            insights.append(monthlyTrendInsight)
        }
        
        // 8. Global Sentiment Trend
        if let sentimentTrendInsight = analyzeSentimentTrend(habits: habits) {
            insights.append(sentimentTrendInsight)
        }
        
        return insights
    }
    
    // MARK: - Helper Algorithms
    
    private func calculateWeeklyRate(_ habit: Habit) -> Double {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let completionsLastWeek = habit.completionDates.filter { $0 > oneWeekAgo }.count
        return Double(completionsLastWeek) / 7.0
    }
    
    private func analyzeTimePatterns(habits: [Habit]) -> (earlyBird: Bool, nightOwl: Bool) {
        var morningCount = 0
        var nightCount = 0
        var totalCount = 0
        
        let calendar = Calendar.current
        
        for habit in habits {
            // Analyze last 30 completions
            let recentCompletions = habit.completionDates.sorted(by: >).prefix(30)
            
            for date in recentCompletions {
                let hour = calendar.component(.hour, from: date)
                if hour >= 5 && hour < 10 { // 05:00 - 10:00
                    morningCount += 1
                } else if hour >= 22 || hour < 2 { // 22:00 - 02:00
                    nightCount += 1
                }
                totalCount += 1
            }
        }
        
        guard totalCount > 10 else { return (false, false) }
        
        let isEarlyBird = Double(morningCount) / Double(totalCount) > 0.4
        let isNightOwl = Double(nightCount) / Double(totalCount) > 0.4
        
        return (isEarlyBird, isNightOwl)
    }
    
    private func isWeekendWarrior(habits: [Habit]) -> Bool {
        var weekendCount = 0
        var totalCount = 0
        let calendar = Calendar.current
        
        for habit in habits {
            let recentCompletions = habit.completionDates.sorted(by: >).prefix(30)
            for date in recentCompletions {
                if calendar.isDateInWeekend(date) {
                    weekendCount += 1
                }
                totalCount += 1
            }
        }
        
        guard totalCount > 10 else { return false }
        
        return Double(weekendCount) / Double(totalCount) > 0.5
    }
    
    private func analyzeProductiveDay(habits: [Habit]) -> Insight? {
        let calendar = Calendar.current
        var weekdayCounts = [Int: Int]() // 1 (Sun) to 7 (Sat)
        
        for habit in habits {
            // Only consider recent history (e.g., last 3 months) to be relevant
            let recentCompletions = habit.completionDates.filter {
                $0 > calendar.date(byAdding: .month, value: -3, to: Date())!
            }
            
            for date in recentCompletions {
                let weekday = calendar.component(.weekday, from: date)
                weekdayCounts[weekday, default: 0] += 1
            }
        }
        
        guard let (bestWeekday, count) = weekdayCounts.max(by: { $0.value < $1.value }), count > 5 else {
            return nil
        }
        
        let weekdaySymbols = calendar.weekdaySymbols
        let dayName = weekdaySymbols[bestWeekday - 1] // 0-indexed array, weekday is 1-indexed
        
        return Insight(
            type: .productiveDay,
            title: String(format: L10n.t("insights.productiveDay.title"), dayName),
            message: String(format: L10n.t("insights.productiveDay.message"), dayName),
            relatedHabitId: nil
        )
    }
    
    private func analyzeMonthlyTrend(habits: [Habit]) -> Insight? {
        let calendar = Calendar.current
        let now = Date()
        
        // Define ranges
        // Current Month: 1st day of month to now
        // Previous Month: 1st day of prev month to last day of prev month
        
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let prevMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart)!
        // To compare fairly, maybe compare "Same number of days in prev month" vs "Days so far in current"?
        // Or just raw counts? Comparing partial month vs full month is unfair.
        // Let's compare "Last 30 days" vs "30-60 days ago".
        
        let last30DaysStart = calendar.date(byAdding: .day, value: -30, to: now)!
        let prev30DaysStart = calendar.date(byAdding: .day, value: -60, to: now)!
        
        var countLast30 = 0
        var countPrev30 = 0
        
        for habit in habits {
            for date in habit.completionDates {
                if date >= last30DaysStart {
                    countLast30 += 1
                } else if date >= prev30DaysStart && date < last30DaysStart {
                    countPrev30 += 1
                }
            }
        }
        
        guard countPrev30 > 5 else { return nil } // Need baseline
        
        let percentChange = Double(countLast30 - countPrev30) / Double(countPrev30) * 100.0
        
        if percentChange >= 20 { // 20% increase
            return Insight(
                type: .monthlyTrendUp,
                title: L10n.t("insights.monthlyTrend.up.title"),
                message: String(format: L10n.t("insights.monthlyTrend.up.message"), Int(percentChange)),
                relatedHabitId: nil
            )
        } else if percentChange <= -20 { // 20% decrease
            return Insight(
                type: .monthlyTrendDown,
                title: L10n.t("insights.monthlyTrend.down.title"),
                message: String(format: L10n.t("insights.monthlyTrend.down.message"), Int(abs(percentChange))),
                relatedHabitId: nil
            )
        }
        
        return nil
    }
    
    private func analyzeSentimentTrend(habits: [Habit]) -> Insight? {
        // Collect all daily notes
        var allNotes: [String] = []
        
        // We really want to analyze recent notes specifically
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        // Date formatter to parse keys if needed, OR we iterate habits and use completions logic?
        // Habit.completionNotes uses string keys.
        // Let's assume keys are sortable strings "yyyy-MM-dd".
        // Filter keys > oneMonthAgoString?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let limitKey = dateFormatter.string(from: oneMonthAgo)
        
        for habit in habits {
            for (dateKey, note) in habit.completionNotes {
                if dateKey >= limitKey && !note.isEmpty {
                    allNotes.append(note)
                }
            }
        }
        
        guard allNotes.count >= 3 else { return nil } // Need some data
        
        // Average sentiment
        let totalScore = allNotes.reduce(0.0) { $0 + SentimentAnalyzer.analyzeSentiment(for: $1) }
        let averageScore = totalScore / Double(allNotes.count)
        
        if averageScore > 0.4 {
            return Insight(
                type: .sentimentTrendUp,
                title: L10n.t("insights.sentimentTrend.positive.title"),
                message: L10n.t("insights.sentimentTrend.positive.message"),
                relatedHabitId: nil
            )
        } else if averageScore < -0.3 {
            return Insight(
                type: .sentimentTrendDown,
                title: L10n.t("insights.sentimentTrend.negative.title"),
                message: L10n.t("insights.sentimentTrend.negative.message"),
                relatedHabitId: nil
            )
        }
        
        return nil
    }
}
