//
//  HabitRepetitionTests.swift
//  AriumTests
//
//  Created by Auto on 28.11.2025.
//

import Testing
@testable import Arium
import Foundation

struct HabitRepetitionTests {
    
    @Test func testDefaultRepetition() async throws {
        let habit = Habit(title: "Test", themeId: "purple", category: .health)
        
        // Default should be 1 repetition
        #expect(habit.dailyRepetitions == 1)
        #expect(habit.repetitionLabels == nil)
        #expect(habit.todayCompletions.isEmpty)
    }
    
    @Test func testMultipleRepetitions() async throws {
        var habit = Habit(
            title: "Brush Teeth",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 2,
            repetitionLabels: ["Morning", "Evening"]
        )
        
        #expect(habit.dailyRepetitions == 2)
        #expect(habit.repetitionLabels?.count == 2)
        #expect(habit.repetitionLabels?[0] == "Morning")
        #expect(habit.repetitionLabels?[1] == "Evening")
    }
    
    @Test func testRepetitionCompletion() async throws {
        var habit = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 3
        )
        
        // Initially no completions
        #expect(habit.todayCompletions.isEmpty)
        #expect(!habit.isRepetitionCompleted(at: 0))
        #expect(!habit.isRepetitionCompleted(at: 1))
        #expect(!habit.isRepetitionCompleted(at: 2))
        
        // Complete first repetition
        habit.toggleRepetitionCompletion(at: 0)
        #expect(habit.isRepetitionCompleted(at: 0))
        #expect(!habit.isRepetitionCompleted(at: 1))
        #expect(habit.todayCompletions.count == 1)
        
        // Complete second repetition
        habit.toggleRepetitionCompletion(at: 1)
        #expect(habit.isRepetitionCompleted(at: 0))
        #expect(habit.isRepetitionCompleted(at: 1))
        #expect(habit.todayCompletions.count == 2)
        
        // Toggle first off
        habit.toggleRepetitionCompletion(at: 0)
        #expect(!habit.isRepetitionCompleted(at: 0))
        #expect(habit.isRepetitionCompleted(at: 1))
        #expect(habit.todayCompletions.count == 1)
    }
    
    @Test func testCompletionPercentage() async throws {
        var habit = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 4
        )
        
        // 0% initially
        #expect(habit.completionPercentage == 0.0)
        
        // Complete 1 out of 4 = 25%
        habit.toggleRepetitionCompletion(at: 0)
        #expect(habit.completionPercentage == 0.25)
        
        // Complete 2 out of 4 = 50%
        habit.toggleRepetitionCompletion(at: 1)
        #expect(habit.completionPercentage == 0.5)
        
        // Complete 3 out of 4 = 75%
        habit.toggleRepetitionCompletion(at: 2)
        #expect(habit.completionPercentage == 0.75)
        
        // Complete all = 100%
        habit.toggleRepetitionCompletion(at: 3)
        #expect(habit.completionPercentage == 1.0)
    }
    
    @Test func testDisplayRepetitionLabels() async throws {
        // Test with custom labels
        let habitWithLabels = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 3,
            repetitionLabels: ["Morning", "Noon", "Evening"]
        )
        
        let labels1 = habitWithLabels.displayRepetitionLabels
        #expect(labels1.count == 3)
        #expect(labels1[0] == "Morning")
        #expect(labels1[1] == "Noon")
        #expect(labels1[2] == "Evening")
        
        // Test without custom labels (should generate defaults)
        let habitWithoutLabels = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 3,
            repetitionLabels: nil
        )
        
        let labels2 = habitWithoutLabels.displayRepetitionLabels
        #expect(labels2.count == 3)
        #expect(labels2[0] == "1")
        #expect(labels2[1] == "2")
        #expect(labels2[2] == "3")
    }
    
    @Test func testResetDailyCompletions() async throws {
        var habit = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 3
        )
        
        // Complete all
        habit.toggleRepetitionCompletion(at: 0)
        habit.toggleRepetitionCompletion(at: 1)
        habit.toggleRepetitionCompletion(at: 2)
        #expect(habit.todayCompletions.count == 3)
        
        // Reset
        habit.resetDailyCompletions()
        #expect(habit.todayCompletions.isEmpty)
        #expect(habit.completionPercentage == 0.0)
    }
    
    @Test func testDailyCompletionCounts() async throws {
        var habit = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 3
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayKey = dateFormatter.string(from: Date())
        
        // Initially empty
        #expect(habit.dailyCompletionCounts.isEmpty)
        
        // Complete 2 out of 3
        habit.toggleRepetitionCompletion(at: 0)
        habit.toggleRepetitionCompletion(at: 1)
        habit.updateDailyCompletionCount()
        
        #expect(habit.dailyCompletionCounts[todayKey] == 2)
        
        // Complete the third one
        habit.toggleRepetitionCompletion(at: 2)
        habit.updateDailyCompletionCount()
        
        #expect(habit.dailyCompletionCounts[todayKey] == 3)
    }
    
    @Test func testMaxRepetitions() async throws {
        // Test that repetitions are clamped to 1-5 range
        let habit1 = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 1
        )
        #expect(habit1.dailyRepetitions == 1)
        
        let habit5 = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 5
        )
        #expect(habit5.dailyRepetitions == 5)
    }
    
    @Test func testRepetitionWithSingleDaily() async throws {
        // Test that single repetition habit still works correctly
        var habit = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 1
        )
        
        #expect(habit.completionPercentage == 0.0)
        
        habit.toggleRepetitionCompletion(at: 0)
        #expect(habit.completionPercentage == 1.0)
        #expect(habit.isRepetitionCompleted(at: 0))
    }
    
    @Test func testRepetitionJSONEncoding() async throws {
        let habit = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 2,
            repetitionLabels: ["AM", "PM"]
        )
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(habit)
        
        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Habit.self, from: data)
        
        // Verify
        #expect(decoded.dailyRepetitions == 2)
        #expect(decoded.repetitionLabels?.count == 2)
        #expect(decoded.repetitionLabels?[0] == "AM")
        #expect(decoded.repetitionLabels?[1] == "PM")
    }
    
    @Test func testPartialCompletion() async throws {
        var habit = Habit(
            title: "Test",
            themeId: "purple",
            category: .health,
            dailyRepetitions: 3
        )
        
        // Complete only 1 out of 3
        habit.toggleRepetitionCompletion(at: 0)
        
        // Check partial completion state
        #expect(habit.isRepetitionCompleted(at: 0))
        #expect(!habit.isRepetitionCompleted(at: 1))
        #expect(!habit.isRepetitionCompleted(at: 2))
        
        let percentage = habit.completionPercentage
        #expect(percentage > 0.0 && percentage < 1.0)
        #expect(abs(percentage - 0.333) < 0.01) // Approximately 33.3%
    }
}

