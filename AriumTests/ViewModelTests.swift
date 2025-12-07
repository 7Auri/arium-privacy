//
//  ViewModelTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

@MainActor
final class ViewModelTests: XCTestCase {
    
    var habitStore: HabitStore!
    
    override func setUp() async throws {
        try await super.setUp()
        habitStore = HabitStore()
        habitStore.habits.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
    }
    
    override func tearDown() async throws {
        habitStore = nil
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
        try await super.tearDown()
    }
    
    // MARK: - HomeViewModel Tests
    // Note: HomeViewModel logic has moved significantly to HabitStore or is UI state only.
    // Testing filteredHabits logic.
    
    func testHomeViewModelFiltering() {
        let viewModel = HomeViewModel()
        
        // Create test habits
        // streak, themeId, category
        let h1 = Habit(title: "Read", streak: 0, themeId: "purple", category: .learning) // Learning
        let h2 = Habit(title: "Run", streak: 0, themeId: "purple", category: .health) // Health
        let h3 = Habit(title: "Code", streak: 0, themeId: "purple", category: .learning) // Learning
        
        let habits = [h1, h2, h3]
        
        // 1. Test Category Filter
        viewModel.selectedCategory = .learning
        let filteredByCat = viewModel.filteredHabits(from: habits)
        XCTAssertEqual(filteredByCat.count, 2)
        XCTAssertTrue(filteredByCat.allSatisfy { $0.category == .learning })
        
        // 2. Test Search Filter
        viewModel.selectedCategory = nil
        viewModel.searchText = "Read"
        let filteredBySearch = viewModel.filteredHabits(from: habits)
        XCTAssertEqual(filteredBySearch.count, 1)
        XCTAssertEqual(filteredBySearch.first?.title, "Read")
        
        // 3. Test Combined
        viewModel.selectedCategory = .health
        viewModel.searchText = "Run"
        let filteredCombined = viewModel.filteredHabits(from: habits)
        XCTAssertEqual(filteredCombined.count, 1)
        XCTAssertEqual(filteredCombined.first?.title, "Run")
    }
    
    // MARK: - AddHabitViewModel Tests
    
    func testAddHabitViewModelInitialState() {
        let viewModel = AddHabitViewModel()
        
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.notes, "")
        XCTAssertEqual(viewModel.selectedTheme, .purple)
        XCTAssertEqual(viewModel.goalDays, 21)
    }
    
    func testAddHabitViewModelCreateHabit() {
        let viewModel = AddHabitViewModel()
        viewModel.title = "Read Books"
        viewModel.notes = "30 pages daily"
        viewModel.selectedTheme = .blue
        viewModel.goalDays = 30
        
        let habit = viewModel.createHabit()
        
        XCTAssertEqual(habit.title, "Read Books")
        XCTAssertEqual(habit.notes, "30 pages daily")
        XCTAssertEqual(habit.themeId, "blue")
        XCTAssertEqual(habit.goalDays, 30)
    }
    
    func testAddHabitViewModelCanSaveSuccess() {
        let viewModel = AddHabitViewModel()
        viewModel.title = "Read Books"
        
        XCTAssertTrue(viewModel.canSave)
    }
    
    func testAddHabitViewModelCanSaveFailure() {
        let viewModel = AddHabitViewModel()
        viewModel.title = ""
        
        XCTAssertFalse(viewModel.canSave)
    }
    
    func testAddHabitViewModelReset() {
        let viewModel = AddHabitViewModel()
        viewModel.title = "Read"
        viewModel.notes = "Test"
        viewModel.selectedTheme = .green
        viewModel.goalDays = 60
        
        viewModel.reset()
        
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.notes, "")
        XCTAssertEqual(viewModel.selectedTheme, .purple)
        XCTAssertEqual(viewModel.goalDays, 21)
    }
    
    // MARK: - HabitDetailViewModel Tests
    
    func testHabitDetailViewModelInitialization() {
        let habit = Habit(title: "Read Books", streak: 5, themeId: "purple", goalDays: 21)
        let viewModel = HabitDetailViewModel(habit: habit)
        
        XCTAssertEqual(viewModel.habit.title, "Read Books")
        XCTAssertEqual(viewModel.habit.streak, 5)
        XCTAssertEqual(viewModel.habit.goalDays, 21)
    }
    
    func testHabitDetailViewModelUpdateGoalDays() throws {
        let habit = Habit(title: "Read Books", streak: 0, themeId: "purple", goalDays: 21)
        // Since we verify calls on store, we can use a real store for this integration test
        
        // We need to add habit to store first so update works
        let store = HabitStore()
        store.habits = [habit] // Inject directly or use add
        // try await store.addHabit(habit) // Async, requires await, harder in sync test.
        // But store.updateHabit relies on finding ID in habits array.
        
        let storedHabit = store.habits.first!
        let viewModel = HabitDetailViewModel(habit: storedHabit)
        
        viewModel.updateGoalDays(30, store: store)
        
        XCTAssertEqual(store.habits.first?.goalDays, 30)
        // Also verify VM updated its local copy if applicable
        // The VM updates 'habit' property: habit.goalDays = days
        XCTAssertEqual(viewModel.habit.goalDays, 30)
    }
    
    func testHabitDetailViewModelUpdateStartDate() throws {
        let habit = Habit(title: "Read Books")
        let store = HabitStore()
        store.habits = [habit]
        
        let storedHabit = store.habits.first!
        let viewModel = HabitDetailViewModel(habit: storedHabit)
        
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        
        viewModel.updateStartDate(newDate, store: store)
        
        XCTAssertEqual(store.habits.first?.startDate, newDate)
        XCTAssertEqual(viewModel.editableStartDate, newDate)
    }
}
