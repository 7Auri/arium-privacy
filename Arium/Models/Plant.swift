//
//  Plant.swift
//  Arium
//
//  Created by Arium AI.
//

import Foundation

enum PlantType: String, Codable, CaseIterable {
    case succulent
    case monstera
    case cactus
    case fern
    case sunflower
    
    var displayName: String {
        switch self {
        case .succulent: return L10n.t("plant.succulent")
        case .monstera: return L10n.t("plant.monstera")
        case .cactus: return L10n.t("plant.cactus")
        case .fern: return L10n.t("plant.fern")
        case .sunflower: return L10n.t("plant.sunflower")
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .succulent: return false
        default: return true
        }
    }
    
    var maxStage: Int {
        return 3 // Seed, Sprout, Small, Mature
    }
}

struct Plant: Identifiable, Codable {
    let id: UUID
    let type: PlantType
    var growthStage: Int // 0: Seed, 1: Sprout, 2: Growing, 3: Mature
    var waterCount: Int // Current water poured
    var waterToNextStage: Int
    var isUnlocked: Bool
    
    init(type: PlantType, isUnlocked: Bool = false) {
        self.id = UUID()
        self.type = type
        self.growthStage = 0
        self.waterCount = 0
        self.waterToNextStage = 10 // Base requirement
        self.isUnlocked = isUnlocked
    }
    
    
    var imageName: String {
        switch growthStage {
        case 0: return "plant_seed"
        case 1: return "plant_sprout"
        case 2: return "plant_sprout" // Placeholder for growing stage
        default: return "plant_\(type.rawValue)_3"
        }
    }
    
    mutating func water() -> Bool {
        waterCount += 1
        if waterCount >= waterToNextStage {
            if growthStage < type.maxStage {
                growthStage += 1
                waterCount = 0
                waterToNextStage = Int(Double(waterToNextStage) * 1.5)
                return true // Evolved
            }
        }
        return false
    }
}
