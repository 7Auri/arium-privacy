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
    @Binding var selectedTemplateIndex: Int?
    let quickStartTemplates: [(titleKey: String, icon: String, category: HabitCategory)]
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                
                // Icon/Illustration
                iconView
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                
                Spacer(minLength: 40)
                
                // Title
                Text(page.title)
                    .applyAppFont(size: 32, weight: .bold)
                    .foregroundColor(AriumTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                
                Spacer(minLength: 16)
                
                // Subtitle
                Text(page.subtitle)
                    .applyAppFont(size: 17, weight: .regular)
                    .foregroundColor(AriumTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                
                Spacer(minLength: 32)
                
                // Optional sections
                if page.showThemeSelector {
                    themeSelectorView
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                
                if page.showMeasurementHighlights {
                    measurementHighlightsView
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .padding(.horizontal, 24)
                }
                
                if page.showTemplatePicker {
                    templatePickerView
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
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
        
        // İlk sayfada (id: 0) Watch app icon'unu göster
        if page.id == 0 {
            return AnyView(
                ZStack {
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
                        .frame(width: 220, height: 220)
                        .blur(radius: 20)
                    
                    Image("AppIconWatch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .shadow(color: accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTheme)
            )
        } else {
            return AnyView(
                ZStack {
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
                        .frame(width: 220, height: 220)
                        .blur(radius: 20)
                    
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
                        .frame(width: 170, height: 170)
                        .shadow(color: accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: page.iconName)
                        .applyAppFont(size: 78, weight: .ultraLight)
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
    
    // MARK: - Measurement Highlights
    
    private var measurementHighlightsView: some View {
        VStack(spacing: 12) {
            measurementRow(
                icon: "scalemass.fill",
                titleKey: "measurement.weight",
                accent: .pink
            )
            measurementRow(
                icon: "ruler.fill",
                titleKey: "measurement.height",
                accent: .purple
            )
            measurementRow(
                icon: "heart.text.square.fill",
                titleKey: "onboarding.measurements.bmi",
                accent: .red
            )
            measurementRow(
                icon: "chart.line.uptrend.xyaxis",
                titleKey: "onboarding.measurements.trends",
                accent: .blue
            )
        }
        .frame(maxWidth: 400)
    }
    
    private func measurementRow(icon: String, titleKey: String, accent: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(accent)
            }
            
            Text(L10n.t(titleKey))
                .applyAppFont(size: 15, weight: .medium)
                .foregroundColor(AriumTheme.textPrimary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AriumTheme.textTertiary.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Template Picker
    
    private var templatePickerView: some View {
        VStack(spacing: 14) {
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(quickStartTemplates.indices, id: \.self) { index in
                    let template = quickStartTemplates[index]
                    templateCard(
                        index: index,
                        titleKey: template.titleKey,
                        icon: template.icon,
                        category: template.category
                    )
                }
            }
            
            Button {
                HapticManager.selection()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTemplateIndex = nil
                }
            } label: {
                Text(L10n.t("onboarding.quickStart.skip"))
                    .applyAppFont(size: 14, weight: .medium)
                    .foregroundColor(
                        selectedTemplateIndex == nil
                            ? AriumTheme.accent
                            : AriumTheme.textTertiary
                    )
                    .padding(.top, 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func templateCard(index: Int, titleKey: String, icon: String, category: HabitCategory) -> some View {
        let isSelected = selectedTemplateIndex == index
        
        return Button {
            HapticManager.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTemplateIndex = isSelected ? nil : index
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(isSelected ? 0.25 : 0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(category.color)
                }
                
                Text(L10n.t(titleKey))
                    .applyAppFont(size: 14, weight: .semibold)
                    .foregroundColor(AriumTheme.textPrimary)
                    .lineLimit(1)
                
                Text(category.localizedName)
                    .applyAppFont(size: 11, weight: .regular)
                    .foregroundColor(AriumTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? category.color.opacity(0.08) : Color(.systemBackground).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? category.color : AriumTheme.textTertiary.opacity(0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? category.color.opacity(0.15) : Color.clear,
                radius: 6, x: 0, y: 3
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Theme Selector
    
    private var themeSelectorView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(L10n.t("onboarding.selectTheme"))
                    .applyAppFont(size: 22, weight: .bold)
                    .foregroundColor(AriumTheme.textPrimary)
                
                Text(L10n.t("onboarding.selectTheme.subtitle"))
                    .applyAppFont(size: 15, weight: .regular)
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
                    
                    if let icon = theme.icon {
                        Text(icon)
                            .applyAppFont(size: 32)
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .applyAppFont(size: 26, weight: .bold)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                Text(theme.localizedName)
                    .applyAppFont(size: 13, weight: isSelected ? .semibold : .medium)
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
        selectedTheme: .constant(.purple),
        selectedTemplateIndex: .constant(nil),
        quickStartTemplates: []
    )
}
