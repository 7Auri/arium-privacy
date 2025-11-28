//
//  HabitExportImportTests.swift
//  AriumTests
//
//  Created by Auto on 23.11.2025.
//

import XCTest
@testable import Arium

@MainActor
final class HabitExportImportTests: XCTestCase {
    
    var exportImport: HabitExportImport!
    
    override func setUp() {
        super.setUp()
        exportImport = HabitExportImport.shared
    }
    
    override func tearDown() {
        exportImport = nil
        super.tearDown()
    }
    
    // MARK: - Export Tests
    
    func testExportHabits() throws {
        let habits = [
            Habit(title: "Read", goalDays: 21),
            Habit(title: "Exercise", goalDays: 30)
        ]
        
        let data = try exportImport.exportHabits(habits)
        
        XCTAssertFalse(data.isEmpty)
        // Should be valid JSON
        let json = try JSONSerialization.jsonObject(with: data)
        XCTAssertNotNil(json)
    }
    
    func testExportEmptyHabits() throws {
        let habits: [Habit] = []
        let data = try exportImport.exportHabits(habits)
        
        // Should export empty array
        let decoded = try exportImport.importHabits(from: data)
        XCTAssertEqual(decoded.count, 0)
    }
    
    func testExportHabitsWithCompletions() throws {
        var habit = Habit(title: "Read")
        habit.completionDates = [Date(), Date().addingTimeInterval(-86400)]
        habit.isCompletedToday = true
        
        let data = try exportImport.exportHabits([habit])
        let decoded = try exportImport.importHabits(from: data)
        
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded.first?.title, "Read")
        XCTAssertEqual(decoded.first?.completionDates.count, 2)
    }
    
    // MARK: - Import Tests
    
    func testImportHabits() throws {
        let habits = [
            Habit(title: "Read", goalDays: 21),
            Habit(title: "Exercise", goalDays: 30)
        ]
        
        let data = try exportImport.exportHabits(habits)
        let imported = try exportImport.importHabits(from: data)
        
        XCTAssertEqual(imported.count, 2)
        XCTAssertEqual(imported[0].title, "Read")
        XCTAssertEqual(imported[1].title, "Exercise")
    }
    
    func testImportInvalidData() {
        let invalidData = "invalid json".data(using: .utf8)!
        
        XCTAssertThrowsError(try exportImport.importHabits(from: invalidData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testImportEmptyData() throws {
        let emptyData = "[]".data(using: .utf8)!
        let imported = try exportImport.importHabits(from: emptyData)
        
        XCTAssertEqual(imported.count, 0)
    }
    
    // MARK: - Prepare Import Items Tests
    
    func testPrepareImportItemsNewHabits() {
        let existingHabits: [Habit] = []
        let importedHabits = [
            Habit(title: "Read"),
            Habit(title: "Exercise")
        ]
        
        let items = exportImport.prepareImportItems(
            importedHabits: importedHabits,
            existingHabits: existingHabits,
            isPremium: true
        )
        
        XCTAssertEqual(items.count, 2)
        XCTAssertFalse(items[0].isExisting)
        XCTAssertFalse(items[0].isDuplicate)
        XCTAssertFalse(items[1].isExisting)
        XCTAssertFalse(items[1].isDuplicate)
    }
    
    func testPrepareImportItemsWithDuplicates() {
        let existingHabit = Habit(id: UUID(), title: "Read")
        let existingHabits = [existingHabit]
        
        let importedHabit = Habit(id: existingHabit.id, title: "Read Updated")
        let importedHabits = [importedHabit]
        
        let items = exportImport.prepareImportItems(
            importedHabits: importedHabits,
            existingHabits: existingHabits,
            isPremium: true
        )
        
        XCTAssertEqual(items.count, 1)
        XCTAssertTrue(items[0].isDuplicate)
    }
    
    func testPrepareImportItemsWithExisting() {
        let existingHabit = Habit(id: UUID(), title: "Read")
        let existingHabits = [existingHabit]
        
        let importedHabits: [Habit] = []
        
        let items = exportImport.prepareImportItems(
            importedHabits: importedHabits,
            existingHabits: existingHabits,
            isPremium: true
        )
        
        // Should not include existing habits in import items
        XCTAssertEqual(items.count, 0)
    }
    
    // MARK: - Merge Habits Tests
    
    func testMergeHabitsNewHabits() {
        let existingHabits: [Habit] = []
        let items = [
            ImportHabitItem(
                id: UUID(),
                habit: Habit(title: "Read"),
                isExisting: false,
                isDuplicate: false,
                isSelected: true,
                duplicateResolution: nil
            )
        ]
        
        let merged = exportImport.mergeHabits(
            items: items,
            isPremium: true,
            maxFreeHabits: 3
        )
        
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.title, "Read")
    }
    
    func testMergeHabitsOverwrite() {
        let existingHabit = Habit(id: UUID(), title: "Read Old")
        let existingHabits = [existingHabit]
        
        let updatedHabit = Habit(id: existingHabit.id, title: "Read New")
        let items = [
            ImportHabitItem(
                id: existingHabit.id,
                habit: updatedHabit,
                isExisting: false,
                isDuplicate: true,
                isSelected: true,
                duplicateResolution: .overwrite
            )
        ]
        
        let merged = exportImport.mergeHabits(
            items: items,
            isPremium: true,
            maxFreeHabits: 3
        )
        
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.title, "Read New")
    }
    
    func testMergeHabitsSkip() {
        let existingHabit = Habit(id: UUID(), title: "Read")
        let existingHabits = [existingHabit]
        
        let duplicateHabit = Habit(id: existingHabit.id, title: "Read Updated")
        let items = [
            ImportHabitItem(
                id: existingHabit.id,
                habit: duplicateHabit,
                isExisting: false,
                isDuplicate: true,
                isSelected: true,
                duplicateResolution: .skip
            )
        ]
        
        let merged = exportImport.mergeHabits(
            items: items,
            isPremium: true,
            maxFreeHabits: 3
        )
        
        // Should keep original
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.title, "Read")
    }
    
    func testMergeHabitsNewId() {
        let existingHabit = Habit(id: UUID(), title: "Read")
        let existingHabits = [existingHabit]
        
        let duplicateHabit = Habit(id: existingHabit.id, title: "Read")
        let items = [
            ImportHabitItem(
                id: existingHabit.id,
                habit: duplicateHabit,
                isExisting: false,
                isDuplicate: true,
                isSelected: true,
                duplicateResolution: .newId
            )
        ]
        
        let merged = exportImport.mergeHabits(
            items: items,
            isPremium: true,
            maxFreeHabits: 3
        )
        
        // Should have both habits with different IDs
        XCTAssertEqual(merged.count, 2)
        XCTAssertNotEqual(merged[0].id, merged[1].id)
    }
    
    func testMergeHabitsFreeLimit() {
        let items = (1...5).map { index in
            ImportHabitItem(
                id: UUID(),
                habit: Habit(title: "Habit \(index)"),
                isExisting: false,
                isDuplicate: false,
                isSelected: true,
                duplicateResolution: nil
            )
        }
        
        let merged = exportImport.mergeHabits(
            items: items,
            isPremium: false,
            maxFreeHabits: 3
        )
        
        // Should only add 3 habits (free limit)
        XCTAssertEqual(merged.count, 3)
    }
}

