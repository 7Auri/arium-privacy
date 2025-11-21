//
//  HabitLog.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation

struct HabitLog: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let completedAt: Date
    var notes: String?
    
    init(
        id: UUID = UUID(),
        habitId: UUID,
        completedAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.habitId = habitId
        self.completedAt = completedAt
        self.notes = notes
    }
}

