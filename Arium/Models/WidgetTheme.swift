//
//  WidgetTheme.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

enum WidgetTheme: String, Codable, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case gradient = "gradient"
    case minimal = "minimal"
    case colorful = "colorful"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .light: return L10n.t("widgetTheme.light")
        case .dark: return L10n.t("widgetTheme.dark")
        case .gradient: return L10n.t("widgetTheme.gradient")
        case .minimal: return L10n.t("widgetTheme.minimal")
        case .colorful: return L10n.t("widgetTheme.colorful")
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .light: return Color.white
        case .dark: return Color.black
        case .gradient: return Color.clear
        case .minimal: return Color(.systemGray6)
        case .colorful: return Color.purple.opacity(0.1)
        }
    }
    
    var textColor: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        case .gradient: return .white
        case .minimal: return .primary
        case .colorful: return .primary
        }
    }
    
    var gradientColors: [Color]? {
        switch self {
        case .gradient:
            return [Color.purple, Color.blue, Color.pink]
        case .colorful:
            return [Color.purple.opacity(0.3), Color.blue.opacity(0.2)]
        default:
            return nil
        }
    }
}

@MainActor
class WidgetThemeManager: ObservableObject {
    static let shared = WidgetThemeManager()
    
    @Published var selectedTheme: WidgetTheme = .light
    
    private let saveKey = "SelectedWidgetTheme"
    private let appGroupSaveKey = "WidgetTheme"
    
    private init() {
        loadTheme()
    }
    
    func loadTheme() {
        // First try App Group (widgets can access)
        if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
           let savedTheme = sharedDefaults.string(forKey: appGroupSaveKey),
           let theme = WidgetTheme(rawValue: savedTheme) {
            selectedTheme = theme
            return
        }
        
        // Fallback to normal UserDefaults
        if let savedTheme = UserDefaults.standard.string(forKey: saveKey),
           let theme = WidgetTheme(rawValue: savedTheme) {
            selectedTheme = theme
            // Also save to App Group for widget access
            if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
                sharedDefaults.set(theme.rawValue, forKey: appGroupSaveKey)
                sharedDefaults.synchronize()
            }
        }
    }
    
    func setTheme(_ theme: WidgetTheme) {
        selectedTheme = theme
        
        // Save to both local and App Group
        UserDefaults.standard.set(theme.rawValue, forKey: saveKey)
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
            sharedDefaults.set(theme.rawValue, forKey: appGroupSaveKey)
            sharedDefaults.synchronize()
        }
    }
}


