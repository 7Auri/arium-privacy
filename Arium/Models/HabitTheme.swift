//
//  HabitTheme.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct HabitTheme: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    
    var primary: Color {
        Color(hex: primaryColor)
    }
    
    var secondary: Color {
        Color(hex: secondaryColor)
    }
    
    var accent: Color {
        Color(hex: accentColor)
    }
    
    var localizedName: String {
        L10n.t("theme.\(id)")
    }
    
    var icon: String? {
        switch id {
        case "christmas":
            return "🎄"
        case "cat":
            return "🐱"
        default:
            return nil
        }
    }
    
    static let purple = HabitTheme(
        id: "purple",
        name: "Purple Dream",
        primaryColor: "#E4BBFF",
        secondaryColor: "#F5E6FF",
        accentColor: "#9B59B6"
    )
    
    static let blue = HabitTheme(
        id: "blue",
        name: "Ocean Blue",
        primaryColor: "#BBE0FF",
        secondaryColor: "#E6F3FF",
        accentColor: "#3498DB"
    )
    
    static let green = HabitTheme(
        id: "green",
        name: "Forest Green",
        primaryColor: "#BBFFCC",
        secondaryColor: "#E6FFF0",
        accentColor: "#2ECC71"
    )
    
    static let pink = HabitTheme(
        id: "pink",
        name: "Soft Pink",
        primaryColor: "#FFD4E5",
        secondaryColor: "#FFF0F5",
        accentColor: "#FF69B4"
    )
    
    static let orange = HabitTheme(
        id: "orange",
        name: "Sunset Orange",
        primaryColor: "#FFD4BB",
        secondaryColor: "#FFF0E6",
        accentColor: "#E67E22"
    )
    
    // NEW THEMES
    static let red = HabitTheme(
        id: "red",
        name: "Ruby Red",
        primaryColor: "#FFB3BA",
        secondaryColor: "#FFE6E8",
        accentColor: "#E74C3C"
    )
    
    static let teal = HabitTheme(
        id: "teal",
        name: "Tropical Teal",
        primaryColor: "#A8E6CF",
        secondaryColor: "#E0F7EF",
        accentColor: "#16A085"
    )
    
    static let indigo = HabitTheme(
        id: "indigo",
        name: "Midnight Indigo",
        primaryColor: "#C5CAE9",
        secondaryColor: "#E8EAF6",
        accentColor: "#3F51B5"
    )
    
    static let mint = HabitTheme(
        id: "mint",
        name: "Fresh Mint",
        primaryColor: "#B8F2E6",
        secondaryColor: "#E6FAF5",
        accentColor: "#00D9C0"
    )
    
    static let coral = HabitTheme(
        id: "coral",
        name: "Coral Reef",
        primaryColor: "#FFB3AB",
        secondaryColor: "#FFE6E3",
        accentColor: "#FF7F6A"
    )
    
    static let lavender = HabitTheme(
        id: "lavender",
        name: "Sweet Lavender",
        primaryColor: "#D4C5F9",
        secondaryColor: "#F0EBFF",
        accentColor: "#9B7EDE"
    )
    
    static let gold = HabitTheme(
        id: "gold",
        name: "Golden Hour",
        primaryColor: "#FFE5B4",
        secondaryColor: "#FFF5E1",
        accentColor: "#F39C12"
    )
    
    static let rose = HabitTheme(
        id: "rose",
        name: "Rose Gold",
        primaryColor: "#F4C2C2",
        secondaryColor: "#FDEAEA",
        accentColor: "#E91E63"
    )
    
    static let navy = HabitTheme(
        id: "navy",
        name: "Deep Navy",
        primaryColor: "#A8C5E0",
        secondaryColor: "#E3EEF7",
        accentColor: "#2C3E50"
    )
    
    static let lime = HabitTheme(
        id: "lime",
        name: "Zesty Lime",
        primaryColor: "#D7F5A6",
        secondaryColor: "#F0FBDC",
        accentColor: "#8BC34A"
    )
    
    static let violet = HabitTheme(
        id: "violet",
        name: "Royal Violet",
        primaryColor: "#D8B5E8",
        secondaryColor: "#F2E6F7",
        accentColor: "#8E44AD"
    )
    
    static let turquoise = HabitTheme(
        id: "turquoise",
        name: "Azure Turquoise",
        primaryColor: "#A8E6E3",
        secondaryColor: "#E0F7F6",
        accentColor: "#1ABC9C"
    )
    
    static let crimson = HabitTheme(
        id: "crimson",
        name: "Bold Crimson",
        primaryColor: "#FFB3C1",
        secondaryColor: "#FFE6EC",
        accentColor: "#C0392B"
    )
    
    static let sage = HabitTheme(
        id: "sage",
        name: "Calm Sage",
        primaryColor: "#C7DCA7",
        secondaryColor: "#EBF3DC",
        accentColor: "#87A96B"
    )
    
    static let peach = HabitTheme(
        id: "peach",
        name: "Peachy Keen",
        primaryColor: "#FFDAB9",
        secondaryColor: "#FFF3E6",
        accentColor: "#FF9A76"
    )
    
    static let christmas = HabitTheme(
        id: "christmas",
        name: "Christmas",
        primaryColor: "#FFB3BA",
        secondaryColor: "#FFE6E8",
        accentColor: "#DC143C"
    )
    
    static let cat = HabitTheme(
        id: "cat",
        name: "Kitty",
        primaryColor: "#FFD4B3",
        secondaryColor: "#FFF0E6",
        accentColor: "#FF8C69"
    )
    
    var isAvailable: Bool {
        switch id {
        case "christmas":
            let calendar = Calendar.current
            let month = calendar.component(.month, from: Date())
            // Available in December (12) and January (1)
            return month == 12 || month == 1
        default:
            return true
        }
    }
    
    static var availableThemes: [HabitTheme] {
        allThemes.filter { $0.isAvailable }
    }

    static let allThemes: [HabitTheme] = [
        // Original
        .purple, .blue, .green, .pink, .orange,
        // New
        .red, .teal, .indigo, .mint, .coral,
        .lavender, .gold, .rose, .navy, .lime,
        .violet, .turquoise, .crimson, .sage, .peach,
        // Special Occasions
        .christmas,
        // Fun Themes
        .cat
    ]
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

