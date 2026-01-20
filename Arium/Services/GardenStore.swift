//
//  GardenStore.swift
//  Arium
//
//  Created by Arium AI.
//

import SwiftUI
import Combine

class GardenStore: ObservableObject {
    static let shared = GardenStore()
    
    @Published var waterAvailable: Int = 0
    @Published var plants: [Plant] = []
    
    private let waterKey = "arium_garden_water"
    private let plantsKey = "arium_garden_plants"
    
    init() {
        loadData()
        
        // Initialize starter plant if empty (deferred to avoid state modification during view update)
        Task { @MainActor in
            if plants.isEmpty {
                plants.append(Plant(type: .succulent, isUnlocked: true))
                savePlants()
            }
        }
    }
    
    func addWater(amount: Int = 1) {
        waterAvailable += amount
        UserDefaults.standard.set(waterAvailable, forKey: waterKey)
    }
    
    func waterPlant(plantId: UUID) {
        guard waterAvailable > 0 else { return }
        guard let index = plants.firstIndex(where: { $0.id == plantId }) else { return }
        
        waterAvailable -= 1
        UserDefaults.standard.set(waterAvailable, forKey: waterKey)
        
        let evolved = plants[index].water()
        if evolved {
            HapticManager.success()
        } else {
            HapticManager.selection()
        }
        
        savePlants()
    }
    
    @MainActor
    func unlockNewPlant(type: PlantType, premiumManager: PremiumManager) -> Bool {
        // Validation
        if !premiumManager.isPremium && type.isPremium {
            return false
        }
        
        // Check if already exists
        if plants.contains(where: { $0.type == type }) {
            return false
        }
        
        let newPlant = Plant(type: type, isUnlocked: true)
        plants.append(newPlant)
        savePlants()
        return true
    }
    
    // MARK: - Persistence
    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: plantsKey)
        }
    }
    
    private func loadData() {
        waterAvailable = UserDefaults.standard.integer(forKey: waterKey)
        
        if let data = UserDefaults.standard.data(forKey: plantsKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        }
    }
}
