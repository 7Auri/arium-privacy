//
//  OnboardingPageView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPageModel
    @Binding var selectedTheme: HabitTheme
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon/Illustration
            iconView
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
                .frame(height: 60)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AriumTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
                .frame(height: 16)
            
            // Subtitle
            Text(page.subtitle)
                .font(.system(size: 18))
                .foregroundColor(AriumTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
                .frame(height: 40)
            
            // Theme Selector (only on last page)
            if page.showThemeSelector {
                themeSelectorView
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isAnimating = true
            }
        }
        .onChange(of: page.id) { _, _ in
            isAnimating = false
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isAnimating = true
            }
        }
    }
    
    private var iconView: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            page.accentColor.opacity(0.2),
                            page.accentColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
            
            // Icon
            Image(systemName: page.iconName)
                .font(.system(size: 80, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [page.accentColor, page.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private var themeSelectorView: some View {
        VStack(spacing: 16) {
            Text(L10n.t("onboarding.selectTheme"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AriumTheme.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(HabitTheme.allThemes) { theme in
                        OnboardingThemeButton(
                            theme: theme,
                            isSelected: selectedTheme.id == theme.id
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTheme = theme
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

struct OnboardingThemeButton: View {
    let theme: HabitTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.primary, theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(theme.accent.opacity(0.5), lineWidth: isSelected ? 3 : 0)
                        )
                        .shadow(
                            color: isSelected ? theme.accent.opacity(0.5) : Color.clear,
                            radius: isSelected ? 12 : 0,
                            x: 0,
                            y: isSelected ? 6 : 0
                        )
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
            }
            .padding(.vertical, 2)
            .frame(width: 75)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingData.pages[0],
        selectedTheme: .constant(.purple)
    )
}

