//
//  MeasurementEntry.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import Foundation

// MARK: - Measurement Entry Model

struct MeasurementEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var typeId: String
    var value: Double
    var unit: String
    var date: Date
    var note: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        typeId: String,
        value: Double,
        unit: String,
        date: Date = Date(),
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.typeId = typeId
        self.value = value
        self.unit = unit
        self.date = date
        self.note = note
        self.createdAt = createdAt
    }
}
