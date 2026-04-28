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
        // Hash'e completion durumlarını da dahil et (sadece ID'ler yeterli değil)
        let habitsHash = habits.map { habit in
            // Her habit için ID, completion durumu, streak ve completion dates'i hash'e dahil et
            var hasher = Hasher()
            hasher.combine(habit.id)
            hasher.combine(habit.isCompletedToday)
            hasher.combine(habit.streak)
            hasher.combine(habit.completionDates.count)
            // Son 7 günün completion durumlarını da dahil et
            let calendar = Calendar.current
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let recentCompletions = habit.completionDates.filter { $0 >= sevenDaysAgo }.count
            hasher.combine(recentCompletions)
            // Completion notes'u da hash'e dahil et (yeni notlar eklendiğinde cache invalidate olsun)
            hasher.combine(habit.completionNotes.count)
            // Son 7 günün notlarını da dahil et
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let limitKey = dateFormatter.string(from: sevenDaysAgo)
            let recentNotesCount = habit.completionNotes.filter { $0.key >= limitKey }.count
            hasher.combine(recentNotesCount)
            return hasher.finalize()
        }.reduce(0) { $0 ^ $1 }
        
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
            
            // New predictive insights
            group.addTask {
                await self.analyzeStreakRisk(habits: habits)
            }
            
            group.addTask {
                await self.analyzeTimeOptimizer(habits: habits)
            }
            
            group.addTask {
                await self.analyzeHabitChains(habits: habits)
            }
            
            group.addTask {
                await self.analyzeRecoveryPattern(habits: habits)
            }
            
            // Measurement insights (premium only)
            let isPremiumUser = await MainActor.run { PremiumManager.shared.isPremium }
            if isPremiumUser {
                group.addTask {
                    await self.analyzeMeasurementTrend()
                }
                
                group.addTask {
                    await self.analyzeHabitMeasurementCorrelation(habits: habits)
                }
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
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let now = Date()
            
            // Tüm completion notlarını tarihleriyle birlikte topla (EWMA için)
            var datedNotes: [(daysAgo: Int, text: String)] = []
            
            for (dateKey, note) in habit.completionNotes where !note.isEmpty {
                if let noteDate = dateFormatter.date(from: dateKey) {
                    let daysAgo = calendar.dateComponents([.day], from: noteDate, to: now).day ?? 0
                    datedNotes.append((daysAgo: max(0, daysAgo), text: note))
                }
            }
            
            // Habit'in ana notunu da ekle (daysAgo = 0 olarak, her zaman güncel kabul edilir)
            if !habit.notes.isEmpty {
                datedNotes.append((daysAgo: 0, text: habit.notes))
            }
            
            // EWMA ile ağırlıklı sentiment hesapla
            // Hard 7-gün cutoff yerine gradual decay kullanıyoruz — tek bir kötü gün
            // tüm skoru domine edemez, ama yakın geçmiş yine de daha ağırlıklı.
            let sentimentScore: Double
            if datedNotes.isEmpty {
                sentimentScore = 0.0
            } else {
                sentimentScore = SentimentAnalyzer.ewmaSentiment(for: datedNotes)
            }
            
            // Son 7 günün notlarını al (son not kontrolü için)
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            let limitKey = dateFormatter.string(from: sevenDaysAgo)
            let recentNotes = habit.completionNotes
                .filter { $0.key >= limitKey && !$0.value.isEmpty }
                .sorted { $0.key > $1.key }
                .map { $0.value }
            
            // ÖNEMLİ: Son 1-2 notun sentiment'ine özel bak
            // Eğer son notlar çok negatifse, genel ortalama iyi olsa bile insight oluştur
            var shouldShowChallengingInsight = false
            var lastNoteScore: Double = 0.0
            var lastTwoAverage: Double = 0.0
            
            if recentNotes.count >= 1 {
                // Son 1-2 notun sentiment'ini kontrol et
                lastNoteScore = SentimentAnalyzer.analyzeSentiment(for: recentNotes[0])
                if recentNotes.count >= 2 {
                    let secondLastScore = SentimentAnalyzer.analyzeSentiment(for: recentNotes[1])
                    lastTwoAverage = (lastNoteScore + secondLastScore) / 2.0
                    // Son 2 not ortalaması -0.3'ten düşükse, zorluk çekiyor demektir
                    if lastTwoAverage < -0.3 {
                        shouldShowChallengingInsight = true
                    }
                } else {
                    // Son not -0.4'ten düşükse (daha hassas eşik)
                    if lastNoteScore < -0.4 {
                        shouldShowChallengingInsight = true
                    }
                }
            }
            
            #if DEBUG
            print("📊 Sentiment Analysis for '\(habit.title)':")
            print("   - Recent notes count: \(recentNotes.count)")
            print("   - Overall sentiment score: \(sentimentScore)")
            print("   - Last note score: \(lastNoteScore)")
            if recentNotes.count >= 2 {
                print("   - Last 2 notes average: \(lastTwoAverage)")
            }
            print("   - Should show challenging insight: \(shouldShowChallengingInsight)")
            if !recentNotes.isEmpty {
                print("   - Recent notes: \(recentNotes.prefix(3).joined(separator: ", "))")
            }
            #endif
            
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
            } else if sentimentScore < -0.3 || shouldShowChallengingInsight {
                // Eşiği -0.6'dan -0.3'e düşürdük ve son notlara özel kontrol ekledik
                #if DEBUG
                print("✅ Creating challenging habit insight for '\(habit.title)'")
                #endif
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
            .needsFocus, .challengingHabit, .monthlyTrendDown, .sentimentTrendDown, .streakRisk,
            .streakMaster, .moodBooster, .monthlyTrendUp, .sentimentTrendUp, .productiveDay, .recovery,
            .consistencyChampion, .comebackKid, .goalAchiever,
            .earlyBird, .nightOwl, .weekendWarrior,
            .timeOptimizer, .categoryMaster, .socialButterfly, .healthHero, .learningLeader,
            .habitChain,
            .measurementTrendUp, .measurementTrendDown, .habitMeasurementCorrelation
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
        #if DEBUG
        print("🗑️ Insights cache cleared")
        #endif
    }
    
    /// Force refresh insights (clears cache and forces new analysis)
    func forceRefresh() {
        clearCache()
    }
    
    // MARK: - New Predictive Insights
    
    /// Analyzes streak risk for habits
    private func analyzeStreakRisk(habits: [Habit]) async -> Insight? {
        let calendar = Calendar.current
        
        for habit in habits {
            guard habit.streak > 5 else { continue }
            
            // Son 7 günün completion oranını hesapla
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let recentCompletions = habit.completionDates.filter { $0 >= sevenDaysAgo }.count
            let completionRate = Double(recentCompletions) / 7.0
            
            // Son 3 günü kontrol et
            let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
            let last3DaysCompletions = habit.completionDates.filter { $0 >= threeDaysAgo }.count
            
            // Eğer son 3 gün hiç tamamlanmamışsa ve completion rate düşükse risk var
            if last3DaysCompletions == 0 && completionRate < 0.5 {
                return Insight(
                    type: .streakRisk,
                    title: L10n.t("insights.streakRisk.title"),
                    message: String(format: L10n.t("insights.streakRisk.message"), habit.streak, habit.title),
                    relatedHabitId: habit.id,
                    suggestedActions: [.focusOnHabit(habit.id), .setReminder(habit.id)],
                    confidence: 0.85
                )
            }
        }
        return nil
    }
    
    /// Analyzes optimal completion timing (improved version with percentage)
    private func analyzeTimeOptimizer(habits: [Habit]) async -> Insight? {
        var hourCompletionMap: [Int: Int] = [:]
        let calendar = Calendar.current
        
        // Find global best time across all habits? Or specific habit?
        // The plan says "Suggest the best time to set a reminder based on actual completion history."
        // Usually best for a specific habit.
        
        for habit in habits {
            hourCompletionMap.removeAll()
            // Analyze specific habit history
            for completionDate in habit.completionDates {
                let hour = calendar.component(.hour, from: completionDate)
                hourCompletionMap[hour, default: 0] += 1
            }
            
            guard let bestHour = hourCompletionMap.max(by: { $0.value < $1.value }),
                  bestHour.value > 3 else { // Min 3 completions to suggest
                continue
            }
            
            let totalCompletions = hourCompletionMap.values.reduce(0, +)
            let bestHourPercentage = Double(bestHour.value) / max(1.0, Double(totalCompletions))
            
            // If > 40% of completions happen in this hour block
            if bestHourPercentage > 0.4 {
                let hourString = String(format: "%02d:00", bestHour.key)
                
                // We encode the hour in the message or title heavily?
                // Or we assume the UI parses it? This is tricky without changing Insight struct.
                // Let's change Insight struct or use a workaround.
                // Workaround: Use title as "Best Time: 14:00" and UI checks for .timeOptimizer type.
                
                return Insight(
                    type: .timeOptimizer,
                    title: hourString, // Store hour directly in title for easy parsing/display
                    message: String(format: L10n.t("insights.timeOptimizer.message"), hourString),
                    relatedHabitId: habit.id,
                    suggestedActions: [.adjustSchedule(habit.id)],
                    confidence: 0.8
                )
            }
        }
        return nil
    }
    
    /// Analyzes habit chains (habits completed together)
    private func analyzeHabitChains(habits: [Habit]) async -> Insight? {
        guard habits.count >= 2 else { return nil }
        
        let calendar = Calendar.current
        var bestCorrelation: (habit1: Habit, habit2: Habit, count: Int)?
        var maxCount = 0
        
        for i in 0..<habits.count {
            for j in (i+1)..<habits.count {
                let habit1 = habits[i]
                let habit2 = habits[j]
                
                // Aynı gün tamamlanma sayısını hesapla
                let sameDayCompletions = habit1.completionDates.filter { date1 in
                    habit2.completionDates.contains { date2 in
                        calendar.isDate(date1, inSameDayAs: date2)
                    }
                }.count
                
                if sameDayCompletions > maxCount && sameDayCompletions > 5 {
                    maxCount = sameDayCompletions
                    bestCorrelation = (habit1, habit2, sameDayCompletions)
                }
            }
        }
        
        if let correlation = bestCorrelation, correlation.count > 7 {
            return Insight(
                type: .habitChain,
                title: L10n.t("insights.habitChain.title"),
                message: String(format: L10n.t("insights.habitChain.message"), correlation.habit1.title, correlation.habit2.title, correlation.count),
                relatedHabitId: correlation.habit1.id,
                suggestedActions: [.focusOnHabit(correlation.habit1.id)],
                confidence: 0.8
            )
        }
        return nil
    }
    
    /// Analyzes recovery patterns (improvement after decline)
    private func analyzeRecoveryPattern(habits: [Habit]) async -> Insight? {
        let calendar = Calendar.current
        
        for habit in habits {
            guard habit.completionDates.count > 14 else { continue }
            
            let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
            let last7Days = calendar.date(byAdding: .day, value: -7, to: Date())!
            
            let recentCompletions = habit.completionDates.filter { $0 >= last7Days }.count
            let previousCompletions = habit.completionDates.filter {
                $0 >= twoWeeksAgo && $0 < last7Days
            }.count
            
            // Eğer son 7 gün önceki 7 günden %50 daha iyiyse
            if previousCompletions > 0 && recentCompletions > previousCompletions *  2 {
                let improvement = ((Double(recentCompletions) / Double(previousCompletions)) - 1.0) * 100
                return Insight(
                    type: .recovery,
                    title: L10n.t("insights.recovery.title"),
                    message: String(format: L10n.t("insights.recovery.message"), habit.title, Int(improvement)),
                    relatedHabitId: habit.id,
                    suggestedActions: [.celebrateAchievement, .reviewProgress(habit.id)],
                    confidence: 0.85
                )
            }
        }
        return nil
    }
    
    // MARK: - Measurement Insights
    
    /// Analyzes measurement trends for each type over the last 30 days
    private func analyzeMeasurementTrend() async -> Insight? {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        for type in MeasurementType.allTypes {
            let typeEntries = await MainActor.run {
                MeasurementStore.shared.entries(for: type.id)
            }.filter { $0.date >= thirtyDaysAgo }
             .sorted { $0.date < $1.date }
            
            guard typeEntries.count >= 3 else { continue }
            
            // Linear regression
            let n = Double(typeEntries.count)
            let referenceDate = typeEntries.first!.date
            let points: [(x: Double, y: Double)] = typeEntries.map { entry in
                let x = entry.date.timeIntervalSince(referenceDate) / 86400.0
                return (x: x, y: entry.value)
            }
            
            let sumX = points.reduce(0.0) { $0 + $1.x }
            let sumY = points.reduce(0.0) { $0 + $1.y }
            let sumXY = points.reduce(0.0) { $0 + $1.x * $1.y }
            let sumX2 = points.reduce(0.0) { $0 + $1.x * $1.x }
            
            let denominator = n * sumX2 - sumX * sumX
            guard abs(denominator) > 1e-10 else { continue }
            
            let slope = (n * sumXY - sumX * sumY) / denominator
            
            // Threshold: slope relative to average value
            let avgValue = sumY / n
            guard avgValue > 0 else { continue }
            let relativeSlope = slope / avgValue
            
            if relativeSlope > 0.01 {
                return Insight(
                    type: .measurementTrendUp,
                    title: L10n.t("insights.measurementTrendUp.title"),
                    message: String(format: L10n.t("insights.measurementTrendUp.message"), type.displayName),
                    relatedHabitId: nil,
                    suggestedActions: [.reviewProgress(UUID())],
                    confidence: 0.75
                )
            } else if relativeSlope < -0.01 {
                return Insight(
                    type: .measurementTrendDown,
                    title: L10n.t("insights.measurementTrendDown.title"),
                    message: String(format: L10n.t("insights.measurementTrendDown.message"), type.displayName),
                    relatedHabitId: nil,
                    suggestedActions: [.reviewProgress(UUID())],
                    confidence: 0.75
                )
            }
        }
        
        return nil
    }
    
    /// Analyzes correlation between habit completions and measurement trends
    private func analyzeHabitMeasurementCorrelation(habits: [Habit]) async -> Insight? {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        for type in MeasurementType.allTypes {
            let typeEntries = await MainActor.run {
                MeasurementStore.shared.entries(for: type.id)
            }.filter { $0.date >= thirtyDaysAgo }
             .sorted { $0.date < $1.date }
            
            guard typeEntries.count >= 5 else { continue }
            
            for habit in habits {
                let recentCompletions = habit.completionDates.filter { $0 >= thirtyDaysAgo }
                guard recentCompletions.count >= 10 else { continue }
                
                // Build daily arrays for Pearson correlation
                var measurementValues: [Double] = []
                var completionValues: [Double] = []
                
                // For each day in the last 30 days
                for dayOffset in 0..<30 {
                    guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
                    
                    // Check if there's a measurement on this day
                    let dayMeasurement = typeEntries.first { calendar.isDate($0.date, inSameDayAs: day) }
                    guard let measurement = dayMeasurement else { continue }
                    
                    // Check if habit was completed on this day
                    let wasCompleted = recentCompletions.contains { calendar.isDate($0, inSameDayAs: day) }
                    
                    measurementValues.append(measurement.value)
                    completionValues.append(wasCompleted ? 1.0 : 0.0)
                }
                
                guard measurementValues.count >= 5 else { continue }
                
                // Pearson correlation
                let n = Double(measurementValues.count)
                let sumX = measurementValues.reduce(0, +)
                let sumY = completionValues.reduce(0, +)
                let sumXY = zip(measurementValues, completionValues).reduce(0.0) { $0 + $1.0 * $1.1 }
                let sumX2 = measurementValues.reduce(0.0) { $0 + $1 * $1 }
                let sumY2 = completionValues.reduce(0.0) { $0 + $1 * $1 }
                
                let numerator = n * sumXY - sumX * sumY
                let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
                
                guard denominator > 1e-10 else { continue }
                let r = numerator / denominator
                
                if abs(r) > 0.5 {
                    return Insight(
                        type: .habitMeasurementCorrelation,
                        title: L10n.t("insights.habitMeasurementCorrelation.title"),
                        message: String(format: L10n.t("insights.habitMeasurementCorrelation.message"), habit.title, type.displayName),
                        relatedHabitId: habit.id,
                        suggestedActions: [.reviewProgress(habit.id)],
                        confidence: 0.7
                    )
                }
            }
        }
        
        return nil
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
    
    /// Calculates daily success probability for a habit
    func calculateDailySuccessProbability(habit: Habit) async -> Double {
        if mlPredictor == nil {
            mlPredictor = HabitMLPredictor()
        }
        return mlPredictor?.calculateDailyProbability(habit: habit) ?? 0.5
    }
}

