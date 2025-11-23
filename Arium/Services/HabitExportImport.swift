//
//  HabitExportImport.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import Foundation
import SwiftUI

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

