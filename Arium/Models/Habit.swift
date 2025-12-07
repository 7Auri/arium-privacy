//
//  Habit.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date? // Değişiklik zamanı (Sync optimizasyonu için)
    var streak: Int
    var themeId: String
    var isCompletedToday: Bool
    var completionDates: [Date]
    var completionNotes: [String: String] // Date string (yyyy-MM-dd) : note
    var startDate: Date? // Kullanıcının seçtiği takip başlangıç tarihi
    var goalDays: Int // Hedef gün sayısı (örn: 21 günlük challenge)
    var reminderTime: Date? // Hatırlatıcı zamanı
    var isReminderEnabled: Bool // Hatırlatıcı açık mı
    var category: HabitCategory // Alışkanlık kategorisi
    
    // MARK: - Daily Repetitions (Premium Feature)
    var dailyRepetitions: Int // Günde kaç kez (1-5, default: 1)
    var repetitionLabels: [String]? // Özel etiketler (örn: ["Sabah", "Akşam"])
    var todayCompletions: [Int] // Bugün tamamlanan tekrarların index'leri [0, 1] = sabah ve akşam tamamlandı
    var dailyCompletionCounts: [String: Int] // Date string : completion count (örn: "2024-11-28": 2)
    
    // MARK: - HealthKit Integration
    var healthKitMetric: HealthKitMetric?
    var healthKitGoal: Double? // Value to achieve auto-completion
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        streak: Int = 0,
        themeId: String = "purple",
        isCompletedToday: Bool = false,
        completionDates: [Date] = [],
        completionNotes: [String: String] = [:],
        startDate: Date? = nil,
        goalDays: Int = 21,
        reminderTime: Date? = nil,
        isReminderEnabled: Bool = false,
        category: HabitCategory = .personal,
        dailyRepetitions: Int = 1,
        repetitionLabels: [String]? = nil,
        todayCompletions: [Int] = [],
        dailyCompletionCounts: [String: Int] = [:],
        healthKitMetric: HealthKitMetric? = nil,
        healthKitGoal: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt // Eğer nil gelirse oluşturulma tarihini kullan
        self.streak = streak
        self.themeId = themeId
        self.isCompletedToday = isCompletedToday
        self.completionDates = completionDates
        self.completionNotes = completionNotes
        self.startDate = startDate
        self.goalDays = goalDays
        self.reminderTime = reminderTime
        self.isReminderEnabled = isReminderEnabled
        self.category = category
        self.dailyRepetitions = dailyRepetitions
        self.repetitionLabels = repetitionLabels
        self.todayCompletions = todayCompletions
        self.dailyCompletionCounts = dailyCompletionCounts
        self.healthKitMetric = healthKitMetric
        self.healthKitGoal = healthKitGoal
    }
    
    var theme: HabitTheme {
        HabitTheme.allThemes.first(where: { $0.id == themeId }) ?? .purple
    }
    
    var effectiveStartDate: Date {
        startDate ?? createdAt
    }
    
    var lastModified: Date {
        updatedAt ?? createdAt
    }
    
    mutating func toggleCompletion(on date: Date = Date()) {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        
        // Check if already completed on that date
        let isCompletedOnDate = completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
        
        if isCompletedOnDate {
            // Remove completion
            completionDates.removeAll { calendar.isDate($0, inSameDayAs: date) }
            if isToday { isCompletedToday = false }
        } else {
            // Add completion
            completionDates.append(date)
            if isToday { isCompletedToday = true }
        }
        
        calculateStreak()
    }
    
    mutating func calculateStreak() {
        guard !completionDates.isEmpty else {
            streak = 0
            return
        }
        
        let calendar = Calendar.current
        let sortedDates = completionDates
            .map { calendar.startOfDay(for: $0) }
            .sorted(by: >)
        
        guard let mostRecent = sortedDates.first else {
            streak = 0
            return
        }
        
        // Check if most recent is today or yesterday
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        guard mostRecent == today || mostRecent == yesterday else {
            streak = 0
            return
        }
        
        var currentStreak = 1
        var previousDate = mostRecent
        
        for date in sortedDates.dropFirst() {
            if let dayDifference = calendar.dateComponents([.day], from: date, to: previousDate).day,
               dayDifference == 1 {
                currentStreak += 1
                previousDate = date
            } else {
                break
            }
        }
        
        streak = currentStreak
    }
    
    func checkIfCompletedToday() -> Bool {
        let calendar = Calendar.current
        return completionDates.contains { date in
            calendar.isDateInToday(date)
        }
    }
    
    func noteForDate(_ date: Date) -> String? {
        let key = date.dateKey
        return completionNotes[key]
    }
    
    mutating func setNote(_ note: String, for date: Date) {
        let key = date.dateKey
        if note.isEmpty {
            completionNotes.removeValue(forKey: key)
        } else {
            completionNotes[key] = String(note.prefix(100))
        }
    }
    
    // MARK: - Daily Repetitions Logic
    
    /// Progress for today's completions (completed, total)
    var todayCompletionProgress: (completed: Int, total: Int) {
        (todayCompletions.count, dailyRepetitions)
    }
    
    /// Check if all repetitions are completed today
    var isFullyCompletedToday: Bool {
        todayCompletions.count >= dailyRepetitions
    }
    
    /// Completion percentage (0.0 - 1.0)
    var completionPercentage: Double {
        guard dailyRepetitions > 0 else { return 0 }
        return Double(todayCompletions.count) / Double(dailyRepetitions)
    }
    
    /// Default labels if custom labels not provided
    var displayRepetitionLabels: [String] {
        if let labels = repetitionLabels, labels.count == dailyRepetitions {
            return labels
        }
        
        switch dailyRepetitions {
        case 1:
            return [L10n.t("repetition.once")]
        case 2:
            return [L10n.t("repetition.morning"), L10n.t("repetition.evening")]
        case 3:
            return [L10n.t("repetition.morning"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
        case 4:
            return [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
        case 5:
            return [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening"), L10n.t("repetition.night")]
        default:
            return (0..<dailyRepetitions).map { "\($0 + 1). " + L10n.t("repetition.time") }
        }
    }
    
    mutating func toggleRepetitionCompletion(at index: Int) {
        guard index >= 0 && index < dailyRepetitions else { return }
        
        let wasFullyCompleted = isFullyCompletedToday
        let calendar = Calendar.current
        
        if todayCompletions.contains(index) {
            todayCompletions.removeAll { $0 == index }
            if wasFullyCompleted {
                completionDates.removeAll { calendar.isDateInToday($0) }
            }
        } else {
            todayCompletions.append(index)
            todayCompletions.sort()
            
            if isFullyCompletedToday && !wasFullyCompleted {
                if !completionDates.contains(where: { calendar.isDateInToday($0) }) {
                    completionDates.append(Date())
                }
            }
        }
        
        updateDailyCompletionCount()
        isCompletedToday = isFullyCompletedToday
        calculateStreak()
    }
    
    mutating func resetDailyCompletions() {
        todayCompletions.removeAll()
        isCompletedToday = false
        updateDailyCompletionCount()
    }
    
    mutating func updateDailyCompletionCount(date: Date = Date(), count: Int? = nil) {
        let key = date.dateKey
        let finalCount = count ?? todayCompletions.count
        
        if finalCount > 0 {
            dailyCompletionCounts[key] = finalCount
        } else {
            dailyCompletionCounts.removeValue(forKey: key)
        }
    }
    
    func isRepetitionCompleted(at index: Int) -> Bool {
        return todayCompletions.contains(index)
    }
}

// MARK: - HealthKit Metric Enum

enum HealthKitMetric: String, Codable, CaseIterable, Identifiable {
    case steps
    case water
    case sleep
    case exercise
    case mindfulness
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .steps: return L10n.t("health.metric.steps")
        case .water: return L10n.t("health.metric.water")
        case .sleep: return L10n.t("health.metric.sleep")
        case .exercise: return L10n.t("health.metric.exercise")
        case .mindfulness: return L10n.t("health.metric.mindfulness")
        }
    }
    
    var unitName: String {
        switch self {
        case .steps: return L10n.t("health.unit.steps")
        case .water: return L10n.t("health.unit.water") // Liters or mL
        case .sleep: return L10n.t("health.unit.hours")
        case .exercise: return L10n.t("health.unit.minutes")
        case .mindfulness: return L10n.t("health.unit.minutes")
        }
    }
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .water: return "drop.fill"
        case .sleep: return "bed.double.fill"
        case .exercise: return "figure.run"
        case .mindfulness: return "brain.head.profile"
        }
    }
}

