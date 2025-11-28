//
//  RepetitionProgressView.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

/// Shows progress for habits with daily repetitions
struct RepetitionProgressView: View {
    let habit: Habit
    let compact: Bool
    
    init(habit: Habit, compact: Bool = false) {
        self.habit = habit
        self.compact = compact
    }
    
    var body: some View {
        if habit.dailyRepetitions > 1 {
            if compact {
                compactView
            } else {
                expandedView
            }
        }
    }
    
    // MARK: - Compact View (for habit card)
    
    private var compactView: some View {
        HStack(spacing: 4) {
            ForEach(0..<habit.dailyRepetitions, id: \.self) { index in
                Circle()
                    .fill(habit.todayCompletions.contains(index) ? habit.theme.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    // MARK: - Expanded View (for detail view)
    
    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(L10n.t("repetition.title"))
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: L10n.t("repetition.progress"), habit.todayCompletions.count, habit.dailyRepetitions))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [habit.theme.accentColor, habit.theme.accentColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(habit.completionPercentage), height: 8)
                        .animation(.spring(response: 0.3), value: habit.completionPercentage)
                }
            }
            .frame(height: 8)
        }
    }
}

/// Individual repetition checkbox
struct RepetitionCheckboxView: View {
    let habit: Habit
    let index: Int
    let onToggle: (Int) -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.selection()
            onToggle(index)
        }) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    Circle()
                        .strokeBorder(isCompleted ? habit.theme.accentColor : Color.secondary.opacity(0.5), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(habit.theme.accentColor)
                    }
                }
                
                // Label
                Text(label)
                    .font(.body)
                    .foregroundColor(isCompleted ? .primary : .secondary)
                
                Spacer()
                
                // Time (optional)
                if isCompleted, let completionTime = getCompletionTime() {
                    Text(completionTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? habit.theme.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var isCompleted: Bool {
        habit.isRepetitionCompleted(at: index)
    }
    
    private var label: String {
        habit.displayRepetitionLabels.indices.contains(index) ? 
            habit.displayRepetitionLabels[index] : 
            "\(index + 1). " + L10n.t("repetition.time")
    }
    
    private func getCompletionTime() -> Date? {
        // For future: Track completion times per repetition
        // For now, return current date if completed today
        return isCompleted ? Date() : nil
    }
}

