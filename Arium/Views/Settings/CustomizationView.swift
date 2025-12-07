//
//  CustomizationView.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI
import WidgetKit

struct CustomizationView: View {
    @StateObject private var fontManager = FontManager.shared
    @StateObject private var appThemeManager = AppThemeManager.shared
    @StateObject private var widgetThemeManager = WidgetThemeManager.shared
    @StateObject private var confettiManager = ConfettiManager.shared
    @Environment(\.dismiss) var dismiss
    
    // Helpers for themes
    private var regularThemes: [AppAccentColor] {
        AppAccentColor.allCases.filter { !$0.isSpecialOccasion }
    }
    
    private var specialOccasionThemes: [AppAccentColor] {
        AppAccentColor.allCases.filter { $0.isSpecialOccasion }
    }
    
    var body: some View {
        NavigationStack {
            List {
                appThemeSection
                fontSection
                confettiSettingsSection
                widgetThemeSection
            }
            .navigationTitle("🎨 \(L10n.t("settings.customization"))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var appThemeSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                // Special Occasion Themes
                if !specialOccasionThemes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.orange)
                            Text(L10n.t("appTheme.specialOccasions"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(specialOccasionThemes) { color in
                                SpecialOccasionColorButton(
                                    color: color,
                                    isSelected: appThemeManager.accentColor == color,
                                    isActive: color.isCurrentlyActive
                                ) {
                                    appThemeManager.accentColor = color
                                    HapticManager.selection()
                                }
                            }
                        }
                    }
                }
                
                // Regular Themes
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(appThemeManager.accentColor.color)
                        Text(L10n.t("appTheme.regularThemes"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(regularThemes) { color in
                            ColorOptionButton(
                                color: color,
                                isSelected: appThemeManager.accentColor == color
                            ) {
                                appThemeManager.accentColor = color
                                HapticManager.selection()
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.t("settings.appTheme"))
        }
    }
    
    private var fontSection: some View {
        Section {
            ForEach(AppFont.allCases) { font in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        fontManager.setFont(font)
                    }
                    HapticManager.selection()
                    
                    // Reload widgets to apply font change
                    WidgetCenter.shared.reloadTimelines(ofKind: "AriumWidget")
                    WidgetCenter.shared.reloadTimelines(ofKind: "AriumWatchWidget")
                }) {
                    HStack(spacing: 16) {
                        Text(font.preview)
                            .font(font.font(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(font.displayName)
                                .font(font.font(size: 17))
                                .foregroundColor(.primary)
                            
                            Text(L10n.t("font.preview.text"))
                                .font(font.font(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if fontManager.selectedFont == font {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(appThemeManager.accentColor.color)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text(L10n.t("font.title"))
        }
    }
    
    private var confettiSettingsSection: some View {
        Section {
            // Confetti Intensity
            HStack {
                Label(L10n.t("confetti.settings.intensity"), systemImage: "party.popper.fill")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Picker("", selection: $confettiManager.intensity) {
                    ForEach(ConfettiManager.ConfettiIntensity.allCases, id: \.self) { intensity in
                        Text(intensity.displayName).tag(intensity)
                    }
                }
                .pickerStyle(.menu)
                .tint(appThemeManager.accentColor.color)
            }
            .padding(.vertical, 4)
            
            // Sound Effects
            HStack {
                Label(L10n.t("confetti.settings.sound"), systemImage: "speaker.wave.2.fill")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $confettiManager.soundEnabled)
                    .labelsHidden()
                    .tint(.blue)
            }
            .padding(.vertical, 4)
            
            // Use Theme Colors
            HStack {
                Label(L10n.t("confetti.settings.customColors"), systemImage: "paintpalette.fill")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $confettiManager.useCustomColors)
                    .labelsHidden()
                    .tint(appThemeManager.accentColor.color)
            }
            .padding(.vertical, 4)
        } header: {
            Text(L10n.t("confetti.settings.title"))
        }
    }
    
    private var widgetThemeSection: some View {
        Section {
            ForEach(WidgetTheme.allCases) { theme in
                Button(action: {
                    widgetThemeManager.setTheme(theme)
                    HapticManager.selection()
                    // Reload widgets to apply theme change
                    WidgetCenter.shared.reloadTimelines(ofKind: "AriumWidget")
                    WidgetCenter.shared.reloadTimelines(ofKind: "AriumWatchWidget")
                }) {
                    HStack(spacing: 16) {
                        // Preview
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.backgroundColor)
                            .overlay(
                                Text(L10n.t("widget.preview"))
                                    .font(.caption.bold())
                                    .foregroundColor(theme.textColor)
                            )
                            .frame(width: 60, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text(theme.displayName)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if widgetThemeManager.selectedTheme == theme {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(appThemeManager.accentColor.color)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text(L10n.t("widgetTheme.title"))
        } footer: {
            Text(L10n.t("widgetTheme.refreshMessage"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Components
    
    struct SpecialOccasionColorButton: View {
        let color: AppAccentColor
        let isSelected: Bool
        let isActive: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    ZStack {
                        // Color circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.color, color.lightColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                            )
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? color.color : Color.clear, lineWidth: 1)
                                    .padding(2)
                            )
                            .shadow(
                                color: isSelected ? color.color.opacity(0.4) : Color.black.opacity(0.1),
                                radius: isSelected ? 12 : 4,
                                x: 0,
                                y: isSelected ? 6 : 2
                            )
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                        
                        // Icon overlay
                        if !color.icon.isEmpty {
                            Text(color.icon)
                                .font(.system(size: 20))
                                .opacity(0.9)
                        }
                        
                        // Active badge
                        if isActive {
                            Circle()
                                .fill(.green)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                                .offset(x: 18, y: -18)
                                .shadow(color: .green.opacity(0.5), radius: 4, x: 0, y: 2)
                        }
                    }
                    
                    VStack(spacing: 2) {
                        Text(color.name)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(isSelected ? .primary : .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        if isActive {
                            Text(L10n.t("appTheme.active"))
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct ColorOptionButton: View {
        let color: AppAccentColor
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(color.color)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isSelected ? AriumTheme.accent : Color(.separator).opacity(0.3),
                                        lineWidth: isSelected ? 3 : 1
                                    )
                            )
                            .shadow(
                                color: isSelected ? color.color.opacity(0.4) : Color.black.opacity(0.1),
                                radius: isSelected ? 8 : 4,
                                x: 0,
                                y: isSelected ? 4 : 2
                            )
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Text(color.name)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? color.color.opacity(0.1) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? color.color.opacity(0.3) : Color(.separator).opacity(0.2),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
