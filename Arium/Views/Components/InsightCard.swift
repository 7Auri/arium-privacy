//
//  InsightCard.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI

struct InsightCard: View {
    let insight: Insight
    var onAction: ((InsightAction, Insight) -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingActions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: insight.type.icon)
                    .applyAppFont(size: 22, weight: .semibold)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(insight.type.color.gradient)
                    )
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(L10n.t("insights.badge"))
                        .applyAppFont(size: 12)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    
                    // Confidence indicator
                    if insight.confidence < 0.7 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .applyAppFont(size: 11)
                            Text("\(Int(insight.confidence * 100))%")
                                .applyAppFont(size: 11)
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .applyAppFont(size: 17, weight: .bold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text(insight.message)
                    .applyAppFont(size: 15)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Actionable Insights
            if !insight.suggestedActions.isEmpty {
                Divider()
                
                Button {
                    showingActions.toggle()
                } label: {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .applyAppFont(size: 12)
                        Text(L10n.t("insights.suggestedActions"))
                            .applyAppFont(size: 12)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: showingActions ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(insight.type.color)
                }
                
                if showingActions {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(insight.suggestedActions) { action in
                            ActionButton(
                                action: action,
                                habitId: insight.relatedHabitId,
                                onTap: {
                                    onAction?(action, insight)
                                }
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
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
        .animation(.easeInOut(duration: 0.2), value: showingActions)
    }
}

// Action Button for actionable insights
struct ActionButton: View {
    let action: InsightAction
    let habitId: UUID?
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.caption)
                Text(action.title)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .foregroundColor(.accentColor)
            .cornerRadius(8)
        }
    }
}

#Preview {
    InsightCard(insight: Insight(
        type: .streakMaster,
        title: "Zincir Kırılmıyor! 🔥",
        message: "'Kitap Oku' alışkanlığında 12 gündür harikasın.",
        relatedHabitId: nil,
        suggestedActions: [.celebrateAchievement, .reviewProgress(UUID())],
        confidence: 0.9
    ))
    .environmentObject(HabitStore())
}
