//
//  HabitDetailViewModelTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

@MainActor
final class HabitDetailViewModelTests: XCTestCase {
    
    var viewModel: HabitDetailViewModel!
    var habitStore: HabitStore!
    var testHabit: Habit!
    
    override func setUp() async throws {
        try await super.setUp()
        testHabit = Habit(title: "Read Books")
        viewModel = HabitDetailViewModel(habit: testHabit)
        habitStore = HabitStore()
        habitStore.habits.removeAll()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        habitStore = nil
        testHabit = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(viewModel.habit.title, "Read Books")
        XCTAssertEqual(viewModel.editableStartDate, testHabit.effectiveStartDate)
        XCTAssertFalse(viewModel.showingEditSheet)
        XCTAssertFalse(viewModel.showingStatistics)
        XCTAssertFalse(viewModel.showingDeleteAlert)
        XCTAssertFalse(viewModel.showingStartDatePicker)
    }
    
    // MARK: - Refresh Completion Tests
    
    func testRefreshCompletionForNewDay() {
        let calendar = Calendar.current
        var habitWithYesterdayCompletion = testHabit!
        
        // Add completion from yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            habitWithYesterdayCompletion.completionDates = [yesterday]
            habitWithYesterdayCompletion.isCompletedToday = true
        }
        
        viewModel.habit = habitWithYesterdayCompletion
        viewModel.refreshCompletionForNewDay()
        
        // Should be false since completion was yesterday
        XCTAssertFalse(viewModel.habit.isCompletedToday)
    }
    
    func testRefreshCompletionWithTodayCompletion() {
        var habitWithTodayCompletion = testHabit!
        habitWithTodayCompletion.completionDates = [Date()]
        habitWithTodayCompletion.isCompletedToday = true
        
        viewModel.habit = habitWithTodayCompletion
        viewModel.refreshCompletionForNewDay()
        
        // Should still be true
        XCTAssertTrue(viewModel.habit.isCompletedToday)
    }
    
    // MARK: - Toggle Completion Tests
    
    func testToggleCompletion() throws {
        try habitStore.addHabit(testHabit)
        
        viewModel.toggleCompletion(store: habitStore)
        
        // Check if habit was toggled in store
        XCTAssertTrue(habitStore.habits.first?.isCompletedToday ?? false)
    }
    
    // MARK: - Completion History Tests
    
    func testGetCompletionHistory() {
        let calendar = Calendar.current
        var habitWithHistory = testHabit!
        
        // Add 3 completion dates
        habitWithHistory.completionDates = [
            Date(),
            calendar.date(byAdding: .day, value: -1, to: Date())!,
            calendar.date(byAdding: .day, value: -2, to: Date())!
        ]
        
        viewModel.habit = habitWithHistory
        let history = viewModel.getCompletionHistory()
        
        XCTAssertEqual(history.count, 3)
        // Should be sorted in descending order (most recent first)
        XCTAssertGreaterThanOrEqual(history[0], history[1])
    }
    
    func testGetCompletionHistoryEmpty() {
        let history = viewModel.getCompletionHistory()
        
        XCTAssertTrue(history.isEmpty)
    }
    
    // MARK: - Completion Percentage Tests
    
    func testGetCompletionPercentage() {
        let calendar = Calendar.current
        var habitWithCompletions = testHabit!
        
        // Add completions for 5 out of last 7 days
        var dates: [Date] = []
        for day in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -day, to: Date()) {
                dates.append(date)
            }
        }
        habitWithCompletions.completionDates = dates
        
        viewModel.habit = habitWithCompletions
        let percentage = viewModel.getCompletionPercentage(days: 7)
        
        // 5 out of 7 days = ~71.4%
        XCTAssertEqual(percentage, 5.0 / 7.0, accuracy: 0.01)
    }
    
    func testGetCompletionPercentageNoCompletions() {
        let percentage = viewModel.getCompletionPercentage(days: 7)
        
        XCTAssertEqual(percentage, 0.0)
    }
    
    // MARK: - Update Start Date Tests
    
    func testUpdateStartDate() throws {
        try habitStore.addHabit(testHabit)
        
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        
        viewModel.updateStartDate(newDate, store: habitStore)
        
        XCTAssertEqual(viewModel.habit.startDate, newDate)
        XCTAssertEqual(viewModel.editableStartDate, newDate)
    }
    
    // MARK: - Update Goal Days Tests
    
    func testUpdateGoalDays() throws {
        try habitStore.addHabit(testHabit)
        
        viewModel.updateGoalDays(30, store: habitStore)
        
        XCTAssertEqual(viewModel.habit.goalDays, 30)
    }
}

