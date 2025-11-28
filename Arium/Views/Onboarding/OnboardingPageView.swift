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
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AriumTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 32)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 30)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
            
            Spacer()
                .frame(height: 16)
            
            // Subtitle
            Text(page.subtitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(AriumTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
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
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                isAnimating = true
            }
        }
        .onChange(of: page.id) { _, _ in
            isAnimating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                    isAnimating = true
                }
            }
        }
    }
    
    private var iconView: some View {
        let accentColor = page.showThemeSelector ? selectedTheme.accent : page.accentColor
        
        // İlk sayfada (id: 0) Watch app icon'unu göster (yuvarlak, daha doğal)
        if page.id == 0 {
            return AnyView(
                ZStack {
                    // Outer glow circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    accentColor.opacity(0.15),
                                    accentColor.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                    
                    // App Logo (Watch Icon - Yuvarlak, daha doğal)
                    Image("AppIconWatch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .shadow(color: accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTheme)
            )
        } else {
            return AnyView(
                ZStack {
                    // Outer glow circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    accentColor.opacity(0.15),
                                    accentColor.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                    
                    // Background circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    accentColor.opacity(0.25),
                                    accentColor.opacity(0.1),
                                    accentColor.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    // Icon
                    Image(systemName: page.iconName)
                        .font(.system(size: 90, weight: .ultraLight))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    accentColor,
                                    accentColor.opacity(0.8),
                                    accentColor.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTheme)
            )
        }
    }
    
    private var themeSelectorView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(L10n.t("onboarding.selectTheme"))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AriumTheme.textPrimary)
                
                Text(L10n.t("onboarding.selectTheme.subtitle"))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AriumTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(HabitTheme.allThemes) { theme in
                        OnboardingThemeButton(
                            theme: theme,
                            isSelected: selectedTheme.id == theme.id
                        ) {
                            HapticManager.selection()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTheme = theme
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
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
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.accent.opacity(isSelected ? 0.25 : 0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 28,
                                endRadius: 48
                            )
                        )
                        .frame(width: 96, height: 96)
                        .blur(radius: 6)
                        .opacity(isSelected ? 1 : 0)
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.primary, theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 76, height: 76)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.white : theme.accent.opacity(0.25),
                                    lineWidth: isSelected ? 3.5 : 2
                                )
                        )
                        .shadow(
                            color: isSelected ? theme.accent.opacity(0.5) : Color.black.opacity(0.08),
                            radius: isSelected ? 14 : 6,
                            x: 0,
                            y: isSelected ? 6 : 3
                        )
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                // Theme name
                Text(theme.localizedName)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AriumTheme.textPrimary : AriumTheme.textSecondary)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .frame(width: 100)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? theme.accent.opacity(0.08) : Color(.systemBackground).opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? theme.accent.opacity(0.25) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? theme.accent.opacity(0.15) : Color.black.opacity(0.04),
                radius: isSelected ? 10 : 3,
                x: 0,
                y: isSelected ? 5 : 2
            )
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

