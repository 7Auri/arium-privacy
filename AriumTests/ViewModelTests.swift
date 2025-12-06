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
    
    override func setUp() {
        super.setUp()
        habitStore = HabitStore()
        habitStore.habits.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
    }
    
    override func tearDown() {
        habitStore = nil
        UserDefaults.standard.removeObject(forKey: "SavedHabits")
        super.tearDown()
    }
    
    // MARK: - HomeViewModel Tests
    
    func testHomeViewModelFetchHabits() {
        let viewModel = HomeViewModel()
        
        habitStore.addHabit(Habit(title: "Read"))
        habitStore.addHabit(Habit(title: "Exercise"))
        
        viewModel.fetchHabits(from: habitStore)
        
        XCTAssertEqual(viewModel.habits.count, 2)
    }
    
    func testHomeViewModelToggleCompletion() {
        let viewModel = HomeViewModel()
        let habit = Habit(title: "Read")
        
        habitStore.addHabit(habit)
        viewModel.fetchHabits(from: habitStore)
        
        XCTAssertFalse(viewModel.habits.first!.isCompletedToday)
        
        viewModel.toggleHabitCompletion(habit.id, store: habitStore)
        viewModel.fetchHabits(from: habitStore)
        
        XCTAssertTrue(viewModel.habits.first!.isCompletedToday)
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
        let habit = Habit(title: "Read Books", streak: 5, goalDays: 21)
        let viewModel = HabitDetailViewModel(habit: habit)
        
        XCTAssertEqual(viewModel.habit.title, "Read Books")
        XCTAssertEqual(viewModel.habit.streak, 5)
        XCTAssertEqual(viewModel.habit.goalDays, 21)
    }
    
    func testHabitDetailViewModelToggleCompletion() throws {
        var habit = Habit(title: "Read Books")
        habit.isCompletedToday = false
        // Ensure we explicitly mock or set premium status if needed, but HabitStore defaults are fine for basic toggle
        PremiumManager.shared.setPremiumStatus(true)
        
        try habitStore.addHabit(habit)
        let storedHabit = habitStore.habits.first!
        
        let viewModel = HabitDetailViewModel(habit: storedHabit)
        
        // Pass the habitStore which is now required by toggleCompletion
        // Note: HabitDetailViewModel.toggleCompletion might vary in signature vs HomeViewModel
        // Let's assume it calls habitStore.toggleHabitCompletion
        viewModel.toggleCompletion(store: habitStore)
        
        // Since toggleCompletion is async or delegates to store, we check the store or VM habit
        // Check HabitStore
        XCTAssertTrue(habitStore.habits.first!.isCompletedToday)
    }
    
    func testHabitDetailViewModelGetCompletionHistory() {
        var habit = Habit(title: "Read Books")
        let calendar = Calendar.current
        
        // Add 5 completions
        for i in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let viewModel = HabitDetailViewModel(habit: habit)
        let history = viewModel.getCompletionHistory()
        
        XCTAssertEqual(history.count, 5)
    }
    
    func testHabitDetailViewModelUpdateGoalDays() throws {
        let habit = Habit(title: "Read Books", goalDays: 21)
        try habitStore.addHabit(habit)
        let storedHabit = habitStore.habits.first!
        
        let viewModel = HabitDetailViewModel(habit: storedHabit)
        
        viewModel.updateGoalDays(30, store: habitStore)
        
        XCTAssertEqual(habitStore.habits.first?.goalDays, 30)
    }
    
    func testHabitDetailViewModelUpdateStartDate() throws {
        let habit = Habit(title: "Read Books")
        try habitStore.addHabit(habit)
        let storedHabit = habitStore.habits.first!
        
        let viewModel = HabitDetailViewModel(habit: storedHabit)
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        
        viewModel.updateStartDate(newDate, store: habitStore)
        
        XCTAssertEqual(habitStore.habits.first?.startDate, newDate)
    }
}
