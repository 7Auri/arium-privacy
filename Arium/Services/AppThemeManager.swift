//
//  AppThemeManager.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import Foundation
import SwiftUI

enum AppAccentColor: String, CaseIterable, Identifiable {
    case purple = "purple"
    case blue = "blue"
    case green = "green"
    case pink = "pink"
    case orange = "orange"
    case teal = "teal"
    case indigo = "indigo"
    case red = "red"
    case mint = "mint"
    case coral = "coral"
    case lavender = "lavender"
    case gold = "gold"
    case rose = "rose"
    case navy = "navy"
    case lime = "lime"
    case violet = "violet"
    case turquoise = "turquoise"
    case crimson = "crimson"
    case sage = "sage"
    case peach = "peach"
    
    // Special Occasion Themes
    case christmas = "christmas"
    
    var id: String { rawValue }
    
    var isSpecialOccasion: Bool {
        switch self {
        case .christmas:
            return true
        default:
            return false
        }
    }
    
    var specialOccasionDateRange: (start: (month: Int, day: Int), end: (month: Int, day: Int))? {
        switch self {
        case .christmas:
            return ((12, 1), (12, 31)) // December 1-31
        default:
            return nil
        }
    }
    
    var isCurrentlyActive: Bool {
        guard let dateRange = specialOccasionDateRange else { return false }
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentDay = calendar.component(.day, from: now)
        
        let startMonth = dateRange.start.month
        let startDay = dateRange.start.day
        let endMonth = dateRange.end.month
        let endDay = dateRange.end.day
        
        // Check if current date is within range
        if currentMonth == startMonth && currentMonth == endMonth {
            return currentDay >= startDay && currentDay <= endDay
        } else if currentMonth == startMonth {
            return currentDay >= startDay
        } else if currentMonth == endMonth {
            return currentDay <= endDay
        } else if startMonth < endMonth {
            return currentMonth > startMonth && currentMonth < endMonth
        } else {
            // Range spans across year boundary (e.g., Dec 1 - Jan 7)
            return currentMonth >= startMonth || currentMonth <= endMonth
        }
    }
    
    var color: Color {
        switch self {
        case .purple:
            return Color(hex: "#9B59B6")
        case .blue:
            return Color(hex: "#3498DB")
        case .green:
            return Color(hex: "#2ECC71")
        case .pink:
            return Color(hex: "#FF69B4")
        case .orange:
            return Color(hex: "#E67E22")
        case .teal:
            return Color(hex: "#1ABC9C")
        case .indigo:
            return Color(hex: "#5B6BC6")
        case .red:
            return Color(hex: "#E74C3C")
        case .mint:
            return Color(hex: "#00D9C0")
        case .coral:
            return Color(hex: "#FF7F6A")
        case .lavender:
            return Color(hex: "#9B7EDE")
        case .gold:
            return Color(hex: "#F39C12")
        case .rose:
            return Color(hex: "#E91E63")
        case .navy:
            return Color(hex: "#2C3E50")
        case .lime:
            return Color(hex: "#8BC34A")
        case .violet:
            return Color(hex: "#8E44AD")
        case .turquoise:
            return Color(hex: "#1ABC9C")
        case .crimson:
            return Color(hex: "#C0392B")
        case .sage:
            return Color(hex: "#87A96B")
        case .peach:
            return Color(hex: "#FF9A76")
        case .christmas:
            return Color(hex: "#DC143C") // Christmas Red
        }
    }
    
    var lightColor: Color {
        switch self {
        case .purple:
            return Color(hex: "#E4BBFF")
        case .blue:
            return Color(hex: "#BBE0FF")
        case .green:
            return Color(hex: "#BBFFCC")
        case .pink:
            return Color(hex: "#FFD4E5")
        case .orange:
            return Color(hex: "#FFD4BB")
        case .teal:
            return Color(hex: "#A8E6CF")
        case .indigo:
            return Color(hex: "#C5CCF0")
        case .red:
            return Color(hex: "#F5B7B1")
        case .mint:
            return Color(hex: "#B8F2E6")
        case .coral:
            return Color(hex: "#FFB3AB")
        case .lavender:
            return Color(hex: "#D4C5F9")
        case .gold:
            return Color(hex: "#FFE5B4")
        case .rose:
            return Color(hex: "#F4C2C2")
        case .navy:
            return Color(hex: "#A8C5E0")
        case .lime:
            return Color(hex: "#D7F5A6")
        case .violet:
            return Color(hex: "#D8B5E8")
        case .turquoise:
            return Color(hex: "#A8E6E3")
        case .crimson:
            return Color(hex: "#FFB3C1")
        case .sage:
            return Color(hex: "#C7DCA7")
        case .peach:
            return Color(hex: "#FFDAB9")
        case .christmas:
            return Color(hex: "#FFB3BA") // Light Christmas Red
        }
    }
    
