//
//  CustomizationView.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

struct CustomizationView: View {
    @StateObject private var fontManager = FontManager.shared
    @StateObject private var widgetThemeManager = WidgetThemeManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Font Selection
                Section {
                    ForEach(AppFont.allCases) { font in
                        Button(action: {
                            fontManager.setFont(font)
                            HapticManager.selection()
                        }) {
                            HStack(spacing: 16) {
                                Text(font.preview)
                                    .font(font.font(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(font.displayName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text("The quick brown fox")
                                        .font(font.font(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if fontManager.selectedFont == font {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(L10n.t("font.title"))
                }
                
                // Widget Theme Selection
                Section {
                    ForEach(WidgetTheme.allCases) { theme in
                        Button(action: {
                            widgetThemeManager.setTheme(theme)
                            HapticManager.selection()
                        }) {
                            HStack(spacing: 16) {
                                // Preview
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.backgroundColor)
                                    .overlay(
                                        Text("Widget")
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
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(L10n.t("widgetTheme.title"))
                } footer: {
                    Text("Widget themes will update next time the widget refreshes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("🎨 Customization")
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
}

