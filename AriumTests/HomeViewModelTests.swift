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
    
    // MARK: - Toggle Completion Tests
    
    func testToggleHabitCompletion() throws {
        let habit = Habit(title: "Read")
        try habitStore.addHabit(habit)
        
        viewModel.toggleHabitCompletion(habit, store: habitStore)
        
        XCTAssertTrue(habitStore.habits.first?.isCompletedToday ?? false)
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

