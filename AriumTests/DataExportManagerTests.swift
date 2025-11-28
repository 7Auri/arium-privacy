//
//  DataExportManagerTests.swift
//  AriumTests
//
//  Created by Auto on 28.11.2025.
//

import Testing
@testable import Arium
import Foundation

struct DataExportManagerTests {
    
    @Test func testDataExportManagerSingleton() async throws {
        let manager1 = DataExportManager.shared
        let manager2 = DataExportManager.shared
        #expect(manager1 === manager2)
    }
    
    @Test func testExportToCSV() async throws {
        let manager = DataExportManager.shared
        
        // Create test habits
        var habit1 = Habit(title: "Test Habit 1", themeId: "purple", category: .health)
        habit1.completionDates = [Date(), Date().addingTimeInterval(-86400)]
        
        var habit2 = Habit(title: "Test Habit 2", themeId: "blue", category: .work)
        habit2.completionDates = [Date()]
        
        let habits = [habit1, habit2]
        
        // Export to CSV
        let url = try manager.exportToCSV(habits: habits)
        
        // Verify file exists
        #expect(FileManager.default.fileExists(atPath: url.path))
        
        // Read and verify content
        let content = try String(contentsOf: url, encoding: .utf8)
        #expect(content.contains("Title"))
        #expect(content.contains("Test Habit 1"))
        #expect(content.contains("Test Habit 2"))
        #expect(content.contains("Health"))
        #expect(content.contains("Work"))
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test func testExportToJSON() async throws {
        let manager = DataExportManager.shared
        
        // Create test habits
        let habit1 = Habit(title: "Test Habit", themeId: "purple", category: .health)
        let habits = [habit1]
        
        // Export to JSON
        let url = try manager.exportToJSON(habits: habits)
        
        // Verify file exists
        #expect(FileManager.default.fileExists(atPath: url.path))
        
        // Read and verify content
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Habit].self, from: data)
        
        #expect(decoded.count == 1)
        #expect(decoded[0].title == "Test Habit")
        #expect(decoded[0].category == .health)
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test func testExportEmptyHabits() async throws {
        let manager = DataExportManager.shared
        let habits: [Habit] = []
        
        // CSV should still work with empty data
        let csvURL = try manager.exportToCSV(habits: habits)
        #expect(FileManager.default.fileExists(atPath: csvURL.path))
        try? FileManager.default.removeItem(at: csvURL)
        
        // JSON should still work with empty data
        let jsonURL = try manager.exportToJSON(habits: habits)
        #expect(FileManager.default.fileExists(atPath: jsonURL.path))
        try? FileManager.default.removeItem(at: jsonURL)
    }
    
    @Test func testCSVFormat() async throws {
        let manager = DataExportManager.shared
        
        var habit = Habit(title: "CSV Test", themeId: "purple", category: .health)
        habit.notes = "Test notes"
        habit.goalDays = 30
        habit.streak = 5
        
        let url = try manager.exportToCSV(habits: [habit])
        let content = try String(contentsOf: url, encoding: .utf8)
        
        // Check CSV structure
        let lines = content.components(separatedBy: "\n")
        #expect(lines.count >= 2) // Header + at least 1 data row
        
        let header = lines[0]
        #expect(header.contains("Title"))
        #expect(header.contains("Category"))
        #expect(header.contains("Streak"))
        #expect(header.contains("Goal Days"))
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test func testJSONBackupRestore() async throws {
        let manager = DataExportManager.shared
        
        // Create diverse test data
        var habit1 = Habit(title: "Habit 1", themeId: "purple", category: .health)
        habit1.notes = "Notes 1"
        habit1.goalDays = 21
        habit1.streak = 10
        habit1.dailyRepetitions = 2
        habit1.repetitionLabels = ["Morning", "Evening"]
        
        var habit2 = Habit(title: "Habit 2", themeId: "blue", category: .work)
        habit2.isReminderEnabled = true
        habit2.completionDates = [Date(), Date().addingTimeInterval(-86400)]
        
        let originalHabits = [habit1, habit2]
        
        // Export
        let url = try manager.exportToJSON(habits: originalHabits)
        
        // Import back
        let data = try Data(contentsOf: url)
        let restoredHabits = try JSONDecoder().decode([Habit].self, from: data)
        
        // Verify restoration
        #expect(restoredHabits.count == originalHabits.count)
        #expect(restoredHabits[0].title == "Habit 1")
        #expect(restoredHabits[0].dailyRepetitions == 2)
        #expect(restoredHabits[0].repetitionLabels == ["Morning", "Evening"])
        #expect(restoredHabits[1].title == "Habit 2")
        #expect(restoredHabits[1].completionDates.count == 2)
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test func testPDFGeneration() async throws {
        let manager = DataExportManager.shared
        
        var habit = Habit(title: "PDF Test", themeId: "purple", category: .health)
        habit.completionDates = [Date()]
        habit.streak = 3
        
        // Generate PDF
        let url = try manager.generatePDFReport(habits: [habit])
        
        // Verify file exists and is a PDF
        #expect(FileManager.default.fileExists(atPath: url.path))
        #expect(url.pathExtension == "pdf")
        
        // Verify file size is reasonable (not empty)
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int ?? 0
        #expect(fileSize > 0)
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
}

