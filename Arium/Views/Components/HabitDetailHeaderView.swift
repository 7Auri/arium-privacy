//
//  HabitDetailHeaderView.swift
//  Arium
//
//  Created by Auto on 06.12.2025.
//

import SwiftUI

struct HabitDetailHeaderView: View {
    let habit: Habit
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Progress Ring with animation
                ProgressRing(
                    progress: habit.isCompletedToday ? 1.0 : 0.0,
                    lineWidth: 10,
                    color: habit.theme.accent
                )
                .frame(width: 140, height: 140)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: habit.isCompletedToday)
                
                VStack(spacing: 6) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(habit.isCompletedToday ? habit.theme.accent : Color(.tertiaryLabel))
                        .symbolEffect(.bounce, value: habit.isCompletedToday)
                    
                    Text("\(habit.streak)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(L10n.t("habit.streak"))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Category Badge with improved styling
            HStack(spacing: 8) {
                Image(systemName: habit.category.systemIcon)
                    .font(.caption)
                Text(habit.category.localizedName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [habit.category.color, habit.category.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(
                color: habit.category.color.opacity(0.4),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(habit.theme.accent.opacity(0.2), lineWidth: 1)
        )
    }
}
