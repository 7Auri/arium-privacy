//
//  InsightsService.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import Foundation
import SwiftUI
import CoreML

class InsightsService {
    static let shared = InsightsService()
    
    private init() {}
    
    // Cache for insights to avoid redundant calculations
    private var cachedInsights: [Insight] = []
    private var lastAnalysisDate: Date?
    private var lastHabitsHash: Int = 0
    
    // Cache duration in seconds (default: 5 minutes, configurable)
    @AppStorage("insightsCacheDuration") private var cacheDuration: TimeInterval = 300
    
    // ML Predictor (will be initialized lazily)
    private var mlPredictor: HabitMLPredictor?
    
    /// Analyzes habits asynchronously and returns insights. Results are cached for performance.
    func analyze(habits: [Habit]) async -> [Insight] {
        // Quick check: if habits haven't changed and cache is recent, return cached
        let habitsHash = habits.map { $0.id }.hashValue
        if let lastDate = lastAnalysisDate,
           habitsHash == lastHabitsHash,
           Date().timeIntervalSince(lastDate) < cacheDuration {
            return cachedInsights
        }
        
        // Perform analysis in parallel using TaskGroup for better performance
        return await withTaskGroup(of: Insight?.self) { group in
            var insights: [Insight] = []
            
            // 1. Streak Master
            group.addTask {
                await self.analyzeStreakMaster(habits: habits)
            }
            
            // 2. Needs Focus
            group.addTask {
                await self.analyzeNeedsFocus(habits: habits)
            }
            
            // 3. Time Patterns
            group.addTask {
                self.analyzeTimePatterns(habits: habits)
            }

            // 4. Weekend Warrior
            group.addTask {
                self.analyzeWeekendWarrior(habits: habits)
            }
            
            // 5. Productive Day (Sentiment analysis is handled separately below)
            group.addTask {
                self.analyzeProductiveDay(habits: habits)
            }
            
            // 7. Monthly Trend
            group.addTask {
                await self.analyzeMonthlyTrend(habits: habits)
            }
            
            // 8. Sentiment Trend
            group.addTask {
                await self.analyzeSentimentTrend(habits: habits)
            }
            
            // 9. New Insight Types
            group.addTask {
                await self.analyzeConsistencyChampion(habits: habits)
            }
            
            group.addTask {
                await self.analyzeComebackKid(habits: habits)
            }
            
            group.addTask {
                self.analyzeTimeOptimizer(habits: habits)
            }
            
            group.addTask {
                self.analyzeCategoryMaster(habits: habits)
            }
            
            group.addTask {
                await self.analyzeGoalAchiever(habits: habits)
            }
            
            group.addTask {
                self.analyzeSocialButterfly(habits: habits)
            }
            
            group.addTask {
                self.analyzeHealthHero(habits: habits)
            }
            
            group.addTask {
                self.analyzeLearningLeader(habits: habits)
            }
            
            // Collect results
            for await insight in group {
                if let insight = insight {
                    insights.append(insight)
                }
            }
            
            // Also add sentiment insights (they return multiple)
            let sentimentInsights = await analyzeSentiment(habits: habits)
            insights.append(contentsOf: sentimentInsights)
            
            // Remove duplicates (same type and same habit)
            insights = removeDuplicates(insights)
            
            // Sort insights by priority
            insights = prioritizeInsights(insights)
            
            // Update cache
            cachedInsights = insights
            lastAnalysisDate = Date()
            lastHabitsHash = habitsHash
            
            return insights
        }
    }
    
    // MARK: - Individual Analysis Functions (Async)
    
