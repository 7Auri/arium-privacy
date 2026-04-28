//
//  MeasurementViewModel.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import Foundation

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
    
    private let store = MeasurementStore.shared
    
    var isPremium: Bool {
        PremiumManager.shared.isPremium
    }
    
    init() {
        refreshData()
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
            MeasurementChartPoint(date: entry.date, value: entry.value)
        }
    }
    
    // MARK: - Trend Line (Linear Regression)
    
    func computeTrendLine() -> (slope: Double, intercept: Double)? {
        guard chartData.count >= 2 else { return nil }
        
        let n = Double(chartData.count)
        let referenceDate = chartData.first!.date
        
        // x = days since first data point, y = value
        let points: [(x: Double, y: Double)] = chartData.map { point in
            let x = point.date.timeIntervalSince(referenceDate) / 86400.0 // days
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
}
