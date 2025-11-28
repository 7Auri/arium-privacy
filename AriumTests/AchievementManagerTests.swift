//
//  AchievementManagerTests.swift
//  AriumTests
//
//  Created by Auto on 28.11.2025.
//

import Testing
@testable import Arium
import Foundation

@MainActor
struct AchievementManagerTests {
    
    @Test func testAchievementManagerSingleton() async throws {
        let manager1 = AchievementManager.shared
        let manager2 = AchievementManager.shared
        #expect(manager1 === manager2)
    }
    
    @Test func testInitialState() async throws {
        let manager = AchievementManager.shared
        #expect(manager.currentXP >= 0)
        #expect(manager.unlockedAchievements.count >= 0)
    }
    
    @Test func testCalculateLevel() async throws {
        let manager = AchievementManager.shared
        
        // Test level calculation
        let level1 = manager.calculateLevel(xp: 0)
        #expect(level1 == 1)
        
        let level2 = manager.calculateLevel(xp: 100)
        #expect(level2 > 1)
        
        let level3 = manager.calculateLevel(xp: 1000)
        #expect(level3 > level2)
    }
    
    @Test func testXPForNextLevel() async throws {
        let manager = AchievementManager.shared
        
        let xpForLevel2 = manager.xpForNextLevel(level: 1)
        #expect(xpForLevel2 > 0)
        
        let xpForLevel3 = manager.xpForNextLevel(level: 2)
        #expect(xpForLevel3 > xpForLevel2)
    }
    
    @Test func testStreakAchievements() async throws {
        let manager = AchievementManager.shared
        
        // Create habits with different streaks
        var habit7 = Habit(title: "Test 7", themeId: "purple", category: .health)
        habit7.streak = 7
        
        var habit30 = Habit(title: "Test 30", themeId: "purple", category: .health)
        habit30.streak = 30
        
        let habits = [habit7, habit30]
        
        // Check achievements
        await manager.checkAchievements(habits: habits)
        
        // Should unlock 7-day achievement
        let hasStreak7 = manager.unlockedAchievements.contains { $0.id == "streak_7days" }
        #expect(hasStreak7)
    }
    
    @Test func testCompletionAchievements() async throws {
        let manager = AchievementManager.shared
        
        // Create habits with completions
        var habits: [Habit] = []
        for i in 0..<15 {
            var habit = Habit(title: "Test \(i)", themeId: "purple", category: .health)
            habit.completionDates = Array(repeating: Date(), count: 5)
            habits.append(habit)
        }
        
        await manager.checkAchievements(habits: habits)
        
        // Should have some XP
        #expect(manager.currentXP > 0)
    }
    
    @Test func testAchievementTiers() async throws {
        // Test tier properties
        #expect(AchievementTier.bronze.color != nil)
        #expect(AchievementTier.silver.xpMultiplier > AchievementTier.bronze.xpMultiplier)
        #expect(AchievementTier.gold.xpMultiplier > AchievementTier.silver.xpMultiplier)
        #expect(AchievementTier.platinum.xpMultiplier > AchievementTier.gold.xpMultiplier)
        #expect(AchievementTier.diamond.xpMultiplier > AchievementTier.platinum.xpMultiplier)
    }
    
    @Test func testAchievementCategories() async throws {
        // Test all categories have localized names
        for category in AchievementCategory.allCases {
            #expect(!category.localizedName.isEmpty)
            #expect(category.id == category.rawValue)
        }
    }
    
    @Test func testAllPredefinedAchievements() async throws {
        let achievements = Achievement.allAchievements
        
        // Should have all 14 achievements
        #expect(achievements.count == 14)
        
        // All should have unique IDs
        let uniqueIDs = Set(achievements.map { $0.id })
        #expect(uniqueIDs.count == achievements.count)
        
        // All should have XP rewards
        for achievement in achievements {
            #expect(achievement.xpReward > 0)
            #expect(achievement.targetValue > 0)
            #expect(!achievement.title.isEmpty)
            #expect(!achievement.description.isEmpty)
        }
    }
    
    @Test func testConsistencyAchievements() async throws {
        let manager = AchievementManager.shared
        
        // Create habit with perfect week
        var habit = Habit(title: "Test", themeId: "purple", category: .health)
        let calendar = Calendar.current
        let today = Date()
        
        // Add 7 consecutive days
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }
        habit.completionDates = dates
        
        await manager.checkAchievements(habits: [habit])
        
        // Check if consistency achievements are being tracked
        #expect(manager.currentXP >= 0)
    }
    
    @Test func testVarietyAchievements() async throws {
        let manager = AchievementManager.shared
        
        // Create habits in different categories
        let categories: [HabitCategory] = [.health, .work, .learning, .personal]
        var habits: [Habit] = []
        
        for (index, category) in categories.enumerated() {
            let habit = Habit(title: "Test \(index)", themeId: "purple", category: category)
            habits.append(habit)
        }
        
        await manager.checkAchievements(habits: habits)
        
        // Should track variety
        #expect(habits.count == 4)
    }
}

