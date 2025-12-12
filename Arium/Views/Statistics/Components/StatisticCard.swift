//
//  StatisticCard.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .applyAppFont(size: 28)
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 4) {
                Text(value)
                    .applyAppFont(size: 24, weight: .bold)
                    .foregroundColor(AriumTheme.textPrimary)
                
                Text(title)
                    .applyAppFont(size: 12)
                    .foregroundColor(AriumTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .cardStyle()
    }
}

#Preview {
    HStack {
        StatisticCard(
            title: "Current Streak",
            value: "7",
            icon: "flame.fill",
            color: AriumTheme.warning
        )
        
        StatisticCard(
            title: "Best Streak",
            value: "14",
            icon: "star.fill",
            color: AriumTheme.accent
        )
    }
    .padding()
}

