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
}

