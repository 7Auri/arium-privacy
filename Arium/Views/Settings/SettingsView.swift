//
//  SettingsView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var showingStatistics = false
    
    var body: some View {
        NavigationStack {
            List {
                // Language Section
                Section {
                    Picker(L10n.t("settings.language"), selection: $appLanguage) {
                        Text("English").tag("en")
                        Text("Türkçe").tag("tr")
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                } header: {
                    Text(L10n.t("settings.language"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                
                // Premium Section
                Section {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.t("settings.premium"))
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Text(habitStore.isPremium ? L10n.t("settings.active") : L10n.t("settings.freePlan"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if !habitStore.isPremium {
                            Button {
                                // TODO: Handle premium purchase
                                habitStore.isPremium = true
                            } label: {
                                Text(L10n.t("premium.button"))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AriumTheme.accent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AriumTheme.accent.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(AriumTheme.success)
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                } header: {
                    Text(L10n.t("settings.premium"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                
                // Statistics Section
                Section {
                    Button {
                        showingStatistics = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.bar.fill")
                                .font(.body)
                                .foregroundStyle(AriumTheme.accent.opacity(0.8))
                                .frame(width: 28, alignment: .center)
                            
                            Text(L10n.t("statistics.viewStats"))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                } header: {
                    Text(L10n.t("statistics.title"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                
                // Debug Section
                Section {
                    // Premium Toggle
                    Toggle(isOn: $habitStore.isPremium) {
                        HStack {
                            Text(L10n.t("settings.debug.togglePremium"))
                                .foregroundStyle(.primary)
                            
                            Image(systemName: habitStore.isPremium ? "crown.fill" : "crown")
                                .font(.caption)
                                .foregroundColor(habitStore.isPremium ? .orange : .secondary)
                        }
                    }
                    .tint(.orange)
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    Button {
                        hasSeenOnboarding = false
                    } label: {
                        HStack {
                            Text(L10n.t("settings.resetOnboarding"))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.clockwise")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    Button {
                        habitStore.habits.removeAll()
                    } label: {
                        HStack {
                            Text(L10n.t("settings.clearAllHabits"))
                                .foregroundStyle(.red)
                            
                            Spacer()
                            
                            Image(systemName: "trash")
                                .font(.body)
                                .foregroundStyle(.red)
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                } header: {
                    Text(L10n.t("settings.debug"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                
                // About Section
                Section {
                    HStack {
                        Text(L10n.t("settings.version"))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    HStack {
                        Text(L10n.t("settings.totalHabits"))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("\(habitStore.habits.count)")
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    HStack {
                        Text(L10n.t("settings.totalCompletions"))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("\(habitStore.getTotalCompletions())")
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                } header: {
                    Text(L10n.t("settings.about"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.automatic)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L10n.t("settings.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                    .foregroundStyle(AriumTheme.accent)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView(habits: habitStore.habits, isPremium: habitStore.isPremium)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(HabitStore())
}
