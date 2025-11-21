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
    
    override func setUp() async throws {
        try await super.setUp()
        habitStore = HabitStore()
        habitStore.habits.removeAll() // Clear any existing habits
    }
    
    override func tearDown() async throws {
        habitStore.habits.removeAll()
        habitStore = nil
        try await super.tearDown()
    }
    
    // MARK: - Add Habit Tests
    
    func testAddHabitSuccess() {
        habitStore.isPremium = true
        let habit = Habit(title: "Read")
        
        habitStore.addHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 1)
        XCTAssertEqual(habitStore.habits.first?.title, "Read")
    }
    
    func testAddHabitFailsWhenFreeAndLimitReached() {
        habitStore.isPremium = false
        
        // Add 3 habits (free limit)
        habitStore.addHabit(Habit(title: "Habit 1"))
        habitStore.addHabit(Habit(title: "Habit 2"))
        habitStore.addHabit(Habit(title: "Habit 3"))
        
        XCTAssertEqual(habitStore.habits.count, 3)
        
        // Try to add 4th habit
        habitStore.addHabit(Habit(title: "Habit 4"))
        
        XCTAssertEqual(habitStore.habits.count, 3) // Should still be 3
    }
    
    func testAddHabitSucceedsWhenPremium() {
        habitStore.isPremium = true
        
        // Add more than 3 habits
        for i in 1...10 {
            habitStore.addHabit(Habit(title: "Habit \(i)"))
        }
        
        XCTAssertEqual(habitStore.habits.count, 10)
    }
    
    // MARK: - Update Habit Tests
    
    func testUpdateHabit() {
        let habit = Habit(title: "Original Title")
        habitStore.addHabit(habit)
        
        var updatedHabit = habit
        updatedHabit.title = "Updated Title"
        
        habitStore.updateHabit(updatedHabit)
        
        XCTAssertEqual(habitStore.habits.first?.title, "Updated Title")
    }
    
    func testUpdateNonExistentHabit() {
        let habit = Habit(title: "Test")
        
        habitStore.updateHabit(habit) // Should not crash
        
        XCTAssertTrue(habitStore.habits.isEmpty)
    }
    
    // MARK: - Delete Habit Tests
    
    func testDeleteHabit() {
        let habit = Habit(title: "To Delete")
        habitStore.addHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 1)
        
        habitStore.deleteHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    func testDeleteNonExistentHabit() {
        habitStore.addHabit(Habit(title: "Keep This"))
        let nonExistent = Habit(title: "Not Added")
        
        habitStore.deleteHabit(nonExistent)
        
        XCTAssertEqual(habitStore.habits.count, 1)
    }
    
    // MARK: - Toggle Completion Tests
    
    func testToggleHabitCompletion() {
        let habit = Habit(title: "Read")
        habitStore.addHabit(habit)
        
        habitStore.toggleHabitCompletion(habit.id)
        
        XCTAssertTrue(habitStore.habits.first?.isCompletedToday ?? false)
    }
    
    func testToggleHabitCompletionWithNote() {
        habitStore.isPremium = true
        let habit = Habit(title: "Read")
        habitStore.addHabit(habit)
        
        habitStore.toggleHabitCompletion(habit.id, note: "Great session!")
        
        let updatedHabit = habitStore.habits.first
        XCTAssertTrue(updatedHabit?.isCompletedToday ?? false)
        XCTAssertNotNil(updatedHabit?.noteForDate(Date()))
    }
    
    func testToggleNonExistentHabit() {
        let randomId = UUID()
        
        habitStore.toggleHabitCompletion(randomId) // Should not crash
        
        XCTAssertTrue(habitStore.habits.isEmpty)
    }
    
    // MARK: - Premium Status Tests
    
    func testCanAddMoreHabitsWhenFreeAndUnderLimit() {
        habitStore.isPremium = false
        habitStore.addHabit(Habit(title: "Habit 1"))
        habitStore.addHabit(Habit(title: "Habit 2"))
        
        XCTAssertTrue(habitStore.canAddMoreHabits)
    }
    
    func testCannotAddMoreHabitsWhenFreeAndAtLimit() {
        habitStore.isPremium = false
        habitStore.addHabit(Habit(title: "Habit 1"))
        habitStore.addHabit(Habit(title: "Habit 2"))
        habitStore.addHabit(Habit(title: "Habit 3"))
        
        XCTAssertFalse(habitStore.canAddMoreHabits)
    }
    
    func testCanAddMoreHabitsWhenPremium() {
        habitStore.isPremium = true
        
        // Add 10 habits
        for i in 1...10 {
            habitStore.addHabit(Habit(title: "Habit \(i)"))
        }
        
        XCTAssertTrue(habitStore.canAddMoreHabits)
    }
    
    func testRemainingFreeSlotsCalculation() {
        habitStore.isPremium = false
        
        XCTAssertEqual(habitStore.remainingFreeSlots, 3)
        
        habitStore.addHabit(Habit(title: "Habit 1"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 2)
        
        habitStore.addHabit(Habit(title: "Habit 2"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 1)
        
        habitStore.addHabit(Habit(title: "Habit 3"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 0)
    }
    
    // MARK: - Statistics Tests
    
    func testGetTotalCompletions() {
        let habit1 = Habit(title: "Read")
        var habit1Mutable = habit1
        habit1Mutable.completionDates = [Date(), Date()]
        
        let habit2 = Habit(title: "Exercise")
        var habit2Mutable = habit2
        habit2Mutable.completionDates = [Date(), Date(), Date()]
        
        habitStore.habits = [habit1Mutable, habit2Mutable]
        
        XCTAssertEqual(habitStore.getTotalCompletions(), 5)
    }
    
    func testGetLongestStreak() {
        var habit1 = Habit(title: "Read")
        habit1.streak = 5
        
        var habit2 = Habit(title: "Exercise")
        habit2.streak = 10
        
        var habit3 = Habit(title: "Meditate")
        habit3.streak = 3
        
        habitStore.habits = [habit1, habit2, habit3]
        
        XCTAssertEqual(habitStore.getLongestStreak(), 10)
    }
    
    func testGetLongestStreakWithNoHabits() {
        XCTAssertEqual(habitStore.getLongestStreak(), 0)
    }
    
    func testGetCompletionRate() {
        var habit1 = Habit(title: "Read")
        habit1.isCompletedToday = true
        
        var habit2 = Habit(title: "Exercise")
        habit2.isCompletedToday = false
        
        var habit3 = Habit(title: "Meditate")
        habit3.isCompletedToday = true
        
        habitStore.habits = [habit1, habit2, habit3]
        
        // 2 out of 3 completed = 0.666...
        XCTAssertEqual(habitStore.getCompletionRate(), 2.0/3.0, accuracy: 0.01)
    }
    
    func testGetCompletionRateWithNoHabits() {
        XCTAssertEqual(habitStore.getCompletionRate(), 0.0)
    }
    
    // MARK: - Update Today Status Tests
    
    func testUpdateTodayStatus() {
        let calendar = Calendar.current
        var habit = Habit(title: "Read")
        
        // Add completion from yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            habit.completionDates = [yesterday]
            habit.isCompletedToday = true // Incorrectly marked as completed today
        }
        
        habitStore.habits = [habit]
        habitStore.updateTodayStatus()
        
        // Should be updated to false since last completion was yesterday
        XCTAssertFalse(habitStore.habits.first?.isCompletedToday ?? true)
    }
}

