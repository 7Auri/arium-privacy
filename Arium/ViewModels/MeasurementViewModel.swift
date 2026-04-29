//
//  MeasurementViewModel.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import Foundation

// MARK: - Weekly Summary

struct MeasurementWeeklySummary {
    let thisWeekAvg: Double
    let lastWeekAvg: Double
    let difference: Double
    let thisWeekCount: Int
    let unit: String
    
    var isImproving: Bool {
        // For weight: lower is usually better (negative diff = good)
        // Generic: just show the difference, let user interpret
        difference != 0
    }
}

// MARK: - Measurement ViewModel

@MainActor
class MeasurementViewModel: ObservableObject {
    @Published var selectedType: MeasurementType = MeasurementType.allTypes[0]
    @Published var filteredEntries: [MeasurementEntry] = []
    @Published var goals: [MeasurementGoal] = []
    @Published var chartData: [MeasurementChartPoint] = []
    @Published var selectedPeriod: MeasurementPeriod = .week
    @Published var isLoading: Bool = false
    @Published var showingPremiumAlert: Bool = false
    @Published var weeklySummary: MeasurementWeeklySummary?
    @Published var currentBMI: Double?
    @Published var bmiCategory: BMICategory?
    
    private let store = MeasurementStore.shared
    
    var isPremium: Bool {
        PremiumManager.shared.isPremium
    }
    
    var unitSystem: UnitSystem {
        UnitSystem(rawValue: UserDefaults.standard.string(forKey: "measurementUnitSystem") ?? "metric") ?? .metric
    }
    
    init() {
        refreshData()
    }
    
    // MARK: - Unit System
    
    func setUnitSystem(_ system: UnitSystem) {
        UserDefaults.standard.set(system.rawValue, forKey: "measurementUnitSystem")
        objectWillChange.send()
        refreshData()
    }
    
    /// Converts a stored metric value to the display unit
    func displayValue(_ metricValue: Double) -> Double {
        UnitConversion.fromMetric(metricValue, type: selectedType, system: unitSystem)
    }
    
    /// Converts a user-entered value to metric for storage
    func toMetric(_ displayValue: Double) -> Double {
        UnitConversion.toMetric(displayValue, type: selectedType, system: unitSystem)
    }
    
    /// Current display unit string
    var displayUnit: String {
        selectedType.unit(for: unitSystem)
    }
    
    // MARK: - Type Selection
    
    func selectType(_ type: MeasurementType) {
        selectedType = type
        refreshData()
    }
    
    // MARK: - Entry CRUD
    
    func addEntry(_ entry: MeasurementEntry) {
        store.addEntry(entry)
        refreshData()
    }
    
    func updateEntry(_ entry: MeasurementEntry) {
        store.updateEntry(entry)
        refreshData()
    }
    
    func deleteEntry(_ entry: MeasurementEntry) {
        store.deleteEntry(entry)
        refreshData()
    }
    
    // MARK: - Goal CRUD
    
    func addGoal(_ goal: MeasurementGoal) throws {
        try store.addGoal(goal)
        refreshData()
    }
    
    func deleteGoal(_ goal: MeasurementGoal) {
        store.deleteGoal(goal)
        refreshData()
    }
    
    // MARK: - Data Refresh
    
    func refreshData() {
        filteredEntries = store.entries(for: selectedType.id)
        goals = store.goals
        computeChartData()
        computeWeeklySummary()
        computeBMI()
    }
    
    // MARK: - Chart Computation
    
    func computeChartData() {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: now) else {
            chartData = []
            return
        }
        
        let typeEntries = store.entries(for: selectedType.id)
            .filter { $0.date >= startDate && $0.date <= now }
            .sorted { $0.date < $1.date }
        
        chartData = typeEntries.map { entry in
            MeasurementChartPoint(date: entry.date, value: displayValue(entry.value))
        }
    }
    
    // MARK: - Trend Line (Linear Regression)
    
    func computeTrendLine() -> (slope: Double, intercept: Double)? {
        guard chartData.count >= 2 else { return nil }
        
        let n = Double(chartData.count)
        let referenceDate = chartData.first!.date
        
        let points: [(x: Double, y: Double)] = chartData.map { point in
            let x = point.date.timeIntervalSince(referenceDate) / 86400.0
            return (x: x, y: point.value)
        }
        
        let sumX = points.reduce(0.0) { $0 + $1.x }
        let sumY = points.reduce(0.0) { $0 + $1.y }
        let sumXY = points.reduce(0.0) { $0 + $1.x * $1.y }
        let sumX2 = points.reduce(0.0) { $0 + $1.x * $1.x }
        
        let denominator = n * sumX2 - sumX * sumX
        guard abs(denominator) > 1e-10 else { return nil }
        
        let slope = (n * sumXY - sumX * sumY) / denominator
        let intercept = (sumY - slope * sumX) / n
        
        return (slope: slope, intercept: intercept)
    }
    
    // MARK: - Weekly Summary
    
    private func computeWeeklySummary() {
        let calendar = Calendar.current
        let now = Date()
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now),
              let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) else {
            weeklySummary = nil
            return
        }
        
        let allEntries = store.entries(for: selectedType.id)
        
        let thisWeek = allEntries.filter { $0.date >= oneWeekAgo && $0.date <= now }
        let lastWeek = allEntries.filter { $0.date >= twoWeeksAgo && $0.date < oneWeekAgo }
        
        guard !thisWeek.isEmpty else {
            weeklySummary = nil
            return
        }
        
        let thisAvg = thisWeek.reduce(0.0) { $0 + $1.value } / Double(thisWeek.count)
        let lastAvg = lastWeek.isEmpty ? thisAvg : lastWeek.reduce(0.0) { $0 + $1.value } / Double(lastWeek.count)
        let diff = thisAvg - lastAvg
        
        weeklySummary = MeasurementWeeklySummary(
            thisWeekAvg: displayValue(thisAvg),
            lastWeekAvg: displayValue(lastAvg),
            difference: displayValue(thisAvg) - displayValue(lastAvg),
            thisWeekCount: thisWeek.count,
            unit: displayUnit
        )
    }
    
    // MARK: - BMI Calculation
    
    private func computeBMI() {
        // BMI sadece weight seçiliyken gösterilir
        guard selectedType.id == "weight" else {
            currentBMI = nil
            bmiCategory = nil
            return
        }
        
        // En son kilo
        guard let latestWeight = store.entries(for: "weight").first else {
            currentBMI = nil
            bmiCategory = nil
            return
        }
        
        // En son boy
        guard let latestHeight = store.entries(for: "height").first else {
            currentBMI = nil
            bmiCategory = nil
            return
        }
        
        // Hesapla (değerler metric olarak saklanıyor)
        if let bmi = BMICalculator.calculate(weightKg: latestWeight.value, heightCm: latestHeight.value) {
            currentBMI = bmi
            bmiCategory = BMICalculator.category(bmi: bmi)
        }
    }
}
