//
//  CompletionButton.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct CompletionButton: View {
    let habit: Habit
    let onToggle: () -> Void
    
    @State private var isAnimating = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var circleScale: CGFloat = 1.0
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0
    
    var body: some View {
        Button(action: {
            // Trigger animations
            if !habit.isCompletedToday {
                // Completing animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    circleScale = 1.2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        checkmarkScale = 1.0
                        circleScale = 1.0
                    }
                }
                
                // Ripple effect
                withAnimation(.easeOut(duration: 0.6)) {
                    rippleScale = 2.5
                    rippleOpacity = 0.3
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    rippleScale = 1.0
                    rippleOpacity = 0
                }
            } else {
                // Uncompleting animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    checkmarkScale = 0
                    circleScale = 0.8
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        circleScale = 1.0
                    }
                }
            }
            
            onToggle()
        }) {
            ZStack {
                // Ripple effect (only when completing)
                if !habit.isCompletedToday {
                    Circle()
                        .stroke(habit.theme.accent.opacity(0.4), lineWidth: 2)
                        .frame(width: 44, height: 44)
                        .scaleEffect(rippleScale)
                        .opacity(rippleOpacity)
                }
                
                // Main circle
                Circle()
                    .fill(
                        habit.isCompletedToday 
                            ? habit.theme.accent 
                            : Color.clear
                    )
                    .frame(width: 44, height: 44)
                    .scaleEffect(circleScale)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                habit.isCompletedToday 
                                    ? Color.clear 
                                    : habit.theme.accent.opacity(0.4),
                                lineWidth: 2.5
                            )
                    )
                
                // Checkmark
                if habit.isCompletedToday {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(checkmarkScale)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: habit.isCompletedToday) { oldValue, newValue in
            if newValue && !oldValue {
                // Just completed - trigger animation
                checkmarkScale = 0
                circleScale = 1.0
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    circleScale = 1.2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        checkmarkScale = 1.0
                        circleScale = 1.0
                    }
                }
                
                // Ripple effect
                withAnimation(.easeOut(duration: 0.6)) {
                    rippleScale = 2.5
                    rippleOpacity = 0.3
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    rippleScale = 1.0
                    rippleOpacity = 0
                }
            } else if !newValue && oldValue {
                // Just uncompleted
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    checkmarkScale = 0
                    circleScale = 0.8
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        circleScale = 1.0
                    }
                }
            }
        }
        .onAppear {
            // Set initial state
            if habit.isCompletedToday {
                checkmarkScale = 1.0
            }
        }
        .accessibilityLabel("\(habit.title), \(habit.isCompletedToday ? L10n.t("habit.completed") : L10n.t("habit.notCompleted"))")
        .accessibilityHint(habit.isCompletedToday ? L10n.t("habit.tapToUndo") : L10n.t("habit.tapToComplete"))
    }
}

#Preview {
    HStack {
        CompletionButton(
            habit: Habit(title: "Test Habit", themeId: "purple", category: .personal),
            onToggle: {}
        )
    }
    .padding()
}
