//
//  InsightCard.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI

struct InsightCard: View {
    let insight: Insight
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: insight.type.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(insight.type.color.gradient)
                    )
                
                Spacer()
                
                Text(L10n.t("insights.badge"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(insight.type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    InsightCard(insight: Insight(
        type: .streakMaster,
        title: "Zincir Kırılmıyor! 🔥",
        message: "'Kitap Oku' alışkanlığında 12 gündür harikasın.",
        relatedHabitId: nil
    ))
}
