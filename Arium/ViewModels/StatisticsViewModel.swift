//
//  StatisticsViewModel.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var dailyStats: [DailyStat] = []
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var totalCompletions: Int = 0
    @Published var completionRate: Double = 0.0
    
    let habit: Habit?
    let habits: [Habit]
    let isPremium: Bool
    let daysToShow: Int
    
    // Single habit statistics
    init(habit: Habit, isPremium: Bool) {
        self.habit = habit
        self.habits = []
        self.isPremium = isPremium
        self.daysToShow = isPremium ? 30 : 7
        calculateStatistics()
    }
    
    // All habits statistics
    init(habits: [Habit], isPremium: Bool) {
        self.habit = nil
        self.habits = habits
        self.isPremium = isPremium
        self.daysToShow = isPremium ? 30 : 7
        calculateAllHabitsStatistics()
    }
    
    private func calculateStatistics() {
        guard let habit = habit else { return }
        
        dailyStats = generateLast30Days(for: habit)
        currentStreak = habit.streak
        bestStreak = calculateBestStreak(for: habit)
        totalCompletions = habit.completionDates.count
        completionRate = calculateCompletionRate(for: habit)
    }
    
    private func calculateAllHabitsStatistics() {
        dailyStats = generateLast30DaysForAllHabits()
        currentStreak = calculateCurrentStreakForAllHabits()
        bestStreak = calculateBestStreakForAllHabits()
        totalCompletions = habits.reduce(0) { $0 + $1.completionDates.count }
        completionRate = calculateCompletionRateForAllHabits()
    }
    
    // MARK: - Single Habit Methods
    
    func generateLast30Days(for habit: Habit) -> [DailyStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<daysToShow).reversed().map { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return DailyStat(date: Date(), completed: false)
            }
            
            let isCompleted = habit.completionDates.contains { completionDate in
                calendar.isDate(completionDate, inSameDayAs: date)
            }
            
            let count = habit.completionDates.filter { completionDate in
                calendar.isDate(completionDate, inSameDayAs: date)
            }.count
            
            return DailyStat(date: date, completed: isCompleted, completionCount: count)
        }
    }
    
    func calculateBestStreak(for habit: Habit) -> Int {
        guard !habit.completionDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = habit.completionDates
            .map { calendar.startOfDay(for: $0) }
            .sorted()
        
        var maxStreak = 1
        var currentStreakCount = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if let dayDifference = calendar.dateComponents([.day], from: previousDate, to: currentDate).day {
                if dayDifference == 1 {
                    currentStreakCount += 1
                    maxStreak = max(maxStreak, currentStreakCount)
                } else if dayDifference > 1 {
                    currentStreakCount = 1
                }
                // If same day, don't change streak count
            }
        }
        
        return maxStreak
    }
    
    func calculateCompletionRate(for habit: Habit) -> Double {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: habit.effectiveStartDate, to: Date()).day ?? 0
        let totalDays = max(1, daysSinceStart + 1) // En az 1 gün olarak hesapla
        return Double(habit.completionDates.count) / Double(totalDays)
    }
    
    // MARK: - All Habits Methods
    
    func generateLast30DaysForAllHabits() -> [DailyStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<daysToShow).reversed().map { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return DailyStat(date: Date(), completed: false)
            }
            
            var totalCompletionsForDay = 0
            var hasAnyCompletion = false
            
            for habit in habits {
                let completionsOnThisDay = habit.completionDates.filter { completionDate in
                    calendar.isDate(completionDate, inSameDayAs: date)
                }.count
                
                if completionsOnThisDay > 0 {
                    hasAnyCompletion = true
                    totalCompletionsForDay += completionsOnThisDay
                }
            }
            
            return DailyStat(date: date, completed: hasAnyCompletion, completionCount: totalCompletionsForDay)
        }
    }
    
    func calculateCurrentStreakForAllHabits() -> Int {
        guard !habits.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        
        for daysAgo in 0..<365 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { break }
            
            let hasAnyCompletion = habits.contains { habit in
                habit.completionDates.contains { completionDate in
                    calendar.isDate(completionDate, inSameDayAs: date)
                }
            }
            
            if hasAnyCompletion {
                streak += 1
            } else if daysAgo > 0 {
                // If not today and no completion, break
                break
            } else {
                // Today has no completion, check yesterday
                continue
            }
        }
        
        return streak
    }
    
    func calculateBestStreakForAllHabits() -> Int {
        return habits.map { calculateBestStreak(for: $0) }.max() ?? 0
    }
    
    func calculateCompletionRateForAllHabits() -> Double {
        guard !habits.isEmpty else { return 0 }
        
        let rates = habits.map { calculateCompletionRate(for: $0) }
        return rates.reduce(0, +) / Double(habits.count)
    }
    
    // MARK: - Helper Methods
    
    func getWeekdayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    func getMonthDay(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

