//
//  MeasurementType.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import Foundation

// MARK: - Measurement Type Model

struct MeasurementType: Identifiable, Codable, Equatable {
    let id: String
    let displayNameKey: String
    let unit: String
    let isPremium: Bool
    let icon: String
    let sortOrder: Int
    
    var displayName: String { L10n.t(displayNameKey) }
    
    static let allTypes: [MeasurementType] = [
        MeasurementType(id: "weight", displayNameKey: "measurement.weight", unit: "kg", isPremium: false, icon: "scalemass", sortOrder: 0),
        MeasurementType(id: "waist", displayNameKey: "measurement.waist", unit: "cm", isPremium: false, icon: "ruler", sortOrder: 1),
        MeasurementType(id: "hip", displayNameKey: "measurement.hip", unit: "cm", isPremium: true, icon: "figure.stand", sortOrder: 2),
        MeasurementType(id: "chest", displayNameKey: "measurement.chest", unit: "cm", isPremium: true, icon: "figure.arms.open", sortOrder: 3),
        MeasurementType(id: "arm", displayNameKey: "measurement.arm", unit: "cm", isPremium: true, icon: "figure.strengthtraining.traditional", sortOrder: 4),
        MeasurementType(id: "leg", displayNameKey: "measurement.leg", unit: "cm", isPremium: true, icon: "figure.walk", sortOrder: 5),
        MeasurementType(id: "bodyfat", displayNameKey: "measurement.bodyfat", unit: "%", isPremium: true, icon: "percent", sortOrder: 6),
    ]
    
    static var freeTypes: [MeasurementType] {
        allTypes.filter { !$0.isPremium }
    }
    
    static func accessibleTypes(isPremium: Bool) -> [MeasurementType] {
        isPremium ? allTypes : freeTypes
    }
}

// MARK: - Measurement Period

enum MeasurementPeriod: String, CaseIterable {
    case week, month, quarter
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        }
    }
    
    var localizedName: String {
        L10n.t("measurement.period.\(rawValue)")
    }
}

// MARK: - Measurement Chart Point

struct MeasurementChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