// MARK: - ML Predictor (Core ML Integration)

/// ML Predictor for habit insights with Core ML support.
///
/// **Current Status**: The bundled `HabitInsightModel.mlmodelc` does NOT exist yet.
/// All predictions currently use the rule-based fallback (`calculateConfidence`).
///
/// **To train a real model**:
/// 1. Run `HabitMLTrainingDataGenerator.generateCSV()` to create synthetic training data
/// 2. Open Create ML in Xcode (Xcode → Open Developer Tool → Create ML)
/// 3. Create a Tabular Regression model with target column "successProbability"
/// 4. Import the generated CSV, train, and export as `HabitInsightModel.mlmodel`
/// 5. Add the `.mlmodel` to the Xcode project — Xcode auto-compiles to `.mlmodelc`
///
/// **Important**: The synthetic-trained model is a bootstrap that matches current rule-based
/// logic plus controlled noise. It is NOT a true predictor of user behavior.
/// TODO: Replace with model trained on real user data once we have ≥10k samples.
class HabitMLPredictor {
    
    /// Which prediction path is active
    enum PredictionPath: String {
        case coreML = "CoreML"
        case ruleBased = "RuleBased"
    }
    
    private var model: MLModel?
    private(set) var isModelLoaded = false
    private var modelLoadAttempted = false
    private(set) var activePath: PredictionPath = .ruleBased
    
