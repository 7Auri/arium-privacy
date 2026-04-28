//
//  MeasurementStore.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import Foundation
import OSLog

// MARK: - Measurement Store Errors

enum MeasurementStoreError: Error, LocalizedError {
    case goalLimitReached
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .goalLimitReached:
            return L10n.t("measurement.goal.freeLimitReached")
        case .saveFailed:
            return "Failed to save measurement data"
        }
    }
}

// MARK: - Measurement Store

@MainActor
class MeasurementStore: ObservableObject {
    static let shared = MeasurementStore()
    
    @Published var entries: [MeasurementEntry] = []
    @Published var goals: [MeasurementGoal] = []
    
    private let entriesKey = "SavedMeasurements"
    private let goalsKey = "SavedMeasurementGoals"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Arium", category: "MeasurementStore")
    private var saveTask: Task<Void, Error>?
    
    private init() {
        loadData()
    }
    
    // MARK: - Persistence
    
    func loadData() {
        // Load entries
        if let data = UserDefaults.standard.data(forKey: entriesKey) {
            do {
                let decoded = try JSONDecoder().decode([MeasurementEntry].self, from: data)
                entries = decoded
                logger.info("✅ Loaded \(decoded.count) measurement entries")
            } catch {
                logger.error("❌ Failed to load measurement entries: \(error.localizedDescription)")
                entries = []
            }
        }
        
        // Load goals
        if let data = UserDefaults.standard.data(forKey: goalsKey) {
            do {
                let decoded = try JSONDecoder().decode([MeasurementGoal].self, from: data)
                goals = decoded
                logger.info("✅ Loaded \(decoded.count) measurement goals")
            } catch {
                logger.error("❌ Failed to load measurement goals: \(error.localizedDescription)")
                goals = []
            }
        }
    }
    
    func saveData(immediate: Bool = false) {
        saveTask?.cancel()
        
        if immediate {
            saveDataImmediate()
        } else {
            saveTask = Task {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second debounce
                await MainActor.run {
                    self.saveDataImmediate()
                }
            }
        }
    }
    
    private func saveDataImmediate() {
        do {
            let entriesData = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(entriesData, forKey: entriesKey)
            
            let goalsData = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(goalsData, forKey: goalsKey)
            
            logger.debug("✅ Saved \(self.entries.count) entries and \(self.goals.count) goals")
        } catch {
            logger.error("❌ Failed to save measurement data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Entry CRUD
    
    func addEntry(_ entry: MeasurementEntry) {
        entries.append(entry)
        saveData(immediate: true)
    }
    
    func updateEntry(_ entry: MeasurementEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveData(immediate: true)
        }
    }
    
    func deleteEntry(_ entry: MeasurementEntry) {
        entries.removeAll { $0.id == entry.id }
        saveData()
    }
    
    func entries(for typeId: String) -> [MeasurementEntry] {
        entries
            .filter { $0.typeId == typeId }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Goal CRUD
    
    func canAddGoal() -> Bool {
        let isPremium = PremiumManager.shared.isPremium
        if isPremium { return true }
        return goals.count < 1
    }
    
    func addGoal(_ goal: MeasurementGoal) throws {
        guard canAddGoal() else {
            throw MeasurementStoreError.goalLimitReached
        }
        goals.append(goal)
        saveData(immediate: true)
    }
    
    func deleteGoal(_ goal: MeasurementGoal) {
        goals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    func goal(for typeId: String) -> MeasurementGoal? {
        goals.first { $0.typeId == typeId }
    }
}