    private func analyzeStreakMaster(habits: [Habit]) async -> Insight? {
        guard let bestStreakHabit = habits.max(by: { $0.streak < $1.streak }), bestStreakHabit.streak > 7 else {
            return nil
        }
        
        let mlConfidence = await getMLConfidence(for: .streakMaster, habit: bestStreakHabit)
        
        return Insight(
            type: .streakMaster,
            title: L10n.t("insights.streakMaster.title"),
            message: String(format: L10n.t("insights.streakMaster.message"), bestStreakHabit.streak, bestStreakHabit.title),
            relatedHabitId: bestStreakHabit.id,
            suggestedActions: [
                .celebrateAchievement,
                .reviewProgress(bestStreakHabit.id)
            ],
            confidence: mlConfidence
        )
    }
    
    private func analyzeNeedsFocus(habits: [Habit]) async -> Insight? {
        let activeHabits = habits.filter { $0.createdAt < Date().addingTimeInterval(-7*24*3600) && !$0.isCompletedToday }
        guard let strugglingHabit = activeHabits.min(by: { calculateWeeklyRate($0) < calculateWeeklyRate($1) }) else {
            return nil
        }
        
        let rate = calculateWeeklyRate(strugglingHabit)
        guard rate < 0.5 && rate > 0 else { return nil }
        
        let mlConfidence = await getMLConfidence(for: .needsFocus, habit: strugglingHabit)
        
        return Insight(
            type: .needsFocus,
            title: L10n.t("insights.needsFocus.title"),
            message: String(format: L10n.t("insights.needsFocus.message"), strugglingHabit.title),
            relatedHabitId: strugglingHabit.id,
            suggestedActions: [
                .focusOnHabit(strugglingHabit.id),
                .setReminder(strugglingHabit.id),
                .tryNewApproach(strugglingHabit.id)
            ],
            confidence: mlConfidence
        )
    }
    
    private func analyzeTimePatterns(habits: [Habit]) -> Insight? {
        let (isEarlyBird, isNightOwl) = analyzeTimePatternsSync(habits: habits)
        
        if isEarlyBird {
            return Insight(
                type: .earlyBird,
                title: L10n.t("insights.earlyBird.title"),
                message: L10n.t("insights.earlyBird.message"),
                relatedHabitId: nil,
                suggestedActions: [.adjustSchedule(UUID())], // Will use most active habit in UI
                confidence: 0.75
            )
        } else if isNightOwl {
            return Insight(
                type: .nightOwl,
                title: L10n.t("insights.nightOwl.title"),
                message: L10n.t("insights.nightOwl.message"),
                relatedHabitId: nil,
                suggestedActions: [.adjustSchedule(UUID())], // Will use most active habit in UI
                confidence: 0.75
            )
        }
        
        return nil
    }
    
    private func analyzeWeekendWarrior(habits: [Habit]) -> Insight? {
        guard isWeekendWarriorSync(habits: habits) else { return nil }
        
        return Insight(
            type: .weekendWarrior,
            title: L10n.t("insights.weekendWarrior.title"),
            message: L10n.t("insights.weekendWarrior.message"),
            relatedHabitId: nil,
            suggestedActions: [.celebrateAchievement],
            confidence: 0.7
        )
    }
    
