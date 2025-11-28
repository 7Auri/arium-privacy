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
    
    private init() {
        loadFont()
    }
    
    func loadFont() {
        if let savedFont = UserDefaults.standard.string(forKey: saveKey),
           let font = AppFont(rawValue: savedFont) {
            selectedFont = font
        }
    }
    
    func setFont(_ font: AppFont) {
        selectedFont = font
        UserDefaults.standard.set(font.rawValue, forKey: saveKey)
    }
}

