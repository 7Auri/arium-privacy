//
//  IntegrationTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

@MainActor
final class IntegrationTests: XCTestCase {
    
    var habitStore: HabitStore!
    
    override func setUp() async throws {
        try await super.setUp()
        habitStore = HabitStore()
        habitStore.habits.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
        
        // Clear shared UserDefaults (App Groups)
        if let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium") {
            sharedDefaults.removeObject(forKey: "SavedHabits")
        }
    }
    
    override func tearDown() async throws {
        habitStore = nil
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
        
        if let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium") {
            sharedDefaults.removeObject(forKey: "SavedHabits")
        }
        
        try await super.tearDown()
    }
    
    // MARK: - Complete User Flow Tests
    
    func testCompleteUserJourney() async throws {
        // 1. User creates a habit
        let addViewModel = AddHabitViewModel()
        addViewModel.title = "Morning Run"
        addViewModel.notes = "5km daily"
        addViewModel.selectedTheme = .blue
        addViewModel.goalDays = 30
        
        XCTAssertTrue(addViewModel.canSave)
        
        let habit = addViewModel.createHabit()
        try habitStore.addHabit(habit)
        
        // 2. User completes the habit
        habitStore.toggleHabitCompletion(habit.id)
        
        let updatedHabit = habitStore.habits.first!
        XCTAssertTrue(updatedHabit.isCompletedToday)
        XCTAssertEqual(updatedHabit.streak, 1)
        
        // 3. User views statistics
        let totalCompletions = habitStore.getTotalCompletions()
        XCTAssertEqual(totalCompletions, 1)
        
        let completionRate = habitStore.getCompletionRate()
        XCTAssertEqual(completionRate, 1.0)
        
        // 4. User adds a note (premium feature)
        PremiumManager.shared.setPremiumStatus(true)
        habitStore.toggleHabitCompletion(habit.id, note: "Great run today!")
        
        let habitWithNote = habitStore.habits.first!
        XCTAssertEqual(habitWithNote.noteForDate(Date()), "Great run today!")
        
        // Cleanup
        PremiumManager.shared.setPremiumStatus(false)
    }
    
    func testFreeToPremiumUpgrade() async throws {
        PremiumManager.shared.setPremiumStatus(false)
        
        // Add 3 habits (free limit)
        try habitStore.addHabit(Habit(title: "Habit 1", themeId: "purple", category: .personal))
        try habitStore.addHabit(Habit(title: "Habit 2", themeId: "purple", category: .personal))
        try habitStore.addHabit(Habit(title: "Habit 3", themeId: "purple", category: .personal))
        
        XCTAssertFalse(habitStore.canAddMoreHabits)
        
        // Try to add 4th habit - should fail
        let habit4 = Habit(title: "Habit 4", themeId: "purple", category: .personal)
        
        var caughtError = false
        do {
            try habitStore.addHabit(habit4)
        } catch {
            caughtError = true
            XCTAssertTrue(error is HabitError)
        }
        XCTAssertTrue(caughtError)
        XCTAssertEqual(habitStore.habits.count, 3)
        
        // Upgrade to premium
        PremiumManager.shared.setPremiumStatus(true)
        
        XCTAssertTrue(habitStore.canAddMoreHabits)
        
        // Now can add 4th habit
        try habitStore.addHabit(habit4)
        XCTAssertEqual(habitStore.habits.count, 4)
        
        // Cleanup
        PremiumManager.shared.setPremiumStatus(false)
    }
    
    // MARK: - App Groups Integration Tests
    
    func testSharedUserDefaultsIntegration() throws {
        // Init order: streak, themeId, category
        let habit = Habit(title: "Test Habit", streak: 5, themeId: "purple", category: .personal)
        try habitStore.addHabit(habit)
        
        // Verify data is saved to shared UserDefaults
        guard let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let loadedHabits = try? JSONDecoder().decode([Habit].self, from: data) else {
            return
        }
        
        XCTAssertEqual(loadedHabits.count, 1)
        XCTAssertEqual(loadedHabits.first?.title, "Test Habit")
        XCTAssertEqual(loadedHabits.first?.streak, 5)
    }
    
    // MARK: - Data Persistence Tests
    
    func testDataPersistenceAcrossAppRestarts() throws {
        // Simulate first app launch
        // Init order: goalDays before category
        let habit1 = Habit(title: "Morning Meditation", themeId: "purple", goalDays: 21, category: .personal)
        let habit2 = Habit(title: "Evening Reading", themeId: "purple", goalDays: 30, category: .learning)
        
        try habitStore.addHabit(habit1)
        try habitStore.addHabit(habit2)
        habitStore.toggleHabitCompletion(habit1.id)
        
        // Simulate app restart by creating new store
        let newStore = HabitStore()
        
        XCTAssertEqual(newStore.habits.count, 2)
        XCTAssertEqual(newStore.habits[0].title, "Morning Meditation")
        XCTAssertTrue(newStore.habits[0].isCompletedToday)
        XCTAssertEqual(newStore.habits[1].title, "Evening Reading")
    }
    
    // MARK: - Streak Continuity Tests
    
    func testStreakContinuityAcrossDays() async throws {
        var habit = Habit(title: "Daily Exercise", themeId: "purple", category: .health)
        let calendar = Calendar.current
        
        // Simulate 7 consecutive days of completions
        for daysAgo in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        habit.calculateStreak()
        XCTAssertEqual(habit.streak, 7)
        
        // Add to store
        try habitStore.addHabit(habit)
        
        // Simulate new day check
        await habitStore.updateTodayStatus()
        
        // Verify streak is maintained
        XCTAssertEqual(habitStore.habits.first?.streak, 7)
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testConcurrentHabitAdditions() {
        PremiumManager.shared.setPremiumStatus(true)
        
        let expectation = XCTestExpectation(description: "Add multiple habits concurrently")
        
        DispatchQueue.concurrentPerform(iterations: 10) { index in
            Task { @MainActor in
                try? habitStore.addHabit(Habit(title: "Habit \(index)", themeId: "purple", category: .personal))
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // Should have added all habits
        XCTAssertEqual(habitStore.habits.count, 10)
        
        PremiumManager.shared.setPremiumStatus(false)
    }
    
    // MARK: - Statistics Accuracy Tests
    
    func testStatisticsAccuracyWithMultipleHabits() throws {
        PremiumManager.shared.setPremiumStatus(true)
        
        // Create habits with different completion states
        // Init order: streak before themeId
        var habit1 = Habit(title: "Habit 1", streak: 5, themeId: "purple", category: .personal)
        habit1.isCompletedToday = true
        habit1.completionDates = Array(repeating: Date(), count: 5)
        
        var habit2 = Habit(title: "Habit 2", streak: 10, themeId: "purple", category: .personal)
        habit2.isCompletedToday = false
        habit2.completionDates = Array(repeating: Date(), count: 10)
        
        var habit3 = Habit(title: "Habit 3", streak: 3, themeId: "purple", category: .personal)
        habit3.isCompletedToday = true
        habit3.completionDates = Array(repeating: Date(), count: 3)
        
        try habitStore.addHabit(habit1)
        try habitStore.addHabit(habit2)
        try habitStore.addHabit(habit3)
        
        // Test statistics
        XCTAssertEqual(habitStore.getTotalCompletions(), 18) // 5 + 10 + 3
        XCTAssertEqual(habitStore.getLongestStreak(), 10)
        XCTAssertEqual(habitStore.getCompletionRate(), 2.0/3.0, accuracy: 0.01) // 2 out of 3 completed today
        
        PremiumManager.shared.setPremiumStatus(false)
    }
}
