//
//  HabitTheme.swift
//  Arium (Shared)
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
    
    static let allThemes: [HabitTheme] = [
        .purple, .blue, .green, .pink, .orange
    ]
}

// MARK: - Color Extension

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

