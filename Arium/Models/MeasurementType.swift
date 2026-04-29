//
//  MeasurementType.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import Foundation
import SwiftUI

// MARK: - Unit System

enum UnitSystem: String, CaseIterable {
    case metric
    case imperial
    
    var localizedName: String {
        L10n.t("measurement.unitSystem.\(rawValue)")
    }
}

// MARK: - Unit Conversion

struct UnitConversion {
    /// kg → lbs
    static func kgToLbs(_ kg: Double) -> Double { kg * 2.20462 }
    /// lbs → kg
    static func lbsToKg(_ lbs: Double) -> Double { lbs / 2.20462 }
    /// cm → inches
    static func cmToInch(_ cm: Double) -> Double { cm / 2.54 }
    /// inches → cm
    static func inchToCm(_ inch: Double) -> Double { inch * 2.54 }
    
    /// Converts a value from metric to the given unit system
    static func fromMetric(_ value: Double, type: MeasurementType, system: UnitSystem) -> Double {
        guard system == .imperial else { return value }
        switch type.metricUnit {
        case "kg": return kgToLbs(value)
        case "cm": return cmToInch(value)
        default: return value // %, etc. don't convert
        }
    }
    
    /// Converts a value from the given unit system to metric (for storage)
    static func toMetric(_ value: Double, type: MeasurementType, system: UnitSystem) -> Double {
        guard system == .imperial else { return value }
        switch type.metricUnit {
        case "kg": return lbsToKg(value)
        case "cm": return inchToCm(value)
        default: return value
        }
    }
}

// MARK: - Measurement Type Model

struct MeasurementType: Identifiable, Codable, Equatable {
    let id: String
    let displayNameKey: String
    let metricUnit: String
    let imperialUnit: String
    let isPremium: Bool
    let icon: String
    let sortOrder: Int
    
    var displayName: String { L10n.t(displayNameKey) }
    
    /// Returns the unit string for the current unit system
    var unit: String {
        let system = UnitSystem(rawValue: UserDefaults.standard.string(forKey: "measurementUnitSystem") ?? "metric") ?? .metric
        return system == .imperial ? imperialUnit : metricUnit
    }
    
    /// Returns the unit string for a specific system
    func unit(for system: UnitSystem) -> String {
        system == .imperial ? imperialUnit : metricUnit
    }
    
    static let allTypes: [MeasurementType] = [
        MeasurementType(id: "weight", displayNameKey: "measurement.weight", metricUnit: "kg", imperialUnit: "lbs", isPremium: false, icon: "scalemass", sortOrder: 0),
        MeasurementType(id: "height", displayNameKey: "measurement.height", metricUnit: "cm", imperialUnit: "in", isPremium: false, icon: "ruler.fill", sortOrder: 1),
        MeasurementType(id: "waist", displayNameKey: "measurement.waist", metricUnit: "cm", imperialUnit: "in", isPremium: false, icon: "ruler", sortOrder: 2),
        MeasurementType(id: "hip", displayNameKey: "measurement.hip", metricUnit: "cm", imperialUnit: "in", isPremium: true, icon: "figure.stand", sortOrder: 3),
        MeasurementType(id: "chest", displayNameKey: "measurement.chest", metricUnit: "cm", imperialUnit: "in", isPremium: true, icon: "figure.arms.open", sortOrder: 4),
        MeasurementType(id: "arm", displayNameKey: "measurement.arm", metricUnit: "cm", imperialUnit: "in", isPremium: true, icon: "figure.strengthtraining.traditional", sortOrder: 5),
        MeasurementType(id: "leg", displayNameKey: "measurement.leg", metricUnit: "cm", imperialUnit: "in", isPremium: true, icon: "figure.walk", sortOrder: 6),
        MeasurementType(id: "bodyfat", displayNameKey: "measurement.bodyfat", metricUnit: "%", imperialUnit: "%", isPremium: true, icon: "percent", sortOrder: 7),
    ]
    
    static var freeTypes: [MeasurementType] {
        allTypes.filter { !$0.isPremium }
    }
    
    static func accessibleTypes(isPremium: Bool) -> [MeasurementType] {
        isPremium ? allTypes : freeTypes
    }
    
    // Backward compatibility — Codable migration
    enum CodingKeys: String, CodingKey {
        case id, displayNameKey, metricUnit, imperialUnit, isPremium, icon, sortOrder
        // Legacy key
        case unit
    }
    
    init(id: String, displayNameKey: String, metricUnit: String, imperialUnit: String, isPremium: Bool, icon: String, sortOrder: Int) {
        self.id = id
        self.displayNameKey = displayNameKey
        self.metricUnit = metricUnit
        self.imperialUnit = imperialUnit
        self.isPremium = isPremium
        self.icon = icon
        self.sortOrder = sortOrder
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        displayNameKey = try container.decode(String.self, forKey: .displayNameKey)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        icon = try container.decode(String.self, forKey: .icon)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        
        // Try new keys first, fall back to legacy
        if let metric = try? container.decode(String.self, forKey: .metricUnit) {
            metricUnit = metric
            imperialUnit = (try? container.decode(String.self, forKey: .imperialUnit)) ?? metric
        } else if let legacy = try? container.decode(String.self, forKey: .unit) {
            metricUnit = legacy
            imperialUnit = legacy == "kg" ? "lbs" : (legacy == "cm" ? "in" : legacy)
        } else {
            metricUnit = "kg"
            imperialUnit = "lbs"
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayNameKey, forKey: .displayNameKey)
        try container.encode(metricUnit, forKey: .metricUnit)
        try container.encode(imperialUnit, forKey: .imperialUnit)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(icon, forKey: .icon)
        try container.encode(sortOrder, forKey: .sortOrder)
    }
}

// MARK: - BMI Calculator

struct BMICalculator {
    /// Calculates BMI from weight (kg) and height (cm)
    /// Formula: BMI = weight(kg) / height(m)²
    static func calculate(weightKg: Double, heightCm: Double) -> Double? {
        guard heightCm > 0, weightKg > 0 else { return nil }
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }
    
    /// Returns the BMI category
    static func category(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<25: return .normal
        case 25..<30: return .overweight
        default: return .obese
        }
    }
}

enum BMICategory {
    case underweight, normal, overweight, obese
    
    var localizedName: String {
        switch self {
        case .underweight: return L10n.t("measurement.bmi.underweight")
        case .normal: return L10n.t("measurement.bmi.normal")
        case .overweight: return L10n.t("measurement.bmi.overweight")
        case .obese: return L10n.t("measurement.bmi.obese")
        }
    }
    
    var color: Color {
        switch self {
        case .underweight: return .blue
        case .normal: return .green
        case .overweight: return .orange
        case .obese: return .red
        }
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
