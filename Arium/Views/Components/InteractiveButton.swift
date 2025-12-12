//
//  InteractiveButton.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct InteractiveButton: ViewModifier {
    @State private var isPressed = false
    let hapticStyle: HapticStyle
    
    enum HapticStyle {
        case none
        case light
        case medium
        case selection
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .brightness(isPressed ? -0.05 : 0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            switch hapticStyle {
                            case .light:
                                HapticManager.light()
                            case .medium:
                                HapticManager.medium()
                            case .selection:
                                HapticManager.selection()
                            case .none:
                                break
                            }
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                isPressed = true
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPressed = false
                        }
                    }
            )
    }
}

extension View {
    func interactiveButton(haptic: InteractiveButton.HapticStyle = .selection) -> some View {
        modifier(InteractiveButton(hapticStyle: haptic))
    }
}
