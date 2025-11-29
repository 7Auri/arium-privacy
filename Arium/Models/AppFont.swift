//
//  AppFont.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

enum AppFont: String, Codable, CaseIterable, Identifiable {
    case system = "system"
    case rounded = "rounded"
    case serif = "serif"
    case monospaced = "monospaced"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return L10n.t("font.system")
        case .rounded: return L10n.t("font.rounded")
        case .serif: return L10n.t("font.serif")
        case .monospaced: return L10n.t("font.monospaced")
        }
    }
    
    var preview: String {
        "Aa"
    }
    
    func font(size: CGFloat = 17, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .system:
            return .system(size: size, weight: weight)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        }
    }
}

@MainActor
class FontManager: ObservableObject {
    static let shared = FontManager()
    
    @Published var selectedFont: AppFont = .system
    
    private let saveKey = "SelectedFont"
    private let appGroupSaveKey = "AppFont"
    
    private init() {
        loadFont()
    }
    
    func loadFont() {
        // First try App Group (widgets can access)
        if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
           let savedFont = sharedDefaults.string(forKey: appGroupSaveKey),
           let font = AppFont(rawValue: savedFont) {
            selectedFont = font
            return
        }
        
        // Fallback to normal UserDefaults
        if let savedFont = UserDefaults.standard.string(forKey: saveKey),
           let font = AppFont(rawValue: savedFont) {
            selectedFont = font
            // Also save to App Group for widget access
            if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
                sharedDefaults.set(font.rawValue, forKey: appGroupSaveKey)
                sharedDefaults.synchronize()
            }
        }
    }
    
    func setFont(_ font: AppFont) {
        selectedFont = font
        
        // Save to both local and App Group
        UserDefaults.standard.set(font.rawValue, forKey: saveKey)
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
            sharedDefaults.set(font.rawValue, forKey: appGroupSaveKey)
            sharedDefaults.synchronize()
        }
    }
}


