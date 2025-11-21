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
        XCTAssertFalse(viewModel.showingAlert)
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
    
    func testAddHabitViewModelValidateSuccess() {
        let viewModel = AddHabitViewModel()
        viewModel.title = "Read Books"
        
        XCTAssertTrue(viewModel.validate())
        XCTAssertFalse(viewModel.showingAlert)
    }
    
    func testAddHabitViewModelValidateFailure() {
        let viewModel = AddHabitViewModel()
        viewModel.title = ""
        
        XCTAssertFalse(viewModel.validate())
        XCTAssertTrue(viewModel.showingAlert)
        XCTAssertEqual(viewModel.alertMessage, "Please enter a habit title")
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
    
    func testHabitDetailViewModelToggleCompletion() {
        var habit = Habit(title: "Read Books")
        habit.isCompletedToday = false
        
        let viewModel = HabitDetailViewModel(habit: habit)
        
        viewModel.toggleCompletion(store: habitStore)
        
        XCTAssertTrue(viewModel.habit.isCompletedToday)
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
    
    func testHabitDetailViewModelUpdateGoalDays() {
        let habit = Habit(title: "Read Books", goalDays: 21)
        let viewModel = HabitDetailViewModel(habit: habit)
        
        habitStore.addHabit(habit)
        
        viewModel.updateGoalDays(30, store: habitStore)
        
        XCTAssertEqual(viewModel.habit.goalDays, 30)
    }
    
    func testHabitDetailViewModelUpdateStartDate() {
        let habit = Habit(title: "Read Books")
        let viewModel = HabitDetailViewModel(habit: habit)
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        
        habitStore.addHabit(habit)
        
        viewModel.updateStartDate(newDate, store: habitStore)
        
        XCTAssertEqual(viewModel.habit.startDate, newDate)
    }
}

