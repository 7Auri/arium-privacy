//
//  AddHabitViewModelTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

@MainActor
final class AddHabitViewModelTests: XCTestCase {
    
    var viewModel: AddHabitViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = AddHabitViewModel()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.notes, "")
        XCTAssertEqual(viewModel.selectedTheme.id, "purple")
        XCTAssertEqual(viewModel.goalDays, 21)
        XCTAssertFalse(viewModel.showingDatePicker)
    }
    
    // MARK: - Can Save Tests
    
    func testCanSaveWithValidTitle() {
        viewModel.title = "Read Books"
        
        XCTAssertTrue(viewModel.canSave)
    }
    
    func testCannotSaveWithEmptyTitle() {
        viewModel.title = ""
        
        XCTAssertFalse(viewModel.canSave)
    }
    
    func testCannotSaveWithWhitespaceOnlyTitle() {
        viewModel.title = "   "
        
        XCTAssertFalse(viewModel.canSave)
    }
    
    // MARK: - Create Habit Tests
    
    func testCreateHabitWithDefaults() {
        viewModel.title = "Read Books"
        
        let habit = viewModel.createHabit()
        
        XCTAssertEqual(habit.title, "Read Books")
        XCTAssertEqual(habit.notes, "")
        XCTAssertEqual(habit.themeId, "purple")
        XCTAssertEqual(habit.goalDays, 21)
    }
    
    func testCreateHabitWithAllFields() {
        viewModel.title = "  Read Books  "
        viewModel.notes = "  Daily reading  "
        viewModel.selectedTheme = .blue
        viewModel.goalDays = 30
        
        let habit = viewModel.createHabit()
        
        XCTAssertEqual(habit.title, "Read Books") // Trimmed
        XCTAssertEqual(habit.notes, "Daily reading") // Trimmed
        XCTAssertEqual(habit.themeId, "blue")
        XCTAssertEqual(habit.goalDays, 30)
    }
    
    func testCreateHabitWithStartDate() {
        viewModel.title = "Exercise"
        let calendar = Calendar.current
        let customDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        viewModel.startDate = customDate
        
        let habit = viewModel.createHabit()
        
        XCTAssertEqual(habit.startDate, customDate)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        viewModel.title = "Test"
        viewModel.notes = "Notes"
        viewModel.selectedTheme = .green
        viewModel.goalDays = 60
        viewModel.showingDatePicker = true
        
        viewModel.reset()
        
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.notes, "")
        XCTAssertEqual(viewModel.selectedTheme.id, "purple")
        XCTAssertEqual(viewModel.goalDays, 21)
        XCTAssertFalse(viewModel.showingDatePicker)
    }
    
    // MARK: - Goal Options Tests
    
    func testGoalOptions() {
        let expectedOptions = [7, 14, 21, 30, 60, 90]
        
        XCTAssertEqual(viewModel.goalOptions, expectedOptions)
    }
    
    // MARK: - Theme Selection Tests
    
    func testThemeSelection() {
        viewModel.selectedTheme = .blue
        XCTAssertEqual(viewModel.selectedTheme.id, "blue")
        
        viewModel.selectedTheme = .green
        XCTAssertEqual(viewModel.selectedTheme.id, "green")
    }
}

