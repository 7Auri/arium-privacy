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
    
    var id: String { rawValue }
    
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
        if let savedColor = UserDefaults.standard.string(forKey: "appAccentColor"),
           let color = AppAccentColor(rawValue: savedColor) {
            self.accentColor = color
        } else {
            self.accentColor = .purple // Default
        }
        updateAriumTheme()
    }
    
    private func updateAriumTheme() {
        // AriumTheme artık computed property olarak AppThemeManager'ı kullanıyor
        // Burada ek güncelleme gerekmiyor
    }
}

