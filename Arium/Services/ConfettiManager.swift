//
//  ConfettiManager.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import Foundation
import SwiftUI

@MainActor
class ConfettiManager: ObservableObject {
    static let shared = ConfettiManager()
    
    // MARK: - Settings
    
    @AppStorage("confettiIntensity") var intensity: ConfettiIntensity = .normal
    @AppStorage("confettiSoundEnabled") var soundEnabled: Bool = true
    @AppStorage("confettiCustomColors") var useCustomColors: Bool = false
    
    // MARK: - Celebration Types
    
    enum CelebrationType {
        case allHabitsCompleted
        case streak7Days
        case streak30Days
        case streak100Days
        case milestone(Int)
        
        func particleCount(intensity: ConfettiIntensity = .normal) -> Int {
            switch self {
            case .allHabitsCompleted:
                return intensity.particleCount
            case .streak7Days:
                return 100
            case .streak30Days:
                return 200
            case .streak100Days:
                return 300
            case .milestone(let days):
                return min(250, 100 + (days / 10) * 10)
            }
        }
        
        var duration: Double {
            switch self {
            case .allHabitsCompleted:
                return 6.0
            case .streak7Days:
                return 4.0
            case .streak30Days:
                return 7.0
            case .streak100Days:
                return 10.0
            case .milestone:
                return 8.0
            }
        }
        
        var message: String {
            switch self {
            case .allHabitsCompleted:
                return L10n.t("celebration.message")
            case .streak7Days:
                return L10n.t("celebration.streak.7days")
            case .streak30Days:
                return L10n.t("celebration.streak.30days")
            case .streak100Days:
                return L10n.t("celebration.streak.100days")
            case .milestone(let days):
                return String(format: L10n.t("celebration.milestone"), days)
            }
        }
    }
    
    enum ConfettiIntensity: String, CaseIterable {
        case low = "low"
        case normal = "normal"
        case high = "high"
        
        var particleCount: Int {
            switch self {
            case .low:
                return 75
            case .normal:
                return 150
            case .high:
                return 250
            }
        }
        
        var displayName: String {
            switch self {
            case .low:
                return L10n.t("confetti.intensity.low")
            case .normal:
                return L10n.t("confetti.intensity.normal")
            case .high:
                return L10n.t("confetti.intensity.high")
            }
        }
    }
    
    private init() {}
    
    // MARK: - Get Colors
    
    func getColors(for theme: Color? = nil) -> [Color] {
        if useCustomColors, let theme = theme {
            return generateThemeColors(theme: theme)
        }
        
        return [
            .red, .blue, .green, .yellow, .pink, .purple, .orange,
            .cyan, .mint, .indigo
        ]
    }
    
    private func generateThemeColors(theme: Color) -> [Color] {
        // Generate variations of the theme color
        return [
            theme,
            theme.opacity(0.8),
            theme.opacity(0.6),
            theme.opacity(0.4),
            theme.opacity(0.9)
        ]
    }
}
