//
//  FontHelper.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

// Helper to apply app font to views
extension View {
    /// Applies the selected app font to this view
    func applyAppFont(size: CGFloat = 17, weight: Font.Weight = .regular) -> some View {
        self.font(FontManager.shared.font(size: size, weight: weight))
    }
}

// Predefined font sizes using app font
extension FontManager {
    func titleFont() -> Font { 
        font(size: 28, weight: .bold) 
    }
    func headlineFont() -> Font { 
        font(size: 20, weight: .semibold) 
    }
    func bodyFont() -> Font { 
        font(size: 16, weight: .regular) 
    }
    func captionFont() -> Font { 
        font(size: 14, weight: .regular) 
    }
    func largeTitleFont() -> Font { 
        font(size: 34, weight: .bold) 
    }
}

// Override system font modifiers to use app font
extension View {
    /// Replaces .font(.system(...)) with app font
    func appSystemFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design? = nil) -> some View {
        self.font(FontManager.shared.font(size: size, weight: weight))
    }
}