    private func analyzeSentiment(habits: [Habit]) async -> [Insight] {
        var insights: [Insight] = []
        
        for habit in habits {
            // Combine habit notes with recent completion notes
            var allNotes: [String] = []
            
            if !habit.notes.isEmpty {
                allNotes.append(habit.notes)
            }
            
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let limitKey = dateFormatter.string(from: sevenDaysAgo)
            
            let recentNotes = habit.completionNotes
                .filter { $0.key >= limitKey && !$0.value.isEmpty }
                .map { $0.value }
            
            allNotes.append(contentsOf: recentNotes)
            
            let sentimentScore: Double
            if allNotes.isEmpty {
                sentimentScore = 0.0
            } else if recentNotes.isEmpty {
                sentimentScore = SentimentAnalyzer.analyzeSentiment(for: habit.notes)
            } else {
                let mainScore = SentimentAnalyzer.analyzeSentiment(for: habit.notes)
                let recentScore = SentimentAnalyzer.averageSentiment(for: recentNotes)
                sentimentScore = (mainScore * 0.3) + (recentScore * 0.7)
            }
            
            let mlConfidence = await getMLConfidence(for: sentimentScore > 0.6 ? .moodBooster : .challengingHabit, habit: habit)
            
            if sentimentScore > 0.6 {
                insights.append(Insight(
                    type: .moodBooster,
                    title: L10n.t("insights.moodBooster.title"),
                    message: String(format: L10n.t("insights.moodBooster.message"), habit.title),
                    relatedHabitId: habit.id,
                    suggestedActions: [.celebrateAchievement, .reviewProgress(habit.id)],
                    confidence: mlConfidence
                ))
            } else if sentimentScore < -0.6 {
                insights.append(Insight(
                    type: .challengingHabit,
                    title: L10n.t("insights.challenging.title"),
                    message: String(format: L10n.t("insights.challenging.message"), habit.title),
                    relatedHabitId: habit.id,
                    suggestedActions: [
                        .focusOnHabit(habit.id),
                        .tryNewApproach(habit.id),
                        .updateGoal(habit.id)
                    ],
                    confidence: mlConfidence
                ))
            }
        }
        
        return insights
    }
    
    private func analyzeProductiveDay(habits: [Habit]) -> Insight? {
        let calendar = Calendar.current
        var weekdayCounts = [Int: Int]()
        
        for habit in habits {
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
        let dayName = weekdaySymbols[bestWeekday - 1]
        
        return Insight(
            type: .productiveDay,
            title: String(format: L10n.t("insights.productiveDay.title"), dayName),
            message: String(format: L10n.t("insights.productiveDay.message"), dayName),
            relatedHabitId: nil,
            suggestedActions: [.adjustSchedule(UUID())],
            confidence: 0.7
        )
    }
    
    private func analyzeMonthlyTrend(habits: [Habit]) async -> Insight? {
        let calendar = Calendar.current
        let now = Date()
        
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
        
        guard countPrev30 > 5 else { return nil }
        
        let percentChange = Double(countLast30 - countPrev30) / Double(countPrev30) * 100.0
        
        if percentChange >= 20 {
            return Insight(
                type: .monthlyTrendUp,
                title: L10n.t("insights.monthlyTrend.up.title"),
                message: String(format: L10n.t("insights.monthlyTrend.up.message"), Int(percentChange)),
                relatedHabitId: nil,
                suggestedActions: [.celebrateAchievement],
                confidence: 0.8
            )
        } else if percentChange <= -20 {
            return Insight(
                type: .monthlyTrendDown,
                title: L10n.t("insights.monthlyTrend.down.title"),
                message: String(format: L10n.t("insights.monthlyTrend.down.message"), Int(abs(percentChange))),
                relatedHabitId: nil,
                suggestedActions: [.reviewProgress(UUID())],
                confidence: 0.8
            )
        }
        
        return nil
    }
    
    private func analyzeSentimentTrend(habits: [Habit]) async -> Insight? {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let limitKey = dateFormatter.string(from: oneMonthAgo)
        
        var allNotes: [String] = []
        
        for habit in habits {
            for (dateKey, note) in habit.completionNotes {
                if dateKey >= limitKey && !note.isEmpty {
                    allNotes.append(note)
                }
            }
        }
        
        guard allNotes.count >= 3 else { return nil }
        
        let totalScore = allNotes.reduce(0.0) { $0 + SentimentAnalyzer.analyzeSentiment(for: $1) }
        let averageScore = totalScore / Double(allNotes.count)
        
        if averageScore > 0.4 {
            return Insight(
                type: .sentimentTrendUp,
                title: L10n.t("insights.sentimentTrend.positive.title"),
                message: L10n.t("insights.sentimentTrend.positive.message"),
                relatedHabitId: nil,
                suggestedActions: [.celebrateAchievement],
                confidence: 0.75
            )
        } else if averageScore < -0.3 {
            return Insight(
                type: .sentimentTrendDown,
                title: L10n.t("insights.sentimentTrend.negative.title"),
                message: L10n.t("insights.sentimentTrend.negative.message"),
                relatedHabitId: nil,
                suggestedActions: [.reviewProgress(UUID())],
                confidence: 0.75
            )
        }
        
        return nil
    }
    
    // MARK: - New Insight Types
    
    private func analyzeConsistencyChampion(habits: [Habit]) async -> Insight? {
        guard !habits.isEmpty else { return nil }
        
        var bestHabit: Habit?
        var bestRate: Double = 0.0
        
        for habit in habits {
            let rate = calculateConsistencyRate(habit)
            if rate > bestRate {
                bestRate = rate
                bestHabit = habit
            }
        }
        
        guard let habit = bestHabit, bestRate > 0.8 else { return nil }
        
        let mlConfidence = await getMLConfidence(for: .consistencyChampion, habit: habit)
        
        return Insight(
            type: .consistencyChampion,
            title: L10n.t("insights.consistencyChampion.title"),
            message: String(format: L10n.t("insights.consistencyChampion.message"), habit.title, bestRate * 100),
            relatedHabitId: habit.id,
            suggestedActions: [.celebrateAchievement, .reviewProgress(habit.id)],
            confidence: mlConfidence
        )
    }
    
    private func analyzeComebackKid(habits: [Habit]) async -> Insight? {
        for habit in habits {
            // Check if habit had a decline and then recovered
            let calendar = Calendar.current
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
            let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: Date())!
            
            let recent30 = habit.completionDates.filter { $0 > thirtyDaysAgo }.count
            let prev30 = habit.completionDates.filter { $0 > sixtyDaysAgo && $0 <= thirtyDaysAgo }.count
            
            // Had decline (prev30 > 0 but low) and recovered (recent30 significantly higher)
            if prev30 > 0 && prev30 < 10 && recent30 > prev30 * 2 && recent30 >= 15 {
                let mlConfidence = await getMLConfidence(for: .comebackKid, habit: habit)
                
                return Insight(
                    type: .comebackKid,
                    title: L10n.t("insights.comebackKid.title"),
                    message: String(format: L10n.t("insights.comebackKid.message"), habit.title),
                    relatedHabitId: habit.id,
                    suggestedActions: [.celebrateAchievement, .reviewProgress(habit.id)],
                    confidence: mlConfidence
                )
            }
        }
        
        return nil
    }
    
