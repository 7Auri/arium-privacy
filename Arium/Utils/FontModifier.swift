//
//  FontModifier.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

// View modifier to apply font to all text views
@MainActor
struct AppFontModifier: ViewModifier {
    @ObservedObject private var fontManager = FontManager.shared
    
    func body(content: Content) -> some View {
        content
            .onChange(of: fontManager.selectedFont) { _, _ in
                // Force view update when font changes
            }
    }
}

extension View {
    func appFont() -> some View {
        modifier(AppFontModifier())
    }
}

// Extension to get current app font
extension FontManager {
    func font(size: CGFloat = 17, weight: Font.Weight = .regular) -> Font {
        // FontManager is @MainActor, so this is safe
        return selectedFont.font(size: size, weight: weight)
    }
}

// Helper extension for Text views to use app font
extension Text {
    @MainActor func appFont(size: CGFloat = 17, weight: Font.Weight = .regular) -> Text {
        self.font(FontManager.shared.font(size: size, weight: weight))
    }
}
