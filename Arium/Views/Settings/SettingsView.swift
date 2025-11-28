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
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var cloudSyncManager = CloudSyncManager.shared
    @StateObject private var versionChecker = AppVersionChecker.shared
    @State private var showingPremiumError = false
    @State private var premiumError: AppError?
    @State private var showingUpdateAlert = false
    @State private var exportError: AppError?
    @State private var showingiCloudSyncSuccess = false
    @State private var showingiCloudSyncError = false
    @State private var iCloudSyncError: AppError?
    @State private var iCloudLoadMessage = ""
    @State private var showingLanguagePicker = false
    @StateObject private var appThemeManager = AppThemeManager.shared
    @State private var showingThemePicker = false
    @State private var showingExportHabitPicker = false
    @State private var selectedHabitsForExport: Set<UUID> = []
    @State private var showingExportSuccess = false
    @State private var showingImportSuccess = false
    @State private var exportedHabitCount = 0
    @State private var importedHabitCount = 0
    @State private var showingImportSelection = false
    @State private var importItems: [ImportHabitItem] = []
    @State private var showingDuplicateAlert = false
    @State private var duplicateHabit: Habit?
    @State private var duplicateItemId: UUID?
    
    var body: some View {
        NavigationStack {
            List {
                // Language Section
                Section {
                    let systemLang = L10nManager.detectSystemLanguage()
                    let hasSystemLanguage = systemLang != nil
                    let currentLanguage = isSystemLanguage && hasSystemLanguage ? "system" : appLanguage
                    
                    Button {
                        showingLanguagePicker = true
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AriumTheme.accent.opacity(0.2), AriumTheme.accent.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "globe")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(AriumTheme.accent)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("settings.language"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text(
                                    currentLanguage == "system" 
                                    ? L10n.t("settings.language.system")
                                    : (currentLanguage == "en" ? "English" : "Türkçe")
                                )
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingLanguagePicker) {
                        LanguagePickerSheet(
                            currentLanguage: Binding(
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
                                    showingLanguagePicker = false
                                }
                            ),
                            hasSystemLanguage: hasSystemLanguage
                        )
                    }
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
                
                // App Theme Section
                Section {
                    Button {
                        showingThemePicker = true
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [appThemeManager.accentColor.color.opacity(0.2), appThemeManager.accentColor.color.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "paintpalette.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(appThemeManager.accentColor.color)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("settings.appTheme"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text(appThemeManager.accentColor.name)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(appThemeManager.accentColor.color)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingThemePicker) {
                        AppThemePickerSheet(
                            selectedColor: $appThemeManager.accentColor
                        )
                    }
                } header: {
                    Text(L10n.t("settings.appearance"))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                
                // Achievements Section (NEW!)
                Section {
                    NavigationLink(destination: AchievementsView()) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.2), Color.purple.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Text("🏆")
                                    .font(.system(size: 22))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("achievements.title"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                if AchievementManager.shared.newAchievementsCount > 0 {
                                    Text("\(AchievementManager.shared.newAchievementsCount) " + L10n.t("achievement.new"))
                                        .font(.caption.bold())
                                        .foregroundColor(.orange)
                                } else {
                                    Text(L10n.t("achievements.viewAll"))
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                
                // Customization Section (NEW!)
                Section {
                    NavigationLink(destination: CustomizationView()) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.pink.opacity(0.2), Color.purple.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Text("🎨")
                                    .font(.system(size: 22))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Özelleştirme")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text("Font, widget, temalar")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                
                // Data Export Section (NEW!)
                Section {
                    NavigationLink(destination: DataExportView()) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("export.title"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text(L10n.t("export.subtitle"))
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                
                // Premium Section
                Section {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.t("settings.premium"))
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Text(premiumManager.isPremium ? L10n.t("settings.active") : L10n.t("settings.freePlan"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if !premiumManager.isPremium {
                            Button {
                                Task {
                                    do {
                                        try await premiumManager.purchasePremium()
                                    } catch {
                                        showingPremiumError = true
                                        premiumError = error as? AppError ?? PremiumError.unknown
                                    }
                                }
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
                    // Note: No automatic sync when toggle is enabled
                    // Users must manually use "Load from iCloud" or "Sync Now" buttons
                    
                    if habitStore.iCloudSyncEnabled {
                        Button {
                            Task {
                                do {
                                    try await habitStore.syncWithiCloud()
                                    showingiCloudSyncSuccess = true
                                } catch {
                                    print("❌ iCloud sync error: \(error)")
                                    showingiCloudSyncError = true
                                    iCloudSyncError = NetworkError.unknown
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if cloudSyncManager.isSyncing {
                                    ProgressView()
                                        .frame(width: 28, height: 28)
                                } else {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.body)
                                        .foregroundStyle(.blue.opacity(0.8))
                                        .frame(width: 28, alignment: .center)
                                }
                                
                                Text(L10n.t("settings.icloud.syncNow"))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                        }
                        .disabled(cloudSyncManager.isSyncing)
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        
                        Button {
                            Task {
                                do {
                                    let beforeCount = habitStore.habits.count
                                    try await habitStore.loadFromiCloud()
                                    let afterCount = habitStore.habits.count
                                    let addedCount = afterCount - beforeCount
                                    
                                    if addedCount > 0 {
                                        iCloudLoadMessage = "\(addedCount) alışkanlık iCloud'dan yüklendi"
                                    } else if afterCount > 0 {
                                        iCloudLoadMessage = "Tüm alışkanlıklar zaten mevcut"
                                    } else {
                                        iCloudLoadMessage = "iCloud'da alışkanlık bulunamadı"
                                    }
                                    showingiCloudSyncSuccess = true
                                } catch {
                                    print("❌ iCloud load error: \(error)")
                                    showingiCloudSyncError = true
                                    iCloudSyncError = NetworkError.unknown
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.blue.opacity(0.8))
                                    .frame(width: 28, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(L10n.t("settings.icloud.loadFromCloud"))
                                        .foregroundStyle(.primary)
                                    
                                    Text(L10n.t("settings.icloud.loadFromCloud.description"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .disabled(cloudSyncManager.isSyncing)
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        
                        if let lastSync = cloudSyncManager.lastSyncDate {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.green.opacity(0.8))
                                    .frame(width: 28, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(L10n.t("settings.icloud.lastSync"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(lastSync.localizedRelativeTimeString())
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                Spacer()
                            }
                            .listRowBackground(Color(.secondarySystemGroupedBackground))
                        }
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
                        guard !habitStore.habits.isEmpty else {
                            exportError = ExportError.exportFailed
                            return
                        }
                        // Initialize with all habits selected
                        selectedHabitsForExport = Set(habitStore.habits.map { $0.id })
                        showingExportHabitPicker = true
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
                #if DEBUG
                Section {
                    // Premium Toggle
                    Toggle(isOn: Binding(
                        get: { premiumManager.isPremium },
                        set: { newValue in
                            premiumManager.setPremiumStatus(newValue)
                        }
                    )) {
                        HStack {
                            Text(L10n.t("settings.debug.togglePremium"))
                                .foregroundStyle(.primary)
                            
                            Image(systemName: premiumManager.isPremium ? "crown.fill" : "crown")
                                .font(.caption)
                                .foregroundColor(premiumManager.isPremium ? .orange : .secondary)
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
                #endif
                
                // About Section
                Section {
                    // App Logo (iPhone App Icon)
                    VStack(spacing: 16) {
                        Image("AppIconMain")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(22)
                            .shadow(color: AriumTheme.accent.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("Arium")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(AriumTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    HStack {
                        Text(L10n.t("settings.version"))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(Bundle.main.displayVersion)
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
                    
                    Link(destination: URL(string: "https://zorbeyteam.com/arium/privacy") ?? URL(string: "https://zorbeyteam.com")!) {
                        HStack {
                            Text(L10n.t("settings.privacyPolicy"))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    
                    Link(destination: URL(string: "https://zorbeyteam.com/arium/terms") ?? URL(string: "https://zorbeyteam.com")!) {
                        HStack {
                            Text(L10n.t("settings.termsOfService"))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
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
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(.top, 8, for: .scrollContent)
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
                StatisticsView(habits: habitStore.habits, isPremium: premiumManager.isPremium)
            }
            .errorAlert(error: $premiumError)
            .errorAlert(error: $exportError)
            .errorAlert(error: $iCloudSyncError)
            .alert(L10n.t("settings.icloud.syncSuccess"), isPresented: $showingiCloudSyncSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                if !iCloudLoadMessage.isEmpty {
                    Text(iCloudLoadMessage)
                }
            }
            .loadingOverlay(isLoading: premiumManager.isLoading, message: premiumManager.isLoading ? L10n.t("premium.purchasing") : nil)
            .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(L10n.t("premium.purchase.success.message"))
            }
            .alert(L10n.t("update.available.title"), isPresented: $showingUpdateAlert) {
                Button(L10n.t("update.available.update")) {
                    versionChecker.openAppStore()
                }
                Button(L10n.t("button.later"), role: .cancel) { }
            } message: {
                if let latestVersion = versionChecker.latestVersion {
                    Text(String(format: L10n.t("update.available.message"), latestVersion))
                } else {
                    Text(L10n.t("update.available.message.generic"))
                }
            }
            .task {
                // Check for updates when settings view appears
                await versionChecker.checkForUpdates()
                if versionChecker.hasUpdateAvailable {
                    showingUpdateAlert = true
                }
            }
            .sheet(isPresented: $showingExportHabitPicker) {
                ExportHabitPickerSheet(
                    habits: habitStore.habits,
                    selectedHabits: $selectedHabitsForExport
                ) { selectedHabits in
                    do {
                        guard !selectedHabits.isEmpty else {
                            exportError = ExportError.exportFailed
                            return
                        }
                        let url = try exportImport.exportToFile(selectedHabits)
                        exportedHabitCount = selectedHabits.count
                        exportURL = url
                        showingExportSheet = true
                        showingExportSuccess = true
                    } catch {
                        print("❌ Export failed: \(error.localizedDescription)")
                        exportError = ExportError.exportFailed
                    }
                }
            }
            .alert(L10n.t("export.success.title"), isPresented: $showingExportSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(String(format: L10n.t("export.success.message"), exportedHabitCount))
            }
            .alert(L10n.t("import.success.title"), isPresented: $showingImportSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(String(format: L10n.t("import.success.message"), importedHabitCount))
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                        .onAppear {
                            print("✅ ShareSheet opened with URL: \(url.path)")
                        }
                }
            }
            .sheet(isPresented: $showingImportSelection) {
                ImportHabitSelectionSheet(
                    items: $importItems,
                    isPremium: premiumManager.isPremium,
                    maxFreeHabits: habitStore.maxFreeHabits
                ) { selectedItems in
                    // Merge habits
                    let mergedHabits = exportImport.mergeHabits(
                        items: selectedItems,
                        isPremium: premiumManager.isPremium,
                        maxFreeHabits: habitStore.maxFreeHabits
                    )
                    
                    // Calculate how many new habits were added
                    let existingCount = habitStore.habits.count
                    importedHabitCount = mergedHabits.count - existingCount
                    
                    // Update habit store
                    habitStore.habits = mergedHabits
                    habitStore.saveHabits()
                    
                    // Show success message
                    showingImportSuccess = true
                    showingImportSelection = false
                    
                    print("✅ Import completed successfully: \(importedHabitCount) new habits added")
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    
                    // iOS requires security-scoped resource access for fileImporter files
                    guard url.startAccessingSecurityScopedResource() else {
                        print("❌ Failed to access security-scoped resource")
                        exportError = ExportError.importFailed
                        return
                    }
                    
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    
                    do {
                        // Read file data
                        let data = try Data(contentsOf: url)
                        print("✅ File read successfully, size: \(data.count) bytes")
                        
                        // Validate JSON
                        guard let jsonString = String(data: data, encoding: .utf8) else {
                            print("❌ Failed to convert data to string")
                            exportError = ExportError.invalidFormat
                            return
                        }
                        print("✅ JSON string length: \(jsonString.count) characters")
                        
                        // Import habits
                        let importedHabits = try exportImport.importHabits(from: data)
                        print("✅ Successfully imported \(importedHabits.count) habits")
                        
                        // Prepare import items for selection
                        let items = exportImport.prepareImportItems(
                            importedHabits: importedHabits,
                            existingHabits: habitStore.habits,
                            isPremium: premiumManager.isPremium
                        )
                        importItems = items
                        showingImportSelection = true
                        
                        print("✅ Import selection screen prepared")
                    } catch let error as DecodingError {
                        print("❌ JSON decode failed: \(error)")
                        print("   - \(error.localizedDescription)")
                        exportError = ExportError.invalidFormat
                    } catch {
                        print("❌ Import failed: \(error.localizedDescription)")
                        exportError = ExportError.importFailed
                    }
                case .failure(let error):
                    print("❌ File picker failed: \(error.localizedDescription)")
                    exportError = ExportError.importFailed
                }
            }
        }
    }
}

// MARK: - Language Picker Sheet

struct LanguagePickerSheet: View {
    @Binding var currentLanguage: String
    let hasSystemLanguage: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if hasSystemLanguage {
                    LanguageOptionRow(
                        title: L10n.t("settings.language.system"),
                        isSelected: currentLanguage == "system",
                        icon: "gear"
                    ) {
                        currentLanguage = "system"
                    }
                }
                
                LanguageOptionRow(
                    title: "English",
                    isSelected: currentLanguage == "en",
                    icon: "globe"
                ) {
                    currentLanguage = "en"
                }
                
                LanguageOptionRow(
                    title: "Türkçe",
                    isSelected: currentLanguage == "tr",
                    icon: "globe"
                ) {
                    currentLanguage = "tr"
                }
                
                LanguageOptionRow(
                    title: "Deutsch",
                    isSelected: currentLanguage == "de",
                    icon: "globe"
                ) {
                    currentLanguage = "de"
                }
                
                LanguageOptionRow(
                    title: "Français",
                    isSelected: currentLanguage == "fr",
                    icon: "globe"
                ) {
                    currentLanguage = "fr"
                }
                
                LanguageOptionRow(
                    title: "Español",
                    isSelected: currentLanguage == "es",
                    icon: "globe"
                ) {
                    currentLanguage = "es"
                }
                
                LanguageOptionRow(
                    title: "Italiano",
                    isSelected: currentLanguage == "it",
                    icon: "globe"
                ) {
                    currentLanguage = "it"
                }
            }
            .navigationTitle(L10n.t("settings.language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LanguageOptionRow: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AriumTheme.accent)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AriumTheme.accent)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - App Theme Picker Sheet

struct AppThemePickerSheet: View {
    @Binding var selectedColor: AppAccentColor
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(AppAccentColor.allCases) { color in
                        ColorOptionButton(
                            color: color,
                            isSelected: selectedColor == color
                        ) {
                            selectedColor = color
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.t("settings.appTheme"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Export Habit Picker Sheet

struct ExportHabitPickerSheet: View {
    let habits: [Habit]
    @Binding var selectedHabits: Set<UUID>
    let onExport: ([Habit]) -> Void
    @Environment(\.dismiss) var dismiss
    
    var selectedHabitsArray: [Habit] {
        habits.filter { selectedHabits.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        // Toggle all
                        if selectedHabits.count == habits.count {
                            selectedHabits.removeAll()
                        } else {
                            selectedHabits = Set(habits.map { $0.id })
                        }
                    } label: {
                        HStack {
                            Text(selectedHabits.count == habits.count 
                                 ? L10n.t("export.deselectAll") 
                                 : L10n.t("export.selectAll"))
                            Spacer()
                            Text("\(selectedHabits.count)/\(habits.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(L10n.t("export.selectHabits"))
                }
                
                Section {
                    ForEach(habits) { habit in
                        HabitSelectionRow(
                            habit: habit,
                            isSelected: selectedHabits.contains(habit.id)
                        ) {
                            if selectedHabits.contains(habit.id) {
                                selectedHabits.remove(habit.id)
                            } else {
                                selectedHabits.insert(habit.id)
                            }
                        }
                    }
                } header: {
                    Text(L10n.t("export.habits"))
                } footer: {
                    Text(String(format: L10n.t("export.selectedCount"), selectedHabits.count))
                }
            }
            .navigationTitle(L10n.t("export.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t("export.button")) {
                        onExport(selectedHabitsArray)
                        dismiss()
                    }
                    .disabled(selectedHabits.isEmpty)
                }
            }
        }
    }
}

struct HabitSelectionRow: View {
    let habit: Habit
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AriumTheme.accent : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    if !habit.notes.isEmpty {
                        Text(habit.notes)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorOptionButton: View {
    let color: AppAccentColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.color)
                        .frame(width: 60, height: 60)
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
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                Text(color.name)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
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

// MARK: - Import Habit Selection Sheet

struct ImportHabitSelectionSheet: View {
    @Binding var items: [ImportHabitItem]
    let isPremium: Bool
    let maxFreeHabits: Int
    let onImport: ([ImportHabitItem]) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showingDuplicateAlert = false
    @State private var duplicateItem: ImportHabitItem?
    
    var existingHabits: [ImportHabitItem] {
        items.filter { $0.isExisting }
    }
    
    var newHabits: [ImportHabitItem] {
        items.filter { !$0.isExisting }
    }
    
    var selectedNewHabitsCount: Int {
        items.filter { !$0.isExisting && $0.isSelected }.count
    }
    
    var existingHabitsCount: Int {
        existingHabits.count
    }
    
    var totalSelectedCount: Int {
        items.filter { $0.isSelected }.count
    }
    
    var maxSelectable: Int {
        isPremium ? Int.max : maxFreeHabits
    }
    
    var canSelectMore: Bool {
        isPremium || totalSelectedCount < maxFreeHabits
    }
    
    var remainingSlots: Int {
        max(0, maxFreeHabits - totalSelectedCount)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Info section
                if !isPremium {
                    Section {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.blue)
                            Text(String(format: L10n.t("import.limitReached"), remainingSlots))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Existing habits section
                if !existingHabits.isEmpty {
                    Section {
                        ForEach(existingHabits) { item in
                            ImportHabitRow(
                                item: item,
                                isPremium: isPremium,
                                canSelectMore: canSelectMore,
                                maxSelectable: maxSelectable
                            ) {
                                toggleSelection(for: item)
                            }
                        }
                    } header: {
                        Text(L10n.t("import.existingHabits"))
                    }
                }
                
                // New habits section
                if !newHabits.isEmpty {
                    Section {
                        ForEach(newHabits) { item in
                            ImportHabitRow(
                                item: item,
                                isPremium: isPremium,
                                canSelectMore: canSelectMore,
                                maxSelectable: maxSelectable
                            ) {
                                if item.isDuplicate {
                                    duplicateItem = item
                                    showingDuplicateAlert = true
                                } else {
                                    toggleSelection(for: item)
                                }
                            }
                        }
                    } header: {
                        Text(L10n.t("import.newHabits"))
                    } footer: {
                        Text(String(format: L10n.t("import.selectedCount"), selectedNewHabitsCount))
                    }
                }
            }
            .navigationTitle(L10n.t("import.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t("import.button")) {
                        onImport(items)
                    }
                    .disabled(selectedNewHabitsCount == 0)
                }
            }
            .alert(L10n.t("import.duplicate.title"), isPresented: $showingDuplicateAlert) {
                if let item = duplicateItem {
                    Button(L10n.t("import.duplicate.overwrite")) {
                        resolveDuplicate(for: item, resolution: .overwrite)
                    }
                    Button(L10n.t("import.duplicate.skip")) {
                        resolveDuplicate(for: item, resolution: .skip)
                    }
                    Button(L10n.t("import.duplicate.newId")) {
                        resolveDuplicate(for: item, resolution: .newId)
                    }
                    Button(L10n.t("button.cancel"), role: .cancel) {
                        duplicateItem = nil
                    }
                }
            } message: {
                if let item = duplicateItem {
                    Text(String(format: L10n.t("import.duplicate.message"), item.habit.title))
                }
            }
        }
    }
    
    private func toggleSelection(for item: ImportHabitItem) {
        // Don't allow toggling existing habits
        if item.isExisting {
            return
        }
        
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if items[index].isSelected {
            // Deselect
            items[index].isSelected = false
        } else {
            // Check limit
            if !isPremium && totalSelectedCount >= maxFreeHabits {
                return
            }
            items[index].isSelected = true
        }
    }
    
    private func resolveDuplicate(for item: ImportHabitItem, resolution: DuplicateResolution) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        switch resolution {
        case .overwrite:
            items[index].isSelected = true
            items[index].duplicateResolution = .overwrite
        case .skip:
            items[index].isSelected = false
            items[index].duplicateResolution = .skip
        case .newId:
            items[index].isSelected = true
            items[index].duplicateResolution = .newId
        }
        
        duplicateItem = nil
    }
}

struct ImportHabitRow: View {
    let item: ImportHabitItem
    let isPremium: Bool
    let canSelectMore: Bool
    let maxSelectable: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if item.isExisting {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            item.isSelected ? AriumTheme.accent : .secondary
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.habit.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        if item.isDuplicate {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        
                        if item.isExisting {
                            Text("(Existing)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !item.habit.notes.isEmpty {
                        Text(item.habit.notes)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            .opacity(item.isExisting || item.isSelected || canSelectMore ? 1.0 : 0.5)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(item.isExisting || (!item.isSelected && !canSelectMore))
    }
}

#Preview {
    SettingsView()
        .environmentObject(HabitStore())
}