    private let featureExtractor = HabitFeatureExtractor()
    
    init() {
        Task {
            await loadMLModel()
        }
    }
    
    /// Loads Core ML model from bundle.
    /// If the model is missing, logs which path is active (debug builds only).
    @MainActor
    private func loadMLModel() async {
        guard !modelLoadAttempted else { return }
        modelLoadAttempted = true
        
        // NOTE: HabitInsightModel.mlmodelc is not yet bundled.
        // When you add it to the project, this code will automatically pick it up.
        guard let modelURL = Bundle.main.url(forResource: "HabitInsightModel", withExtension: "mlmodelc") ??
                            Bundle.main.url(forResource: "HabitInsightModel", withExtension: "mlmodel") else {
            activePath = .ruleBased
            #if DEBUG
            print("🧠 [HabitMLPredictor] Model path: RULE-BASED (HabitInsightModel.mlmodelc not found in bundle)")
            print("   → To train a model, see HabitMLTrainingDataGenerator.swift")
            #endif
            return
        }
        
        do {
            let finalURL: URL
            if modelURL.pathExtension == "mlmodel" {
                finalURL = try await MLModel.compileModel(at: modelURL)
            } else {
                finalURL = modelURL
            }
            
            model = try MLModel(contentsOf: finalURL)
            isModelLoaded = true
            activePath = .coreML
            
            #if DEBUG
            print("🧠 [HabitMLPredictor] Model path: CORE ML (\(finalURL.lastPathComponent))")
            #endif
        } catch {
            activePath = .ruleBased
            #if DEBUG
            print("🧠 [HabitMLPredictor] Model path: RULE-BASED (load failed: \(error.localizedDescription))")
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
    
    /// Calculates the probability (0-100%) of completing the habit today
    func calculateDailyProbability(habit: Habit) -> Double {
        // 1. Weekday Consistency (50%)
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        var matchCount = 0
        var totalCount = 0
        
        let recentCompletions = habit.completionDates.sorted(by: >).prefix(40) // Look at last 40 completions
        
        for date in recentCompletions {
            let weekday = calendar.component(.weekday, from: date)
            if weekday == today {
                matchCount += 1
            }
            totalCount += 1
        }
        
        // Normalize: If we have history, how often is it this weekday?
        // But better: How often do we complete on this weekday relative to expected?
        // Let's look at last 8 weeks specific to this weekday.
        let eightWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -8, to: Date())!
        let completionsSince = habit.completionDates.filter { $0 >= eightWeeksAgo }
        
        var weekdayCompletions = 0
        for date in completionsSince {
            if calendar.component(.weekday, from: date) == today {
                weekdayCompletions += 1
            }
        }
        
        // Max score if completed 6-8 times in last 8 weeks on this day
        let consistencyScore = min(1.0, Double(weekdayCompletions) / 6.0)
        
        // 2. Streak Bonus (30%)
        let streakScore = min(1.0, Double(habit.streak) / 10.0)
        
        // 3. Time Decay (20%) - If it's late (e.g. 23:00) and not done, lower prob
        let hour = calendar.component(.hour, from: Date())
        var timeScore = 1.0
        if hour >= 22 {
            timeScore = 0.2
        } else if hour >= 20 {
            timeScore = 0.6
        }
        
        // Weighted Average
        let probability = (consistencyScore * 0.5) + (streakScore * 0.3) + (timeScore * 0.2)
        
        return max(0.1, min(0.99, probability))
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
        
        // Sentiment score (EWMA for time-aware weighting)
        let sentimentScore: Double
        if !habit.completionNotes.isEmpty {
            let calendar = Calendar.current
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let datedNotes: [(daysAgo: Int, text: String)] = habit.completionNotes.compactMap { (dateKey, note) in
                guard !note.isEmpty, let noteDate = dateFormatter.date(from: dateKey) else { return nil }
                let daysAgo = calendar.dateComponents([.day], from: noteDate, to: now).day ?? 0
                return (daysAgo: max(0, daysAgo), text: note)
            }
            sentimentScore = max(-1.0, min(1.0, SentimentAnalyzer.ewmaSentiment(for: datedNotes)))
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
