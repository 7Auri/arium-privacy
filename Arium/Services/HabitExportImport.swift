//
//  HabitExportImport.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import Foundation
import SwiftUI

enum DuplicateResolution {
    case overwrite
    case skip
    case newId
}

struct ImportHabitItem: Identifiable {
    let id: UUID
    let habit: Habit
    let isExisting: Bool
    let isDuplicate: Bool
    var isSelected: Bool
    var duplicateResolution: DuplicateResolution?
}

@MainActor
class HabitExportImport: ObservableObject {
    static let shared = HabitExportImport()
    
    private init() {}
    
    func exportHabits(_ habits: [Habit]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(habits)
    }
    
    func importHabits(from data: Data) throws -> [Habit] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Habit].self, from: data)
    }
    
    func prepareImportItems(
        importedHabits: [Habit],
        existingHabits: [Habit],
        isPremium: Bool
    ) -> [ImportHabitItem] {
        var items: [ImportHabitItem] = []
        let existingIds = Set(existingHabits.map { $0.id })
        
        // Add existing habits (always included, not selectable)
        for habit in existingHabits {
            items.append(ImportHabitItem(
                id: habit.id,
                habit: habit,
                isExisting: true,
                isDuplicate: false,
                isSelected: true, // Always selected (cannot be deselected)
                duplicateResolution: nil
            ))
        }
        
        // Add imported habits
        for importedHabit in importedHabits {
            let isDuplicate = existingIds.contains(importedHabit.id)
            items.append(ImportHabitItem(
                id: importedHabit.id,
                habit: importedHabit,
                isExisting: false,
                isDuplicate: isDuplicate,
                isSelected: !isDuplicate, // Auto-select if not duplicate
                duplicateResolution: isDuplicate ? nil : .overwrite
            ))
        }
        
        return items
    }
    
    func mergeHabits(
        items: [ImportHabitItem],
        isPremium: Bool,
        maxFreeHabits: Int = 3
    ) -> [Habit] {
        var mergedHabits: [Habit] = []
        var existingHabitIds: Set<UUID> = []
        
        // First, add all existing habits (they should always be included)
        for item in items where item.isExisting {
            mergedHabits.append(item.habit)
            existingHabitIds.insert(item.habit.id)
        }
        
        // Then, add selected new habits
        for item in items where !item.isExisting && item.isSelected {
            var habit = item.habit
            
            // Handle duplicates
            if item.isDuplicate, let resolution = item.duplicateResolution {
                switch resolution {
                case .overwrite:
                    // Replace existing habit with imported version
                    if let index = mergedHabits.firstIndex(where: { $0.id == habit.id }) {
                        mergedHabits[index] = habit
                    }
                    continue
                case .skip:
                    // Skip this habit
                    continue
                case .newId:
                    // Create new ID
                    habit = Habit(
                        id: UUID(),
                        title: habit.title,
                        notes: habit.notes,
                        createdAt: habit.createdAt,
                        streak: habit.streak,
                        themeId: habit.themeId,
                        isCompletedToday: habit.isCompletedToday,
                        completionDates: habit.completionDates,
                        completionNotes: habit.completionNotes,
                        startDate: habit.startDate,
                        goalDays: habit.goalDays,
                        reminderTime: habit.reminderTime,
                        isReminderEnabled: habit.isReminderEnabled,
                        category: habit.category
                    )
                }
            }
            
            // Check limit for free users (only count new habits)
            if !isPremium && mergedHabits.count >= maxFreeHabits {
                continue
            }
            
            mergedHabits.append(habit)
        }
        
        return mergedHabits
    }
    
    func exportToFile(_ habits: [Habit]) throws -> URL {
        let data = try exportHabits(habits)
        
        // Create a safe filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "Arium_Habits_\(dateString).json"
        
        // Use documents directory instead of temp (more reliable)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        try data.write(to: fileURL)
        print("✅ Export file created at: \(fileURL.path)")
        return fileURL
    }
}

