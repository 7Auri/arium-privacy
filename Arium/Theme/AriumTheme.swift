//
//  AriumTheme.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct AriumTheme {
    // Background Colors
    static let background = AriumColors.background
    static let cardBackground = AriumColors.card
    static let secondaryBackground = AriumColors.background
    
    // Text Colors
    static let textPrimary = AriumColors.textPrimary
    static let textSecondary = AriumColors.textSecondary
    static let textTertiary = AriumColors.textTertiary
    
    // Accent Colors
    static let accent = AriumColors.accent
    static let accentLight = AriumColors.accentLight
    static let success = AriumColors.success
    static let warning = AriumColors.warning
    static let danger = AriumColors.danger
    
    // Spacing
    static let spacing: CGFloat = 8
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 8
    static let cardBorder = AriumColors.cardBorder
    
    // Animation
    static let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

// Custom View Modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AriumTheme.cardBackground)
            .cornerRadius(AriumTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AriumTheme.cornerRadius)
                    .stroke(AriumTheme.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// Progress Ring Shape
struct ProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 8
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(AriumTheme.springAnimation, value: progress)
        }
    }
}