    private func analyzeTimeOptimizer(habits: [Habit]) -> Insight? {
        var hourCounts: [Int: Int] = [:]
        let calendar = Calendar.current
        
        for habit in habits {
            let recentCompletions = habit.completionDates.sorted(by: >).prefix(50)
            for date in recentCompletions {
                let hour = calendar.component(.hour, from: date)
                hourCounts[hour, default: 0] += 1
            }
        }
        
        guard let (bestHour, count) = hourCounts.max(by: { $0.value < $1.value }), count > 10 else {
            return nil
        }
        
        let hourString = String(format: "%02d:00", bestHour)
        
        return Insight(
            type: .timeOptimizer,
            title: L10n.t("insights.timeOptimizer.title"),
            message: String(format: L10n.t("insights.timeOptimizer.message"), hourString),
            relatedHabitId: nil,
            suggestedActions: [.adjustSchedule(UUID())],
            confidence: 0.7
        )
    }
    
    private func analyzeCategoryMaster(habits: [Habit]) -> Insight? {
        var categoryCounts: [String: Int] = [:]
        
        for habit in habits {
            let category = habit.category.rawValue
            let recentCompletions = habit.completionDates.filter {
                $0 > Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            }.count
            categoryCounts[category, default: 0] += recentCompletions
        }
        
        guard let (bestCategory, count) = categoryCounts.max(by: { $0.value < $1.value }), count > 20 else {
            return nil
        }
        
        let categoryName = L10n.t("category.\(bestCategory)")
        
        return Insight(
            type: .categoryMaster,
            title: L10n.t("insights.categoryMaster.title"),
            message: String(format: L10n.t("insights.categoryMaster.message"), categoryName),
            relatedHabitId: nil,
            suggestedActions: [.celebrateAchievement],
            confidence: 0.7
        )
    }
    
