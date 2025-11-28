//
//  AchievementManager.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation
import Combine

@MainActor
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var unlockedAchievements: [UnlockedAchievement] = []
    @Published var userXP: Int = 0
    @Published var userLevel: Int = 1
    @Published var showingUnlockAlert: Bool = false
    @Published var latestUnlockedAchievement: Achievement?
    
    private let saveKey = "UnlockedAchievements"
    private let xpKey = "UserXP"
    
    private init() {
        loadUnlockedAchievements()
    }
    
    // MARK: - Save/Load
    
    private func loadUnlockedAchievements() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([UnlockedAchievement].self, from: data) {
            unlockedAchievements = decoded
        }
        
        userXP = UserDefaults.standard.integer(forKey: xpKey)
        userLevel = calculateLevel(from: userXP)
    }
    
    private func saveUnlockedAchievements() {
        if let encoded = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
        
        UserDefaults.standard.set(userXP, forKey: xpKey)
    }
    
    // MARK: - Check Achievements
    
    func checkAchievements(habits: [Habit], isPremium: Bool) {
        let newAchievements = checkAllAchievements(habits: habits, isPremium: isPremium)
        
        for achievement in newAchievements {
            unlockAchievement(achievement)
        }
    }
    
    private func checkAllAchievements(habits: [Habit], isPremium: Bool) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        
        for achievement in Achievement.allAchievements {
            // Skip if already unlocked
            if isAchievementUnlocked(achievement.id) {
                continue
            }
            
            // Skip premium achievements for free users
            if achievement.isPremium && !isPremium {
                continue
            }
            
            // Check if achievement should be unlocked
            if shouldUnlockAchievement(achievement, habits: habits, isPremium: isPremium) {
                newlyUnlocked.append(achievement)
            }
        }
        
        return newlyUnlocked
    }
    
    private func shouldUnlockAchievement(_ achievement: Achievement, habits: [Habit], isPremium: Bool) -> Bool {
        switch achievement.category {
        case .streak:
            return checkStreakAchievement(achievement, habits: habits)
        case .completion:
            return checkCompletionAchievement(achievement, habits: habits)
        case .consistency:
            return checkConsistencyAchievement(achievement, habits: habits)
        case .variety:
            return checkVarietyAchievement(achievement, habits: habits)
        case .premium:
            return checkPremiumAchievement(achievement, isPremium: isPremium)
        case .social:
            return false // Future implementation
        }
    }
    
    // MARK: - Achievement Checks
    
    private func checkStreakAchievement(_ achievement: Achievement, habits: [Habit]) -> Bool {
        let maxStreak = habits.map { $0.streak }.max() ?? 0
        return maxStreak >= achievement.targetValue
    }
    
    private func checkCompletionAchievement(_ achievement: Achievement, habits: [Habit]) -> Bool {
        let totalCompletions = habits.reduce(0) { $0 + $1.completionDates.count }
        return totalCompletions >= achievement.targetValue
    }
    
    private func checkConsistencyAchievement(_ achievement: Achievement, habits: [Habit]) -> Bool {
        if achievement.id == "perfect_week" {
            return checkPerfectWeek(habits: habits)
        } else if achievement.id == "perfect_month" {
            return checkPerfectMonth(habits: habits)
        }
        return false
    }
    
    private func checkVarietyAchievement(_ achievement: Achievement, habits: [Habit]) -> Bool {
        if achievement.id == "multi_category" {
            let uniqueCategories = Set(habits.map { $0.category })
            return uniqueCategories.count >= achievement.targetValue
        } else if achievement.id == "habit_master" {
            return habits.count >= achievement.targetValue
        }
        return false
    }
    
    private func checkPremiumAchievement(_ achievement: Achievement, isPremium: Bool) -> Bool {
        if achievement.id == "premium_member" {
            return isPremium
        }
        // template_creator will be checked when user creates a template
        return false
    }
    
    private func checkPerfectWeek(habits: [Habit]) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return false }
        
        // Check if all habits were completed every day in the last 7 days
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            for habit in habits {
                let dayStart = calendar.startOfDay(for: day)
                let completedOnDay = habit.completionDates.contains { calendar.isDate($0, inSameDayAs: day) }
                
                // Check if habit existed on that day
                let habitExistedOnDay = habit.createdAt <= dayStart
                
                if habitExistedOnDay && !completedOnDay {
                    return false
                }
            }
        }
        
        return !habits.isEmpty
    }
    
    private func checkPerfectMonth(habits: [Habit]) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        guard let monthAgo = calendar.date(byAdding: .day, value: -30, to: today) else { return false }
        
        for dayOffset in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            for habit in habits {
                let dayStart = calendar.startOfDay(for: day)
                let completedOnDay = habit.completionDates.contains { calendar.isDate($0, inSameDayAs: day) }
                let habitExistedOnDay = habit.createdAt <= dayStart
                
                if habitExistedOnDay && !completedOnDay {
                    return false
                }
            }
        }
        
        return !habits.isEmpty
    }
    
    // MARK: - Unlock Achievement
    
    func unlockAchievement(_ achievement: Achievement) {
        let unlocked = UnlockedAchievement(achievementId: achievement.id)
        unlockedAchievements.append(unlocked)
        
        // Add XP
        userXP += achievement.xpReward
        userLevel = calculateLevel(from: userXP)
        
        // Show unlock alert
        latestUnlockedAchievement = achievement
        showingUnlockAlert = true
        
        // Haptic feedback
        HapticManager.success()
        
        saveUnlockedAchievements()
        
        print("🏆 Achievement Unlocked: \(achievement.title) (+\(achievement.xpReward) XP)")
    }
    
    // MARK: - Helpers
    
    func isAchievementUnlocked(_ achievementId: String) -> Bool {
        unlockedAchievements.contains { $0.achievementId == achievementId }
    }
    
    func getProgress(for achievement: Achievement, habits: [Habit]) -> (current: Int, target: Int) {
        let current: Int
        
        switch achievement.category {
        case .streak:
            current = habits.map { $0.streak }.max() ?? 0
        case .completion:
            current = habits.reduce(0) { $0 + $1.completionDates.count }
        case .variety:
            if achievement.id == "multi_category" {
                current = Set(habits.map { $0.category }).count
            } else {
                current = habits.count
            }
        default:
            current = 0
        }
        
        return (current, achievement.targetValue)
    }
    
    func calculateLevel(from xp: Int) -> Int {
        // XP to Level formula: level = sqrt(xp / 100) + 1
        return Int(sqrt(Double(xp) / 100.0)) + 1
    }
    
    func xpForNextLevel() -> Int {
        let nextLevel = userLevel + 1
        return (nextLevel - 1) * (nextLevel - 1) * 100
    }
    
    func xpProgressInCurrentLevel() -> Double {
        let currentLevelXP = (userLevel - 1) * (userLevel - 1) * 100
        let nextLevelXP = xpForNextLevel()
        let progressXP = userXP - currentLevelXP
        let requiredXP = nextLevelXP - currentLevelXP
        
        return Double(progressXP) / Double(requiredXP)
    }
    
    // MARK: - Mark as Seen
    
    func markAchievementAsSeen(_ achievementId: String) {
        if let index = unlockedAchievements.firstIndex(where: { $0.achievementId == achievementId }) {
            unlockedAchievements[index].isNew = false
            saveUnlockedAchievements()
        }
    }
    
    func markAllAsSeen() {
        for index in unlockedAchievements.indices {
            unlockedAchievements[index].isNew = false
        }
        saveUnlockedAchievements()
    }
    
    var newAchievementsCount: Int {
        unlockedAchievements.filter { $0.isNew }.count
    }
}

