//
//  MeasurementGoal.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import Foundation

// MARK: - Measurement Goal Model

struct MeasurementGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var typeId: String
    var targetValue: Double
    var targetDate: Date
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        typeId: String,
        targetValue: Double,
        targetDate: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.typeId = typeId
        self.targetValue = targetValue
        self.targetDate = targetDate
        self.createdAt = createdAt
    }
}
