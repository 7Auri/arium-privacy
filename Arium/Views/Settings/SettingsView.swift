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
    @State private var isSystemLanguage = false
    @AppStorage("isDailyMotivationEnabled") private var isDailyMotivationEnabled = false
    @AppStorage("isStreakWarningEnabled") private var isStreakWarningEnabled = true
    @State private var showingStatistics = false
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportURL: URL?
    @StateObject private var exportImport = HabitExportImport.shared
    
    var body: some View {
        NavigationStack {
            List {
                // Language Section
                Section {
                    let systemLang = L10nManager.detectSystemLanguage()
                    let hasSystemLanguage = systemLang != nil
                    
                    Picker(L10n.t("settings.language"), selection: Binding(
                        get: { isSystemLanguage && hasSystemLanguage ? "system" : appLanguage },
                        set: { newValue in
                            if newValue == "system" && hasSystemLanguage {
                                isSystemLanguage = true
                                if let systemLang = systemLang {
                                    L10n.setLanguage(systemLang)
                                }
                            } else {
                                isSystemLanguage = false
                                appLanguage = newValue
                                L10n.setLanguage(newValue)
                            }
                        }
                    )) {
                        if hasSystemLanguage {
                            Text(L10n.t("settings.language.system")).tag("system")
                        }
                        Text("English").tag("en")
                        Text("Türkçe").tag("tr")
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    .onAppear {
                        // İlk açılışta sistem dilini kontrol et
                        if UserDefaults.standard.string(forKey: "appLanguage") == nil {
                            if hasSystemLanguage {
                                isSystemLanguage = true
                                if let systemLang = systemLang {
                                    L10n.setLanguage(systemLang)
                                }
                            } else {
                                // Sistem dili desteklenmiyorsa varsayılan olarak İngilizce
                                L10n.setLanguage("en")
                            }
                        } else {
                            // Mevcut dil sistem diliyle eşleşiyor mu kontrol et
                            if hasSystemLanguage {
                                let currentLang = L10nManager.shared.currentLanguage
                                isSystemLanguage = (currentLang == systemLang)
                            } else {
                                isSystemLanguage = false
                            }
                        }
                    }
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
                
                // Notifications Section
                Section {
                    Toggle(isOn: $notificationManager.isAuthorized) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.fill")
                                .font(.body)
                                .foregroundStyle(.orange.opacity(0.8))
                                .frame(width: 28, alignment: .center)
                            
                            Text(L10n.t("settings.notifications.enable"))
                                .foregroundStyle(.primary)
                        }
                    }
                    .tint(.orange)
                    .onChange(of: notificationManager.isAuthorized) { _, newValue in
                        if newValue {
                            Task {
                                _ = await notificationManager.requestAuthorization()
                            }
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    if notificationManager.isAuthorized {
                        Toggle(isOn: $isDailyMotivationEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.body)
                                    .foregroundStyle(.yellow.opacity(0.8))
                                    .frame(width: 28, alignment: .center)
                                
                                Text(L10n.t("settings.notifications.daily"))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .tint(.yellow)
                        .onChange(of: isDailyMotivationEnabled) { _, newValue in
                            Task {
                                if newValue {
                                    await notificationManager.scheduleDailyMotivation()
                                } else {
                                    notificationManager.cancelDailyMotivation()
                                }
                            }
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        
                        Toggle(isOn: $isStreakWarningEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.body)
                                    .foregroundStyle(.red.opacity(0.8))
                                    .frame(width: 28, alignment: .center)
                                
                                Text(L10n.t("settings.notifications.streaks"))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .tint(.red)
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                    }
                } header: {
                    Text(L10n.t("settings.notifications"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                
                // iCloud Sync Section
                Section {
                    Toggle(isOn: $habitStore.iCloudSyncEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "icloud.fill")
                                .font(.body)
                                .foregroundStyle(.blue.opacity(0.8))
                                .frame(width: 28, alignment: .center)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(L10n.t("settings.icloud.sync"))
                                    .foregroundStyle(.primary)
                                
                                Text(L10n.t("settings.icloud.sync.description"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tint(.blue)
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    if habitStore.iCloudSyncEnabled {
                        Button {
                            Task {
                                await habitStore.syncWithiCloud()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.blue.opacity(0.8))
                                    .frame(width: 28, alignment: .center)
                                
                                Text(L10n.t("settings.icloud.syncNow"))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                    }
                } header: {
                    Text(L10n.t("settings.icloud.title"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                
                // Export/Import Section
                Section {
                    Button {
                        do {
                            let url = try exportImport.exportToFile(habitStore.habits)
                            exportURL = url
                            showingExportSheet = true
                        } catch {
                            print("❌ Export failed: \(error)")
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.body)
                                .foregroundStyle(.blue.opacity(0.8))
                                .frame(width: 28, alignment: .center)
                            
                            Text(L10n.t("settings.export"))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    Button {
                        showingImportPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(.body)
                                .foregroundStyle(.green.opacity(0.8))
                                .frame(width: 28, alignment: .center)
                            
                            Text(L10n.t("settings.import"))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                } header: {
                    Text(L10n.t("settings.data"))
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
            .sheet(isPresented: $showingExportSheet, content: {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            })
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    do {
                        let data = try Data(contentsOf: url)
                        let importedHabits = try exportImport.importHabits(from: data)
                        habitStore.habits = importedHabits
                        habitStore.saveHabits()
                    } catch {
                        print("❌ Import failed: \(error)")
                    }
                case .failure(let error):
                    print("❌ File picker failed: \(error)")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(HabitStore())
}
