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
    }
    
    override func tearDown() {
        habitStore = nil
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
        super.tearDown()
    }
    
    // MARK: - Add Habit Tests
    
    func testAddHabit() {
        let habit = Habit(title: "Read Books")
        
        habitStore.addHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 1)
        XCTAssertEqual(habitStore.habits.first?.title, "Read Books")
    }
    
    func testAddMultipleHabits() {
        let habit1 = Habit(title: "Read")
        let habit2 = Habit(title: "Exercise")
        let habit3 = Habit(title: "Meditate")
        
        habitStore.addHabit(habit1)
        habitStore.addHabit(habit2)
        habitStore.addHabit(habit3)
        
        XCTAssertEqual(habitStore.habits.count, 3)
    }
    
    // MARK: - Free Tier Limit Tests
    
    func testCanAddMoreHabitsWhenFree() {
        habitStore.isPremium = false
        
        XCTAssertTrue(habitStore.canAddMoreHabits)
        XCTAssertEqual(habitStore.remainingFreeSlots, 3)
        
        habitStore.addHabit(Habit(title: "Habit 1"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 2)
        
        habitStore.addHabit(Habit(title: "Habit 2"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 1)
        
        habitStore.addHabit(Habit(title: "Habit 3"))
        XCTAssertEqual(habitStore.remainingFreeSlots, 0)
        XCTAssertFalse(habitStore.canAddMoreHabits)
    }
    
    func testCannotAddMoreThan3HabitsWhenFree() {
        habitStore.isPremium = false
        
        habitStore.addHabit(Habit(title: "Habit 1"))
        habitStore.addHabit(Habit(title: "Habit 2"))
        habitStore.addHabit(Habit(title: "Habit 3"))
        habitStore.addHabit(Habit(title: "Habit 4")) // Should not be added
        
        XCTAssertEqual(habitStore.habits.count, 3)
    }
    
    func testCanAddUnlimitedHabitsWhenPremium() {
        habitStore.isPremium = true
        
        for i in 1...10 {
            habitStore.addHabit(Habit(title: "Habit \(i)"))
        }
        
        XCTAssertEqual(habitStore.habits.count, 10)
        XCTAssertTrue(habitStore.canAddMoreHabits)
    }
    
    // MARK: - Update Habit Tests
    
    func testUpdateHabit() {
        var habit = Habit(title: "Read Books")
        habitStore.addHabit(habit)
        
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
    
    func testDeleteHabit() {
        let habit = Habit(title: "Read Books")
        habitStore.addHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 1)
        
        habitStore.deleteHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    func testDeleteHabitRestoresFreeSlots() {
        habitStore.isPremium = false
        
        let habit1 = Habit(title: "Habit 1")
        let habit2 = Habit(title: "Habit 2")
        let habit3 = Habit(title: "Habit 3")
        
        habitStore.addHabit(habit1)
        habitStore.addHabit(habit2)
        habitStore.addHabit(habit3)
        
        XCTAssertFalse(habitStore.canAddMoreHabits)
        
        habitStore.deleteHabit(habit1)
        
        XCTAssertTrue(habitStore.canAddMoreHabits)
        XCTAssertEqual(habitStore.remainingFreeSlots, 1)
    }
    
    // MARK: - Toggle Completion Tests
    
    func testToggleHabitCompletion() {
        let habit = Habit(title: "Read Books")
        habitStore.addHabit(habit)
        
        XCTAssertFalse(habitStore.habits.first!.isCompletedToday)
        
        habitStore.toggleHabitCompletion(habit.id)
        
        XCTAssertTrue(habitStore.habits.first!.isCompletedToday)
    }
    
    func testToggleHabitCompletionWithNote() {
        habitStore.isPremium = true
        let habit = Habit(title: "Read Books")
        habitStore.addHabit(habit)
        
        habitStore.toggleHabitCompletion(habit.id, note: "Great progress!")
        
        let updatedHabit = habitStore.habits.first!
        XCTAssertTrue(updatedHabit.isCompletedToday)
        XCTAssertEqual(updatedHabit.noteForDate(Date()), "Great progress!")
    }
    
    // MARK: - Statistics Tests
    
    func testGetTotalCompletions() {
        var habit1 = Habit(title: "Read")
        habit1.completionDates = [Date(), Date()]
        
        var habit2 = Habit(title: "Exercise")
        habit2.completionDates = [Date(), Date(), Date()]
        
        habitStore.addHabit(habit1)
        habitStore.addHabit(habit2)
        
        XCTAssertEqual(habitStore.getTotalCompletions(), 5)
    }
    
    func testGetLongestStreak() {
        var habit1 = Habit(title: "Read", streak: 5)
        var habit2 = Habit(title: "Exercise", streak: 12)
        var habit3 = Habit(title: "Meditate", streak: 3)
        
        habitStore.addHabit(habit1)
        habitStore.addHabit(habit2)
        habitStore.addHabit(habit3)
        
        XCTAssertEqual(habitStore.getLongestStreak(), 12)
    }
    
    func testGetCompletionRate() {
        var habit1 = Habit(title: "Read")
        habit1.isCompletedToday = true
        
        var habit2 = Habit(title: "Exercise")
        habit2.isCompletedToday = false
        
        var habit3 = Habit(title: "Meditate")
        habit3.isCompletedToday = true
        
        habitStore.addHabit(habit1)
        habitStore.addHabit(habit2)
        habitStore.addHabit(habit3)
        
        let rate = habitStore.getCompletionRate()
        XCTAssertEqual(rate, 2.0/3.0, accuracy: 0.01)
    }
    
    func testGetCompletionRateWhenEmpty() {
        XCTAssertEqual(habitStore.getCompletionRate(), 0.0)
    }
    
    // MARK: - Update Today Status Tests
    
    func testUpdateTodayStatus() {
        var habit = Habit(title: "Read")
        let calendar = Calendar.current
        
        // Add a completion from yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            habit.completionDates = [yesterday]
            habit.isCompletedToday = true // Manually set (simulating old state)
        }
        
        habitStore.addHabit(habit)
        habitStore.updateTodayStatus()
        
        // Should be false now since last completion was yesterday
        XCTAssertFalse(habitStore.habits.first!.isCompletedToday)
    }
    
    // MARK: - Persistence Tests
    
    func testHabitsPersistence() {
        let habit = Habit(title: "Read Books", goalDays: 30)
        habitStore.addHabit(habit)
        
        // Create a new store instance (simulating app restart)
        let newStore = HabitStore()
        
        XCTAssertEqual(newStore.habits.count, 1)
        XCTAssertEqual(newStore.habits.first?.title, "Read Books")
        XCTAssertEqual(newStore.habits.first?.goalDays, 30)
    }
}