    private func analyzeGoalAchiever(habits: [Habit]) async -> Insight? {
        for habit in habits {
            let goalDays = habit.goalDays
            if goalDays > 0 {
                let daysTracked = Calendar.current.dateComponents([.day], from: habit.effectiveStartDate, to: Date()).day ?? 0
                if daysTracked >= goalDays {
                    let completionRate = Double(habit.completionDates.count) / Double(daysTracked)
                    if completionRate >= 0.8 {
                        let mlConfidence = await getMLConfidence(for: .goalAchiever, habit: habit)
                        
                        return Insight(
                            type: .goalAchiever,
                            title: L10n.t("insights.goalAchiever.title"),
                            message: String(format: L10n.t("insights.goalAchiever.message"), goalDays, habit.title),
                            relatedHabitId: habit.id,
                            suggestedActions: [.celebrateAchievement, .updateGoal(habit.id)],
                            confidence: mlConfidence
                        )
                    }
                }
            }
        }
        
        return nil
    }
    
    private func analyzeSocialButterfly(habits: [Habit]) -> Insight? {
        let socialHabits = habits.filter { $0.category == .social }
        guard !socialHabits.isEmpty else { return nil }
        
        let totalCompletions = socialHabits.reduce(0) { $0 + $1.completionDates.count }
        let avgCompletions = Double(totalCompletions) / Double(socialHabits.count)
        
        if avgCompletions > 20 {
            return Insight(
                type: .socialButterfly,
                title: L10n.t("insights.socialButterfly.title"),
                message: L10n.t("insights.socialButterfly.message"),
                relatedHabitId: nil,
                suggestedActions: [.celebrateAchievement],
                confidence: 0.7
            )
        }
        
        return nil
    }
    
    private func analyzeHealthHero(habits: [Habit]) -> Insight? {
        let healthHabits = habits.filter { $0.category == .health }
        guard !healthHabits.isEmpty else { return nil }
        
        let totalCompletions = healthHabits.reduce(0) { $0 + $1.completionDates.count }
        let avgCompletions = Double(totalCompletions) / Double(healthHabits.count)
        
        if avgCompletions > 25 {
            return Insight(
                type: .healthHero,
                title: L10n.t("insights.healthHero.title"),
                message: L10n.t("insights.healthHero.message"),
                relatedHabitId: nil,
                suggestedActions: [.celebrateAchievement],
                confidence: 0.7
            )
        }
        
        return nil
    }
    
    private func analyzeLearningLeader(habits: [Habit]) -> Insight? {
        let learningHabits = habits.filter { $0.category == .learning }
        guard !learningHabits.isEmpty else { return nil }
        
        let totalCompletions = learningHabits.reduce(0) { $0 + $1.completionDates.count }
        let avgCompletions = Double(totalCompletions) / Double(learningHabits.count)
        
        if avgCompletions > 20 {
            return Insight(
                type: .learningLeader,
                title: L10n.t("insights.learningLeader.title"),
                message: L10n.t("insights.learningLeader.message"),
                relatedHabitId: nil,
                suggestedActions: [.celebrateAchievement],
                confidence: 0.7
            )
        }
        
        return nil
    }
    
    // MARK: - Helper Functions
    
    private func calculateWeeklyRate(_ habit: Habit) -> Double {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let completionsLastWeek = habit.completionDates.filter { $0 > oneWeekAgo }.count
        return Double(completionsLastWeek) / 7.0
    }
    
    private func calculateConsistencyRate(_ habit: Habit) -> Double {
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: habit.effectiveStartDate, to: Date()).day ?? 1
        guard daysSinceStart > 0 else { return 0.0 }
        
