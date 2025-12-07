//
//  HabitTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

final class HabitTests: XCTestCase {
    
    // MARK: - Habit Initialization Tests
    
    func testHabitInitialization() {
        let habit = Habit(title: "Read Books")
        
        XCTAssertEqual(habit.title, "Read Books")
        XCTAssertEqual(habit.notes, "")
        XCTAssertEqual(habit.streak, 0)
        XCTAssertEqual(habit.themeId, "purple")
        XCTAssertFalse(habit.isCompletedToday)
        XCTAssertTrue(habit.completionDates.isEmpty)
        XCTAssertEqual(habit.goalDays, 21)
    }
    
    func testHabitWithCustomGoalDays() {
        let habit = Habit(title: "Meditate", goalDays: 30)
        
        XCTAssertEqual(habit.goalDays, 30)
    }
    
    // MARK: - Theme Tests
    
    func testHabitTheme() {
        let habit = Habit(title: "Exercise", themeId: "blue")
        
        XCTAssertEqual(habit.themeId, "blue")
        XCTAssertEqual(habit.theme.id, "blue")
    }
    
    func testHabitThemeFallback() {
        var habit = Habit(title: "Test")
        habit.themeId = "invalid_theme"
        
        // Should fallback to purple
        XCTAssertEqual(habit.theme.id, "purple")
    }
    
    // MARK: - Completion Tests
    
    func testToggleCompletionToCompleted() {
        var habit = Habit(title: "Read")
        
        habit.toggleCompletion()
        
        XCTAssertTrue(habit.isCompletedToday)
        XCTAssertEqual(habit.completionDates.count, 1)
        XCTAssertEqual(habit.streak, 1)
    }
    
    func testToggleCompletionToUncompleted() {
        var habit = Habit(title: "Read")
        habit.toggleCompletion() // Complete
        habit.toggleCompletion() // Uncomplete
        
        XCTAssertFalse(habit.isCompletedToday)
        XCTAssertEqual(habit.completionDates.count, 0)
        XCTAssertEqual(habit.streak, 0)
    }
    
    func testCheckIfCompletedToday() {
        var habit = Habit(title: "Read")
        
        XCTAssertFalse(habit.checkIfCompletedToday())
        
        habit.toggleCompletion()
        
        XCTAssertTrue(habit.checkIfCompletedToday())
    }
    
    // MARK: - Streak Calculation Tests
    
    func testStreakCalculationSingleDay() {
        var habit = Habit(title: "Read")
        habit.toggleCompletion()
        
        XCTAssertEqual(habit.streak, 1)
    }
    
    func testStreakCalculationConsecutiveDays() {
        var habit = Habit(title: "Read")
        let calendar = Calendar.current
        
        // Simulate 5 consecutive days
        for daysAgo in (0..<5).reversed() {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        habit.calculateStreak()
        
        XCTAssertEqual(habit.streak, 5)
    }
    
    func testStreakCalculationWithGap() {
        var habit = Habit(title: "Read")
        let calendar = Calendar.current
        
        // Add today
        habit.completionDates.append(Date())
        
        // Add 5 days ago (gap of 4 days)
        if let date = calendar.date(byAdding: .day, value: -5, to: Date()) {
            habit.completionDates.append(date)
        }
        
        habit.calculateStreak()
        
        // Streak should be 1 (only today counts)
        XCTAssertEqual(habit.streak, 1)
    }
    
    func testStreakCalculationWithYesterday() {
        var habit = Habit(title: "Read")
        let calendar = Calendar.current
        
        // Add yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            habit.completionDates.append(yesterday)
        }
        
        habit.calculateStreak()
        
        // Streak should count yesterday
        XCTAssertEqual(habit.streak, 1)
    }
    
    func testStreakResetWhenTooOld() {
        var habit = Habit(title: "Read")
        let calendar = Calendar.current
        
        // Add date from 5 days ago
        if let oldDate = calendar.date(byAdding: .day, value: -5, to: Date()) {
            habit.completionDates.append(oldDate)
        }
        
        habit.calculateStreak()
        
        // Streak should be 0 (too old)
        XCTAssertEqual(habit.streak, 0)
    }
    
    // MARK: - Note Tests
    
    func testSetNote() {
        var habit = Habit(title: "Read")
        let today = Date()
        
        habit.setNote("Great progress today!", for: today)
        
        XCTAssertEqual(habit.noteForDate(today), "Great progress today!")
    }
    
    func testSetNoteWithMaxLength() {
        var habit = Habit(title: "Read")
        let today = Date()
        let longNote = String(repeating: "a", count: 150)
        
        habit.setNote(longNote, for: today)
        
        let savedNote = habit.noteForDate(today)
        XCTAssertEqual(savedNote?.count, 100)
    }
    
    func testRemoveNoteWithEmptyString() {
        var habit = Habit(title: "Read")
        let today = Date()
        
        habit.setNote("Test note", for: today)
        XCTAssertNotNil(habit.noteForDate(today))
        
        habit.setNote("", for: today)
        XCTAssertNil(habit.noteForDate(today))
    }
    
    func testNoteForDateReturnsNilWhenNoNote() {
        let habit = Habit(title: "Read")
        let today = Date()
        
        XCTAssertNil(habit.noteForDate(today))
    }
    
    // MARK: - Start Date Tests
    
    func testEffectiveStartDateWithoutCustomDate() {
        let habit = Habit(title: "Read")
        
        XCTAssertEqual(habit.effectiveStartDate, habit.createdAt)
    }
    
    func testEffectiveStartDateWithCustomDate() {
        let calendar = Calendar.current
        let customDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        
        let habit = Habit(title: "Read", startDate: customDate)
        
        XCTAssertEqual(habit.effectiveStartDate, customDate)
    }
    
    // MARK: - Codable Tests
    
    func testHabitEncoding() throws {
        let habit = Habit(title: "Read Books", notes: "Daily reading", goalDays: 30)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(habit)
        
        XCTAssertFalse(data.isEmpty)
    }
    
    func testHabitDecoding() throws {
        let habit = Habit(title: "Read Books", notes: "Daily reading", goalDays: 30)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(habit)
        
        let decoder = JSONDecoder()
        let decodedHabit = try decoder.decode(Habit.self, from: data)
        
        XCTAssertEqual(decodedHabit.title, habit.title)
        XCTAssertEqual(decodedHabit.notes, habit.notes)
        XCTAssertEqual(decodedHabit.goalDays, habit.goalDays)
    }
    
    // MARK: - Equatable Tests
    
    func testHabitEquality() {
        let id = UUID()
        let date = Date()
        let habit1 = Habit(id: id, title: "Read", createdAt: date)
        let habit2 = Habit(id: id, title: "Read", createdAt: date)
        
        XCTAssertEqual(habit1, habit2)
    }
    
    func testHabitInequality() {
        let habit1 = Habit(title: "Read")
        let habit2 = Habit(title: "Exercise")
        
        XCTAssertNotEqual(habit1, habit2)
    }
}

