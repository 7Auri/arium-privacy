//
//  HomeViewModelTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var habitStore: HabitStore!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = HomeViewModel()
        habitStore = HabitStore()
        habitStore.habits.removeAll()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        habitStore = nil
        try await super.tearDown()
    }
    
    // MARK: - Date Selection & Completion Tests
    
    func testDateSelectionDefaultsToToday() {
        XCTAssertTrue(Calendar.current.isDateInToday(viewModel.selectedDate))
    }
    
    func testToggleCompletionOnSelectedDate() throws {
        let habit = Habit(title: "Read")
        try habitStore.addHabit(habit)
        
        let today = Date()
        viewModel.selectedDate = today
        
        // Toggle (Mark as completed)
        viewModel.toggleCompletion(habit, date: today, store: habitStore)
        XCTAssertTrue(habitStore.habits.first?.isCompletedToday ?? false)
        XCTAssertTrue(viewModel.isCompleted(habitStore.habits.first!, on: today))
        
        // Toggle again (Unmark)
        viewModel.toggleCompletion(habitStore.habits.first!, date: today, store: habitStore)
        XCTAssertFalse(habitStore.habits.first?.isCompletedToday ?? true)
        XCTAssertFalse(viewModel.isCompleted(habitStore.habits.first!, on: today))
    }
    
    func testToggleCompletionOnPastDate() throws {
        let habit = Habit(title: "Past Habit")
        try habitStore.addHabit(habit)
        
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else { return }
        
        viewModel.selectedDate = yesterday
        
        // Toggle for yesterday
        viewModel.toggleCompletion(habit, date: yesterday, store: habitStore)
        
        // Should be completed on yesterday
        XCTAssertTrue(viewModel.isCompleted(habitStore.habits.first!, on: yesterday))
        
        // Should NOT be completed today
        XCTAssertFalse(viewModel.isCompleted(habitStore.habits.first!, on: Date()))
    }
    
    // MARK: - Delete Habit Tests
    
    func testDeleteHabit() throws {
        let habit = Habit(title: "To Delete")
        try habitStore.addHabit(habit)
        
        XCTAssertEqual(habitStore.habits.count, 1)
        
        viewModel.deleteHabit(habit, store: habitStore)
        
        XCTAssertEqual(habitStore.habits.count, 0)
    }
    
    // MARK: - UI State Tests
    
    func testShowingAddHabitToggle() {
        XCTAssertFalse(viewModel.showingAddHabit)
        
        viewModel.showingAddHabit = true
        
        XCTAssertTrue(viewModel.showingAddHabit)
    }
    
    func testShowingSettingsToggle() {
        XCTAssertFalse(viewModel.showingSettings)
        
        viewModel.showingSettings = true
        
        XCTAssertTrue(viewModel.showingSettings)
    }
    
    func testSelectedHabitIsNilByDefault() {
        XCTAssertNil(viewModel.selectedHabit)
    }
    
    func testSelectedHabitCanBeSet() {
        let habit = Habit(title: "Read")
        
        viewModel.selectedHabit = habit
        
        XCTAssertEqual(viewModel.selectedHabit?.title, "Read")
    }
}

