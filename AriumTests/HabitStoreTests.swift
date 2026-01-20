//
//  HabitStoreTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

@MainActor
final class HabitStoreTests: XCTestCase {
    
    var habitStore: HabitStore!
    
    override func setUp() {
        super.setUp()
        habitStore = HabitStore()
        // Clear all habits before each test
        habitStore.habits.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
        UserDefaults.standard.removeObject(forKey: "isPremium")
        UserDefaults.standard.removeObject(forKey: "isTestPremium")
    }
    
    override func tearDown() {
        habitStore = nil
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
        UserDefaults.standard.removeObject(forKey: "isPremium")
        UserDefaults.standard.removeObject(forKey: "isTestPremium")
        super.tearDown()
    }
    
    // MARK: - Add Habit Tests
    
    func testAddHabit() throws {
        let habit = Habit(title: "Read Books")
        
        try habitStore.addHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 1)
        XCTAssertEqual(habitStore.habits.first?.title, "Read Books")
    }
    
    func testAddMultipleHabits() throws {
        let habit1 = Habit(title: "Read")
        let habit2 = Habit(title: "Exercise")
        let habit3 = Habit(title: "Meditate")
        
        try habitStore.addHabit(habit1)
        try habitStore.addHabit(habit2)
        try habitStore.addHabit(habit3)
        
        XCTAssertEqual(habitStore.habits.count, 3)
    }
    
    // MARK: - Free Tier Limit Tests
    
    func testCanAddMoreHabitsWhenFree() throws {
        PremiumManager.shared.setPremiumStatus(false)
        
        XCTAssertTrue(habitStore.canAddMoreHabits)
        XCTAssertEqual(habitStore.remainingFreeSlots, 3)
        
        try habitStore.addHabit(Habit(title: "Habit 1"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 2)
        
        try habitStore.addHabit(Habit(title: "Habit 2"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 1)
        
        try habitStore.addHabit(Habit(title: "Habit 3"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 0)
        XCTAssertFalse(habitStore.canAddMoreHabits)
    }
    
    func testCannotAddMoreThan3HabitsWhenFree() throws {
        PremiumManager.shared.setPremiumStatus(false)
        
        try habitStore.addHabit(Habit(title: "Habit 1"))
        try habitStore.addHabit(Habit(title: "Habit 2"))
        try habitStore.addHabit(Habit(title: "Habit 3"))
        
        // Should throw error when trying to add 4th habit
        XCTAssertThrowsError(try habitStore.addHabit(Habit(title: "Habit 4"))) { error in
            XCTAssertTrue(error is HabitError)
        }
        
        XCTAssertEqual(habitStore.habits.count, 3)
    }
    
    func testCanAddUnlimitedHabitsWhenPremium() throws {
        PremiumManager.shared.setPremiumStatus(true)
        
        for i in 1...10 {
            try habitStore.addHabit(Habit(title: "Habit \(i)"))
        }
        
        XCTAssertEqual(habitStore.habits.count, 10)
        XCTAssertTrue(habitStore.canAddMoreHabits)
    }
    
    // MARK: - Update Habit Tests
    
    func testUpdateHabit() throws {
        var habit = Habit(title: "Read Books")
        try habitStore.addHabit(habit)
        
        habit.title = "Read 30 Pages"
        habitStore.updateHabit(habit)
        
        XCTAssertEqual(habitStore.habits.first?.title, "Read 30 Pages")
    }
    
    func testUpdateNonExistentHabit() {
        let habit = Habit(title: "Ghost Habit")
        
        habitStore.updateHabit(habit)
        
        // Should not crash, just do nothing
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    // MARK: - Delete Habit Tests
    
    func testDeleteHabit() throws {
        let habit = Habit(title: "Read Books")
        try habitStore.addHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 1)
        
        habitStore.deleteHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    func testDeleteHabitRestoresFreeSlots() throws {
        PremiumManager.shared.setPremiumStatus(false)
        
        let habit1 = Habit(title: "Habit 1")
        let habit2 = Habit(title: "Habit 2")
        let habit3 = Habit(title: "Habit 3")
        
        try habitStore.addHabit(habit1)
        try habitStore.addHabit(habit2)
        try habitStore.addHabit(habit3)
        
        XCTAssertFalse(habitStore.canAddMoreHabits)
        
        habitStore.deleteHabit(habit1)
        
        XCTAssertTrue(habitStore.canAddMoreHabits)
        XCTAssertEqual(habitStore.remainingFreeSlots, 1)
    }
    
    // MARK: - Toggle Completion Tests
    
    func testToggleHabitCompletion() throws {
        let habit = Habit(title: "Read Books")
        try habitStore.addHabit(habit)
        
        XCTAssertFalse(habitStore.habits.first!.isCompletedToday)
        
        habitStore.toggleHabitCompletion(habit.id)
        
        XCTAssertTrue(habitStore.habits.first!.isCompletedToday)
    }
    
    func testToggleHabitCompletionWithNote() throws {
        PremiumManager.shared.setPremiumStatus(true)
        let habit = Habit(title: "Read Books")
        try habitStore.addHabit(habit)
        
        habitStore.toggleHabitCompletion(habit.id, note: "Great progress!")
        
        let updatedHabit = habitStore.habits.first!
        XCTAssertTrue(updatedHabit.isCompletedToday)
        XCTAssertEqual(updatedHabit.noteForDate(Date()), "Great progress!")
    }
    
    func testToggleHabitCompletionOnSpecificDate() throws {
        let habit = Habit(title: "Read Books")
        try habitStore.addHabit(habit)
        
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else {
            XCTFail("Could not calculate yesterday")
            return
        }
        
        // Toggle for yesterday
        habitStore.toggleHabitCompletion(habit.id, date: yesterday)
        
        // Should NOT be completed today
        XCTAssertFalse(habitStore.habits.first!.isCompletedToday)
        
        // Completions should contain yesterday
        XCTAssertTrue(habitStore.habits.first!.completionDates.contains {
            calendar.isDate($0, inSameDayAs: yesterday)
        })
        
        // Streak should be updated?
        // If completed yesterday but not today, streak should be preserved?
        // Default streak calc might handle it if yesterday is present.
        // Let's check streak > 0
        XCTAssertTrue(habitStore.habits.first!.streak > 0)
    }
    
    // MARK: - Statistics Tests
    
    func testGetTotalCompletions() throws {
        var habit1 = Habit(title: "Read")
        habit1.completionDates = [Date(), Date()]
        
        var habit2 = Habit(title: "Exercise")
        habit2.completionDates = [Date(), Date(), Date()]
        
        try habitStore.addHabit(habit1)
        try habitStore.addHabit(habit2)
        
        XCTAssertEqual(habitStore.getTotalCompletions(), 5)
    }
    
    func testGetLongestStreak() throws {
        var habit1 = Habit(title: "Read", streak: 5)
        var habit2 = Habit(title: "Exercise", streak: 12)
        var habit3 = Habit(title: "Meditate", streak: 3)
        
        try habitStore.addHabit(habit1)
        try habitStore.addHabit(habit2)
        try habitStore.addHabit(habit3)
        
        XCTAssertEqual(habitStore.getLongestStreak(), 12)
    }
    
    func testGetCompletionRate() throws {
        var habit1 = Habit(title: "Read")
        habit1.isCompletedToday = true
        
        var habit2 = Habit(title: "Exercise")
        habit2.isCompletedToday = false
        
        var habit3 = Habit(title: "Meditate")
        habit3.isCompletedToday = true
        
        try habitStore.addHabit(habit1)
        try habitStore.addHabit(habit2)
        try habitStore.addHabit(habit3)
        
        let rate = habitStore.getCompletionRate()
        XCTAssertEqual(rate, 2.0/3.0, accuracy: 0.01)
    }
    
    func testGetCompletionRateWhenEmpty() {
        XCTAssertEqual(habitStore.getCompletionRate(), 0.0)
    }
    
    // MARK: - Update Today Status Tests
    
    func testPartialCompletionPersistence() async throws {
        var habit = Habit(title: "Multi-step Habit", dailyRepetitions: 2)
        habit.id = UUID()
        let calendar = Calendar.current
        
        // 1. Setup: Habit created today, one repetition completed today
        habit.todayCompletions = [0] // First repetition done
        habit.updatedAt = Date() // Updated just now
        
        try habitStore.addHabit(habit)
        
        // Verify initial state
        guard let savedHabit = habitStore.habits.first else {
            XCTFail("Habit not saved")
            return
        }
        XCTAssertEqual(savedHabit.todayCompletions, [0], "Initial state should have 1 completion")
        
        // 2. Simulate App Foregrounding (calls updateTodayStatus)
        await habitStore.updateTodayStatus()
        
        // 3. Verify persistence
        // Expected: [0] should remain because it was updated today
        // Actual (Bug): Cleared because completionDates (full completion) is empty
        if let updatedHabit = habitStore.habits.first {
            XCTAssertEqual(updatedHabit.todayCompletions, [0], "Partial completion should be persisted if updated today")
        }
    }

    func testUpdateTodayStatus() async throws {
        var habit = Habit(title: "Read")
        let calendar = Calendar.current
        
        // Add a completion from yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            habit.completionDates = [yesterday]
            habit.isCompletedToday = true // Manually set (simulating old state)
        }
        
        try habitStore.addHabit(habit)
        await habitStore.updateTodayStatus()
        
        // Should be false now since last completion was yesterday
        XCTAssertFalse(habitStore.habits.first!.isCompletedToday)
    }
    
    // MARK: - Validation Tests
    
    func testAddHabitWithEmptyTitle() {
        var habit = Habit(title: "")
        
        XCTAssertThrowsError(try habitStore.addHabit(habit)) { error in
            XCTAssertTrue(error is HabitError)
            if let habitError = error as? HabitError {
                XCTAssertEqual(habitError, HabitError.emptyTitle)
            }
        }
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    func testAddHabitWithWhitespaceOnlyTitle() {
        var habit = Habit(title: "   ")
        
        XCTAssertThrowsError(try habitStore.addHabit(habit)) { error in
            XCTAssertTrue(error is HabitError)
        }
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    func testAddHabitWithNotesTooLong() {
        var habit = Habit(title: "Read")
        habit.notes = String(repeating: "a", count: 101) // 101 characters
        
        XCTAssertThrowsError(try habitStore.addHabit(habit)) { error in
            XCTAssertTrue(error is HabitError)
            if let habitError = error as? HabitError {
                if case .notesTooLong(let maxLength) = habitError {
                    XCTAssertEqual(maxLength, 100)
                } else {
                    XCTFail("Expected notesTooLong error")
                }
            }
        }
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    func testAddHabitWithValidNotesLength() {
        var habit = Habit(title: "Read")
        habit.notes = String(repeating: "a", count: 100) // Exactly 100 characters
        
        XCTAssertNoThrow(try habitStore.addHabit(habit))
        XCTAssertEqual(habitStore.habits.count, 1)
    }
    
    func testAddHabitWithFutureStartDate() {
        var habit = Habit(title: "Read")
        habit.startDate = Date().addingTimeInterval(86400) // Tomorrow
        
        XCTAssertThrowsError(try habitStore.addHabit(habit)) { error in
            XCTAssertTrue(error is HabitError)
            if let habitError = error as? HabitError {
                XCTAssertEqual(habitError, HabitError.invalidStartDate)
            }
        }
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    func testAddHabitWithPastStartDate() {
        var habit = Habit(title: "Read")
        habit.startDate = Date().addingTimeInterval(-86400) // Yesterday
        
        XCTAssertNoThrow(try habitStore.addHabit(habit))
        XCTAssertEqual(habitStore.habits.count, 1)
    }
    
    func testAddHabitWithTodayStartDate() {
        var habit = Habit(title: "Read")
        habit.startDate = Date()
        
        XCTAssertNoThrow(try habitStore.addHabit(habit))
        XCTAssertEqual(habitStore.habits.count, 1)
    }
    
    // MARK: - Persistence Tests
    
    func testHabitsPersistence() throws {
        let habit = Habit(title: "Read Books", goalDays: 30)
        try habitStore.addHabit(habit)
        
        // Create a new store instance (simulating app restart)
        let newStore = HabitStore()
        
        XCTAssertEqual(newStore.habits.count, 1)
        XCTAssertEqual(newStore.habits.first?.title, "Read Books")
        XCTAssertEqual(newStore.habits.first?.goalDays, 30)
    }
}
