//
//  AccessibilityHelpers.swift
//  Arium
//
//  Created by Zorbey on 22.11.2025.
//

import SwiftUI

extension View {
    /// Adds accessibility label for VoiceOver (convenience method)
    func ariumAccessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(Text(label))
    }
    
    /// Adds accessibility hint for VoiceOver (convenience method)
    func ariumAccessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(Text(hint))
    }
}

// MARK: - Dynamic Type Support

extension Font {
    static func ariumTitle() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static func ariumHeadline() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static func ariumBody() -> Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    
    static func ariumCaption() -> Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
    
    // Dancing Script font for app name
    static func dancingScript(size: CGFloat) -> Font {
        // Try different possible font names for Dancing Script
        // Variable fonts use different naming conventions
        let fontNames = [
            "DancingScript-VariableFont_wght",  // Variable font name
            "DancingScript-Regular",
            "DancingScript",
            "Dancing Script"
        ]
        
        for fontName in fontNames {
            if let font = UIFont(name: fontName, size: size) {
                print("✅ Found Dancing Script font: \(fontName)")
                return .custom(fontName, size: size)
            }
        }
        
        // Debug: Print all available fonts containing "Dancing"
        print("⚠️ Dancing Script font not found. Available fonts with 'Dancing':")
        UIFont.familyNames.forEach { family in
            if family.lowercased().contains("dancing") {
                print("   Family: \(family)")
                UIFont.fontNames(forFamilyName: family).forEach { name in
                    print("     - \(name)")
                }
            }
        }
        
        // Fallback to system serif italic if font not loaded
        print("⚠️ Using fallback font: system serif italic")
        return .system(size: size, weight: .ultraLight, design: .serif).italic()
    }
}

