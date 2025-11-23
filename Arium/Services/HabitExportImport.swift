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
        let fileName = "Arium_Habits_\(Date().formatted(date: .numeric, time: .omitted)).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: tempURL)
        return tempURL
    }
}