        return Double(habit.completionDates.count) / Double(daysSinceStart)
    }
    
    private func analyzeTimePatternsSync(habits: [Habit]) -> (earlyBird: Bool, nightOwl: Bool) {
        var morningCount = 0
        var nightCount = 0
        var totalCount = 0
        
        let calendar = Calendar.current
        
        for habit in habits {
            let recentCompletions = habit.completionDates.sorted(by: >).prefix(30)
            
            for date in recentCompletions {
                let hour = calendar.component(.hour, from: date)
                if hour >= 5 && hour < 10 {
                    morningCount += 1
                } else if hour >= 22 || hour < 2 {
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
    
    private func isWeekendWarriorSync(habits: [Habit]) -> Bool {
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
    
    /// Removes duplicate insights (same type and same habit)
    private func removeDuplicates(_ insights: [Insight]) -> [Insight] {
        var seen: Set<String> = []
        var unique: [Insight] = []
        
        for insight in insights {
            // Create a unique key: type description + habitId (or "general" if no specific habit)
            let typeString = String(describing: insight.type)
            let key = "\(typeString)-\(insight.relatedHabitId?.uuidString ?? "general")"
            
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(insight)
            }
        }
        
        return unique
    }
    
    /// Prioritizes insights: critical/negative first, then positive, then informational
    private func prioritizeInsights(_ insights: [Insight]) -> [Insight] {
        let priorityOrder: [InsightType] = [
            .needsFocus, .challengingHabit, .monthlyTrendDown, .sentimentTrendDown,
            .streakMaster, .moodBooster, .monthlyTrendUp, .sentimentTrendUp, .productiveDay,
            .consistencyChampion, .comebackKid, .goalAchiever,
            .earlyBird, .nightOwl, .weekendWarrior,
            .timeOptimizer, .categoryMaster, .socialButterfly, .healthHero, .learningLeader
        ]
        
        return insights.sorted { insight1, insight2 in
            let priority1 = priorityOrder.firstIndex(of: insight1.type) ?? Int.max
            let priority2 = priorityOrder.firstIndex(of: insight2.type) ?? Int.max
            if priority1 == priority2 {
                // If same priority, sort by confidence
                return insight1.confidence > insight2.confidence
            }
            return priority1 < priority2
        }
    }
    
    /// Clears the insights cache (call when habits are significantly updated)
    func clearCache() {
        cachedInsights = []
        lastAnalysisDate = nil
        lastHabitsHash = 0
    }
    
    // MARK: - ML Integration
    
    /// Gets ML confidence score for an insight type (placeholder for Core ML integration)
    private func getMLConfidence(for type: InsightType, habit: Habit) async -> Double {
        // Initialize ML predictor if needed
        if mlPredictor == nil {
            mlPredictor = HabitMLPredictor()
        }
        
        // Use ML predictor to get confidence score
        if let predictor = mlPredictor {
            return await predictor.predictConfidence(for: type, habit: habit)
        }
        
        // Fallback to default confidence based on data quality
        let dataQuality = min(1.0, Double(habit.completionDates.count) / 30.0)
        return 0.5 + (dataQuality * 0.3) // Base 0.5 + up to 0.3 based on data
    }
}

// MARK: - ML Predictor (Core ML Integration)

/// ML Predictor for habit insights with Core ML support
class HabitMLPredictor {
    // Core ML model (will be loaded when available)
    private var model: MLModel?
    private var isModelLoaded = false
    private var modelLoadAttempted = false
    
    // Feature extractor for ML model
    private let featureExtractor = HabitFeatureExtractor()
    
    init() {
        // Initialize ML model when available (lazy loading)
        Task {
            await loadMLModel()
        }
    }
    
    /// Loads Core ML model from bundle
    @MainActor
    private func loadMLModel() async {
        guard !modelLoadAttempted else { return }
        modelLoadAttempted = true
        
        // Try to load the model
        guard let modelURL = Bundle.main.url(forResource: "HabitInsightModel", withExtension: "mlmodelc") ??
                            Bundle.main.url(forResource: "HabitInsightModel", withExtension: "mlmodel") else {
            #if DEBUG
            print("ℹ️ Core ML model not found in bundle, using rule-based fallback")
            #endif
            return
        }
        
        do {
            // If .mlmodel, compile it first
            let finalURL: URL
            if modelURL.pathExtension == "mlmodel" {
                finalURL = try await MLModel.compileModel(at: modelURL)
            } else {
                finalURL = modelURL
            }
            
            // Load the compiled model
            model = try MLModel(contentsOf: finalURL)
            isModelLoaded = true
            
            #if DEBUG
            print("✅ Core ML model loaded successfully from: \(finalURL.lastPathComponent)")
            #endif
        } catch {
            #if DEBUG
            print("⚠️ Failed to load Core ML model: \(error.localizedDescription)")
            print("   Using rule-based fallback instead")
            #endif
            isModelLoaded = false
        }
    }
    
    /// Predicts confidence score for an insight using ML model or fallback algorithm
    func predictConfidence(for type: InsightType, habit: Habit) async -> Double {
        // Extract features for ML model
        let features = featureExtractor.extractFeatures(for: habit, insightType: type)
        
        // If ML model is available and loaded, use it
        if isModelLoaded, let model = model {
            if let mlConfidence = await predictWithML(model: model, features: features) {
                return mlConfidence
            }
        }
        
        // Fallback to rule-based confidence calculation
        return calculateConfidence(features: features, type: type, habit: habit)
    }
    
    /// Calculates confidence using rule-based algorithm (fallback)
    private func calculateConfidence(features: HabitFeatures, type: InsightType, habit: Habit) -> Double {
        // Base confidence from data quality
        var confidence = features.dataQuality
        
        // Adjust based on insight type and habit characteristics
        switch type {
        case .streakMaster:
            confidence = min(1.0, features.streakQuality * 0.9 + features.dataQuality * 0.1)
            
        case .consistencyChampion:
            confidence = min(1.0, features.consistencyRate * 0.8 + features.dataQuality * 0.2)
            
        case .needsFocus, .challengingHabit:
            // Lower confidence for negative insights (need more data)
            confidence = features.dataQuality * 0.7
            
        case .goalAchiever:
            confidence = min(1.0, features.goalProgress * 0.9 + features.dataQuality * 0.1)
            
        case .comebackKid:
            confidence = min(1.0, features.recoveryScore * 0.8 + features.dataQuality * 0.2)
            
        case .moodBooster:
            confidence = min(1.0, features.sentimentScore * 0.7 + features.dataQuality * 0.3)
            
        default:
            confidence = features.dataQuality
        }
        
        // Ensure confidence is within valid range
        return max(0.3, min(1.0, confidence))
    }
    
    /// Predicts using Core ML model (when available)
    private func predictWithML(model: MLModel, features: HabitFeatures) async -> Double? {
        do {
            // Convert features to MLMultiArray
            let featureArray = features.toMLArray()
            guard let inputArray = try? MLMultiArray(shape: [NSNumber(value: featureArray.count)], dataType: .double) else {
                return nil
            }
            
            // Fill the array with feature values
            for (index, value) in featureArray.enumerated() {
                inputArray[index] = NSNumber(value: value)
            }
            
            // Create input dictionary (model-specific, adjust based on your model's input schema)
            // This is a generic approach - adjust input key based on your actual model
            let input = try MLDictionaryFeatureProvider(dictionary: ["features": MLFeatureValue(multiArray: inputArray)])
            
            // Make prediction
            let prediction = try await model.prediction(from: input)
            
            // Extract confidence from output (adjust key based on your model's output schema)
            // Generic approach: look for "confidence" or first output value
            if let confidenceValue = prediction.featureValue(for: "confidence") {
                // MLFeatureValue.doubleValue is non-optional, use directly
                let doubleValue = confidenceValue.doubleValue
                return max(0.0, min(1.0, doubleValue)) // Clamp to 0-1
            }
            
            // Fallback: try to get first output value
            if let firstOutput = prediction.featureNames.first,
               let outputValue = prediction.featureValue(for: firstOutput) {
                // MLFeatureValue.doubleValue is non-optional, use directly
                let doubleValue = outputValue.doubleValue
                return max(0.0, min(1.0, doubleValue))
            }
            
            return nil
        } catch {
            #if DEBUG
            print("⚠️ ML prediction failed: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
}

// MARK: - Feature Extractor

/// Extracts features from habits for ML model input
class HabitFeatureExtractor {
    func extractFeatures(for habit: Habit, insightType: InsightType) -> HabitFeatures {
        let calendar = Calendar.current
        let now = Date()
        let daysSinceStart = calendar.dateComponents([.day], from: habit.effectiveStartDate, to: now).day ?? 1
        
        // Data quality: based on number of completions and time tracked
        let dataQuality = min(1.0, Double(habit.completionDates.count) / max(30.0, Double(daysSinceStart)))
        
        // Streak quality: normalized streak
        let streakQuality = min(1.0, Double(habit.streak) / 30.0)
        
        // Consistency rate
        let consistencyRate = daysSinceStart > 0 ? Double(habit.completionDates.count) / Double(daysSinceStart) : 0.0
        
        // Goal progress
        let goalProgress: Double
        let goalDays = habit.goalDays
        if goalDays > 0 {
            goalProgress = min(1.0, Double(habit.completionDates.count) / Double(goalDays))
        } else {
            goalProgress = 0.0
        }
        
        // Recovery score (for comeback kid)
        let recoveryScore: Double
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: now)!
        let recent30 = habit.completionDates.filter { $0 > thirtyDaysAgo }.count
        let prev30 = habit.completionDates.filter { $0 > sixtyDaysAgo && $0 <= thirtyDaysAgo }.count
        if prev30 > 0 && recent30 > prev30 {
            recoveryScore = min(1.0, Double(recent30 - prev30) / Double(prev30))
        } else {
            recoveryScore = 0.0
        }
        
        // Sentiment score
        let sentimentScore: Double
        if !habit.completionNotes.isEmpty {
            let notes = Array(habit.completionNotes.values)
            sentimentScore = max(-1.0, min(1.0, SentimentAnalyzer.averageSentiment(for: notes)))
        } else {
            sentimentScore = SentimentAnalyzer.analyzeSentiment(for: habit.notes)
        }
        
        return HabitFeatures(
            dataQuality: dataQuality,
            streakQuality: streakQuality,
            consistencyRate: consistencyRate,
            goalProgress: goalProgress,
            recoveryScore: recoveryScore,
            sentimentScore: sentimentScore,
            completionCount: habit.completionDates.count,
            daysTracked: daysSinceStart,
            hasNotes: !habit.completionNotes.isEmpty,
            category: habit.category.rawValue
        )
    }
}

// MARK: - Feature Model

/// Features extracted from habits for ML model
struct HabitFeatures {
    let dataQuality: Double
    let streakQuality: Double
    let consistencyRate: Double
    let goalProgress: Double
    let recoveryScore: Double
    let sentimentScore: Double
    let completionCount: Int
    let daysTracked: Int
    let hasNotes: Bool
    let category: String
    
    /// Converts features to array for ML model input
    func toMLArray() -> [Double] {
        return [
            dataQuality,
            streakQuality,
            consistencyRate,
            goalProgress,
            recoveryScore,
            (sentimentScore + 1.0) / 2.0, // Normalize to 0-1
            Double(completionCount) / 100.0, // Normalize
            Double(daysTracked) / 365.0, // Normalize
            hasNotes ? 1.0 : 0.0,
            // Category encoding (one-hot would be better, but simplified)
            Double(category.hashValue % 10) / 10.0
        ]
    }
}