    var name: String {
        switch self {
        case .purple:
            return L10n.t("appTheme.purple")
        case .blue:
            return L10n.t("appTheme.blue")
        case .green:
            return L10n.t("appTheme.green")
        case .pink:
            return L10n.t("appTheme.pink")
        case .orange:
            return L10n.t("appTheme.orange")
        case .teal:
            return L10n.t("appTheme.teal")
        case .indigo:
            return L10n.t("appTheme.indigo")
        case .red:
            return L10n.t("appTheme.red")
        case .mint:
            return L10n.t("appTheme.mint")
        case .coral:
            return L10n.t("appTheme.coral")
        case .lavender:
            return L10n.t("appTheme.lavender")
        case .gold:
            return L10n.t("appTheme.gold")
        case .rose:
            return L10n.t("appTheme.rose")
        case .navy:
            return L10n.t("appTheme.navy")
        case .lime:
            return L10n.t("appTheme.lime")
        case .violet:
            return L10n.t("appTheme.violet")
        case .turquoise:
            return L10n.t("appTheme.turquoise")
        case .crimson:
            return L10n.t("appTheme.crimson")
        case .sage:
            return L10n.t("appTheme.sage")
        case .peach:
            return L10n.t("appTheme.peach")
        case .christmas:
            return L10n.t("appTheme.christmas")
        }
    }
    
    var icon: String {
        switch self {
        case .christmas:
            return "🎄"
        default:
            return ""
        }
    }
}

@MainActor
class AppThemeManager: ObservableObject {
    static let shared = AppThemeManager()
    
    @Published var accentColor: AppAccentColor {
        didSet {
            UserDefaults.standard.set(accentColor.rawValue, forKey: "appAccentColor")
            updateAriumTheme()
        }
    }
    
    private init() {
        // Initialize with a default value first
        var initialColor: AppAccentColor = .purple
        
        // Check if user has manually set an accent color in Settings
        if let savedColor = UserDefaults.standard.string(forKey: "appAccentColor"),
           let color = AppAccentColor(rawValue: savedColor) {
            // If it's a special occasion theme, check if it's still active
            if color.isSpecialOccasion && !color.isCurrentlyActive {
                // Special occasion has passed, check for auto-switch setting
                let autoSwitchEnabled = UserDefaults.standard.bool(forKey: "autoSwitchSpecialThemes")
                if autoSwitchEnabled {
                    // Find next active special theme or fallback
                    if let nextActive = Self.findNextActiveSpecialTheme() {
                        initialColor = nextActive
                    } else if let onboardingThemeId = UserDefaults.standard.string(forKey: "selectedOnboardingTheme"),
                              let onboardingColor = AppAccentColor(rawValue: onboardingThemeId) {
                        initialColor = onboardingColor
                    } else {
                        initialColor = .purple
                    }
                } else {
                    // Keep the theme even if not active
                    initialColor = color
                }
            } else {
                initialColor = color
            }
        }
        // If not, check if user selected a theme during onboarding
        else if let onboardingThemeId = UserDefaults.standard.string(forKey: "selectedOnboardingTheme"),
                let onboardingColor = AppAccentColor(rawValue: onboardingThemeId) {
            initialColor = onboardingColor
            // Save it to appAccentColor so it persists
            UserDefaults.standard.set(onboardingColor.rawValue, forKey: "appAccentColor")
        }
        // Check for active special occasion themes
        else if let activeSpecialTheme = Self.findNextActiveSpecialTheme() {
            let autoSwitchEnabled = UserDefaults.standard.bool(forKey: "autoSwitchSpecialThemes")
            if autoSwitchEnabled {
                initialColor = activeSpecialTheme
            } else {
                initialColor = .purple // Default
            }
        }
        
        // Now initialize the stored property
        self.accentColor = initialColor
        updateAriumTheme()
    }
    
    private static func findNextActiveSpecialTheme() -> AppAccentColor? {
        return AppAccentColor.allCases.first { $0.isSpecialOccasion && $0.isCurrentlyActive }
    }
    
    private func updateAriumTheme() {
        // AriumTheme artık computed property olarak AppThemeManager'ı kullanıyor
        // Burada ek güncelleme gerekmiyor
    }
}

