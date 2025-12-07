//
//  FontModifier.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct AppFontModifier: ViewModifier {
    @EnvironmentObject var fontManager: FontManager
    
    func body(content: Content) -> some View {
        content
            .font(fontManager.selectedFont.font())
    }
}

extension View {
    func appFont() -> some View {
        modifier(AppFontModifier())
    }
}
