//
//  SettingsView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI
import CloudKit
import MessageUI

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
    @State private var isLoadingFromCloud = false
    @State private var showingLanguagePicker = false
    @StateObject private var appThemeManager = AppThemeManager.shared

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
    @StateObject private var feedbackManager = FeedbackManager.shared
    @StateObject private var analyticsManager = AnalyticsManager.shared
    @State private var showingMailComposer = false
    @State private var currentFeedbackType: FeedbackManager.FeedbackType?
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    // MARK: - Computed Properties
    
    private var systemLang: String? {
        L10nManager.detectSystemLanguage()
    }
    
    private var hasSystemLanguage: Bool {
        systemLang != nil
    }
    
    private var currentLanguage: String {
        isSystemLanguage && hasSystemLanguage ? "system" : appLanguage
    }
    
    private var languageDescription: String {
        if currentLanguage == "system" {
            return L10n.t("settings.language.system")
        } else if currentLanguage == "tr" {
            return "Türkçe"
        } else if currentLanguage == "de" {
            return "Deutsch"
        } else if currentLanguage == "fr" {
            return "Français"
        } else if currentLanguage == "es" {
            return "Español"
        } else if currentLanguage == "it" {
            return "Italiano"
        } else {
            return "English"
        }
    }
    
    // MARK: - Modern UI Components
    
    private var headerCard: some View {
        VStack(spacing: 20) {
            // App Icon with specialized glow
            ZStack {
                Circle()
                    .fill(appThemeManager.accentColor.color.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Image("AppIconMain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .padding(.top, 10)
            
            VStack(spacing: 8) {
                // App Name - Premium Gradient Style
                Text("Arium")
                    .applyAppFont(size: 38, weight: .bold)
                    .tracking(1) // Balanced spacing
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                appThemeManager.accentColor.color,
                                appThemeManager.accentColor.color.opacity(0.8),
                                Color.blue.opacity(0.6) // Subtle cool tone mix
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: appThemeManager.accentColor.color.opacity(0.4), radius: 8, x: 0, y: 4)
                
                // Version Info
                HStack(spacing: 6) {
                    Text("v\(Bundle.main.displayVersion)")
                        .applyAppFont(size: 14, weight: .medium)
                        .foregroundStyle(.secondary)
                    
                    if premiumManager.isPremium {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("Premium")
                            .applyAppFont(size: 14, weight: .semibold)
                            .foregroundStyle(appThemeManager.accentColor.color)
                    }
                }
            }
            
            // Stats Row
            HStack(spacing: 20) {
                StatItem(icon: "list.bullet", value: "\(habitStore.habits.count)", color: appThemeManager.accentColor.color)
                StatItem(icon: "checkmark.circle.fill", value: "\(habitStore.getTotalCompletions())", color: .green)
                StatItem(icon: "flame.fill", value: "\(habitStore.habits.map { $0.streak }.max() ?? 0)", color: .orange)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    // Helper Stat Item View
    private struct StatItem: View {
        let icon: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .applyAppFont(size: 18, weight: .semibold)
                    .foregroundStyle(color)
                    .frame(width: 24, height: 24)
                
                Text(value)
                    .applyAppFont(size: 16, weight: .bold)
                    .foregroundStyle(.primary)
            }
            .frame(minWidth: 60)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .tertiarySystemGroupedBackground))
            )
        }
    }
    
    private struct StatBadge: View {
        let icon: String
        let value: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .applyAppFont(size: 11, weight: .semibold)
                    .foregroundStyle(color)
                Text(value)
                    .applyAppFont(size: 13, weight: .bold)
                    .foregroundStyle(AriumTheme.textPrimary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
        }
    }
    
    private var quickStatsCards: some View {
        HStack(alignment: .top, spacing: 12) {
            QuickStatCard(
                icon: "list.bullet",
                iconColor: AriumTheme.accent,
                value: "\(habitStore.habits.count)",
                label: L10n.t("home.stats.total")
            )
            
            QuickStatCard(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                value: "\(habitStore.getTotalCompletions())",
                label: L10n.t("statistics.totalCompletions")
            )
            
            QuickStatCard(
                icon: "flame.fill",
                iconColor: .orange,
                value: "\(habitStore.habits.map { $0.streak }.max() ?? 0)",
                label: L10n.t("home.stats.streak")
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func modernSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .applyAppFont(size: 16, weight: .semibold)
                    .foregroundStyle(iconColor)
                
                Text(title)
                    .applyAppFont(size: 18, weight: .bold)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 4)
            
            content()
        }
    }
    
    // MARK: - Card Views
    
    private var languageCard: some View {
        ModernSettingsCard(
            iconName: "globe",
            iconColor: AriumTheme.accent,
            title: L10n.t("settings.language"),
            description: languageDescription,
            action: {
                showingLanguagePicker = true
            }
        )
    }
    

    
    @State private var showingCustomization = false
    @State private var showingAchievements = false
    
    private var customizationCard: some View {
        ModernSettingsCard(
            iconName: "paintbrush.fill",
            iconColor: appThemeManager.accentColor.color,
            title: L10n.t("settings.customization"),
            description: L10n.t("settings.customization.subtitle"),
            action: {
                showingCustomization = true
            }
        )
        .sheet(isPresented: $showingCustomization) {
            CustomizationView()
        }
    }
    
    private var achievementsCard: some View {
        ModernSettingsCard(
            iconName: "trophy.fill",
            iconColor: .orange,
            title: L10n.t("achievements.title"),
            description: AchievementManager.shared.newAchievementsCount > 0
                ? "\(AchievementManager.shared.newAchievementsCount) " + L10n.t("achievement.new")
                : L10n.t("achievements.viewAll"),
            badge: AchievementManager.shared.newAchievementsCount > 0 ? AchievementManager.shared.newAchievementsCount : nil,
            action: {
                showingAchievements = true
            }
        )
        .sheet(isPresented: $showingAchievements) {
            NavigationStack {
                AchievementsView()
                    .environmentObject(habitStore)
                    .environmentObject(premiumManager)
                    .environmentObject(AchievementManager.shared)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(L10n.t("button.done")) {
                                showingAchievements = false
                            }
                        }
                    }
            }
        }
    }
    
    private var premiumCardDescription: String {
        if premiumManager.isPremium {
            return L10n.t("settings.active")
        } else if premiumManager.isProductLoading {
            return L10n.t("premium.loading")
        } else if premiumManager.productLoadFailed {
            return L10n.t("premium.error.loadFailed")
        } else {
            return premiumManager.product?.displayPrice ?? L10n.t("settings.freePlan")
        }
    }
    
    private var premiumCard: some View {
        VStack(spacing: 12) {
            // Ana premium kartı
            ModernSettingsCard(
                iconName: "crown.fill",
                iconColor: .orange,
                title: L10n.t("settings.premium"),
                description: premiumCardDescription,
                rightIndicator: AnyView(
                    Group {
                        if premiumManager.isPremium {
                            Image(systemName: "checkmark.circle.fill")
                                .applyAppFont(size: 20, weight: .semibold)
                                .foregroundStyle(AriumTheme.success)
                        } else if premiumManager.isLoading || premiumManager.isProductLoading {
                            ProgressView()
                                .tint(.orange)
                        } else if premiumManager.product != nil {
                            Text(L10n.t("premium.button"))
                                .applyAppFont(size: 12)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        // Ürün yüklenemezse buton gösterme
                    }
                ),
                action: {
                    if !premiumManager.isPremium && !premiumManager.isLoading && premiumManager.product != nil {
                        Task {
                            await premiumManager.purchasePremium()
                        }
                    } else if premiumManager.productLoadFailed {
                        // Ürün yüklenemezse tekrar dene
                        Task {
                            await premiumManager.loadProduct()
                        }
                    }
                }
            )
            
            // Satın Alımları Geri Yükle butonu (her zaman görünür — Apple 3.1.1 zorunlu)
            ModernSettingsCard(
                iconName: "arrow.clockwise",
                iconColor: .blue,
                title: L10n.t("premium.restore.button"),
                description: premiumManager.isPremium
                    ? L10n.t("premium.restore.alreadyActive")
                    : L10n.t("premium.restore.description"),
                action: {
                    Task {
                        await premiumManager.restorePurchases()
                    }
                }
            )
        }
    }
    
    @AppStorage("isPersonalizedAIEnabled") private var isPersonalizedAIEnabled = true
    
    private var personalizationCard: some View {
        VStack(spacing: 12) {
            ModernSettingsCard(
                iconName: "brain.head.profile",
                iconColor: .purple,
                title: L10n.t("settings.personalization.toggle"),
                description: L10n.t("settings.personalization.description"),
                toggleBinding: $isPersonalizedAIEnabled,
                toggleTint: .purple,
                action: {}
            )
            
            if ModelPersonalizationService.shared.hasPersonalizedModel {
                ModernSettingsCard(
                    iconName: "arrow.counterclockwise",
                    iconColor: .red,
                    title: L10n.t("settings.personalization.reset"),
                    description: L10n.t("settings.personalization.reset.description"),
                    action: {
                        ModelPersonalizationService.shared.reset()
                        HapticManager.warning()
                    }
                )
            }
        }
    }

    private var notificationsCard: some View {
        VStack(spacing: 12) {
            ModernSettingsCard(
                iconName: "bell.fill",
                iconColor: .orange,
                title: L10n.t("settings.notifications.enable"),
                description: L10n.t("settings.notifications"),
                toggleBinding: $notificationManager.isAuthorized,
                toggleTint: .orange,
                action: {}
            )
            .onChange(of: notificationManager.isAuthorized) { _, newValue in
                if newValue {
                    Task { _ = await notificationManager.requestAuthorization() }
                }
            }
            
            if notificationManager.isAuthorized {
                ModernSettingsCard(
                    iconName: "sparkles",
                    iconColor: .yellow,
                    title: L10n.t("settings.notifications.daily"),
                    description: L10n.t("settings.notifications.daily"),
                    toggleBinding: $isDailyMotivationEnabled,
                    toggleTint: .yellow,
                    action: {}
                )
                .onChange(of: isDailyMotivationEnabled) { _, newValue in
                    Task {
                        if newValue {
                            await notificationManager.scheduleDailyMotivation()
                        } else {
                            notificationManager.cancelDailyMotivation()
                        }
                    }
                }
                
                ModernSettingsCard(
                    iconName: "flame.fill",
                    iconColor: .red,
                    title: L10n.t("settings.notifications.streaks"),
                    description: L10n.t("settings.notifications.streaks"),
                    toggleBinding: $isStreakWarningEnabled,
                    toggleTint: .red,
                    action: {}
                )
            }
        }
    }
    
    private var iCloudCard: some View {
        VStack(spacing: 12) {
            ModernSettingsCard(
                iconName: "icloud.fill",
                iconColor: .blue,
                title: L10n.t("settings.icloud.sync"),
                description: L10n.t("settings.icloud.sync.description"),
                toggleBinding: $habitStore.iCloudSyncEnabled,
                toggleTint: .blue,
                action: {}
            )
            
            if habitStore.iCloudSyncEnabled {
                Button {
                    Task {
                        do {
                            try await habitStore.syncWithiCloud()
                            showingiCloudSyncSuccess = true
                        } catch {
                            print("❌ iCloud sync error: \(error)")
                            showingiCloudSyncError = true
                            
                            if let ckError = error as? CKError {
                                switch ckError.code {
                                case .notAuthenticated:
                                    iCloudSyncError = NetworkError.noConnection
                                case .networkUnavailable, .networkFailure:
                                    iCloudSyncError = NetworkError.noConnection
                                case .quotaExceeded:
                                    iCloudSyncError = NetworkError.serverError
                                default:
                                    iCloudSyncError = NetworkError.unknown
                                }
                            } else {
                                iCloudSyncError = NetworkError.unknown
                            }
                        }
                    }
                } label: {
                    ModernSettingsCard(
                        iconName: cloudSyncManager.isSyncing ? "arrow.clockwise" : "arrow.clockwise.circle.fill",
                        iconColor: .blue,
                        title: L10n.t("settings.icloud.syncNow"),
                        description: cloudSyncManager.isSyncing ? L10n.t("settings.icloud.syncNow") : L10n.t("settings.icloud.syncNow"),
                        rightIndicator: cloudSyncManager.isSyncing ? AnyView(
                            ProgressView()
                                .tint(.blue)
                        ) : nil,
                        action: {}
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(cloudSyncManager.isSyncing)
                
                ModernSettingsCard(
                    iconName: "arrow.down.circle.fill",
                    iconColor: .blue,
                    title: L10n.t("settings.icloud.loadFromCloud"),
                    description: L10n.t("settings.icloud.loadFromCloud.description"),
                    showChevron: false,
                    action: {
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
                                
                                if let ckError = error as? CKError {
                                    switch ckError.code {
                                    case .notAuthenticated:
                                        iCloudSyncError = NetworkError.noConnection
                                    case .networkUnavailable, .networkFailure:
                                        iCloudSyncError = NetworkError.noConnection
                                    case .quotaExceeded:
                                        iCloudSyncError = NetworkError.serverError
                                    default:
                                        iCloudSyncError = NetworkError.unknown
                                    }
                                } else {
                                    iCloudSyncError = NetworkError.unknown
                                }
                            }
                        }
                    }
                )
                .disabled(cloudSyncManager.isSyncing)
                
                if let lastSync = cloudSyncManager.lastSyncDate {
                    ModernSettingsCard(
                        iconName: "checkmark.circle.fill",
                        iconColor: .green,
                        title: L10n.t("settings.icloud.lastSync"),
                        description: lastSync.localizedRelativeTimeString(),
                        showChevron: false,
                        action: {}
                    )
                }
            }
        }
    }
    
    @State private var showingDeleteAllConfirmation = false
    
    private var dataManagementCard: some View {
        VStack(spacing: 12) {
            ModernSettingsCard(
                iconName: "square.and.arrow.up",
                iconColor: .blue,
                title: L10n.t("settings.export.habits"),
                description: L10n.t("settings.export.description"),
                action: {
                    guard !habitStore.habits.isEmpty else {
                        exportError = ExportError.exportFailed
                        return
                    }
                    selectedHabitsForExport = Set(habitStore.habits.map { $0.id })
                    showingExportHabitPicker = true
                }
            )
            
            ModernSettingsCard(
                iconName: "square.and.arrow.down",
                iconColor: .green,
                title: L10n.t("settings.import"),
                description: L10n.t("import.subtitle"),
                action: {
                    showingImportPicker = true
                }
            )
            
            ModernSettingsCard(
                iconName: "trash",
                iconColor: .red,
                title: L10n.t("settings.deleteAllData"),
                description: L10n.t("settings.deleteAllData.description"),
                action: {
                    showingDeleteAllConfirmation = true
                }
            )
            .alert(L10n.t("settings.deleteAllData.confirm.title"), isPresented: $showingDeleteAllConfirmation) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("settings.deleteAllData.confirm.button"), role: .destructive) {
                    // Tüm local verileri sil
                    habitStore.habits.removeAll()
                    
                    // iCloud verilerini sil (eğer sync açıksa)
                    if cloudSyncManager.syncEnabled {
                        Task {
                            await cloudSyncManager.deleteAllCloudData()
                        }
                    }
                    
                    // Premium test durumunu sıfırla
                    UserDefaults.standard.removeObject(forKey: "isTestPremium")
                    
                    HapticManager.warning()
                }
            } message: {
                Text(L10n.t("settings.deleteAllData.confirm.message"))
            }
        }
    }
    
    private var statisticsCard: some View {
        ModernSettingsCard(
            iconName: "chart.bar.fill",
            iconColor: AriumTheme.accent,
            title: L10n.t("statistics.viewStats"),
            description: L10n.t("statistics.title"),
            action: {
                showingStatistics = true
            }
        )
    }
    
    #if DEBUG
    private var debugCard: some View {
        VStack(spacing: 12) {
            ModernSettingsCard(
                iconName: premiumManager.isPremium ? "crown.fill" : "crown",
                iconColor: .orange,
                title: L10n.t("settings.debug.togglePremium"),
                description: premiumManager.isPremium ? L10n.t("settings.active") : L10n.t("settings.freePlan"),
                toggleBinding: Binding(
                    get: { premiumManager.isPremium },
                    set: { newValue in
                        premiumManager.setPremiumStatus(newValue)
                    }
                ),
                toggleTint: .orange,
                action: {}
            )
            
            ModernSettingsCard(
                iconName: "arrow.clockwise",
                iconColor: AriumTheme.accent,
                title: L10n.t("settings.resetOnboarding"),
                description: L10n.t("settings.resetOnboarding"),
                action: {
                    hasSeenOnboarding = false
                }
            )
            
            ModernSettingsCard(
                iconName: "trash",
                iconColor: .red,
                title: L10n.t("settings.clearAllHabits"),
                description: L10n.t("settings.clearAllHabits"),
                action: {
                    habitStore.habits.removeAll()
                }
            )
            
            ModernSettingsCard(
                iconName: "trash.slash",
                iconColor: AriumTheme.accent,
                title: L10n.t("settings.clearCache"),
                description: L10n.t("settings.clearCache"),
                action: {
                    CodingCache.clearCaches()
                    HapticManager.success()
                }
            )
        }
    }
    #endif
    
    private var aboutCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(L10n.t("settings.version"))
                    .applyAppFont(size: 15, weight: .medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(Bundle.main.displayVersion)
                    .applyAppFont(size: 15, weight: .semibold)
                    .foregroundStyle(AriumTheme.accent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            
            HStack {
                Text(L10n.t("settings.totalHabits"))
                    .applyAppFont(size: 15, weight: .medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(habitStore.habits.count)")
                    .applyAppFont(size: 15, weight: .semibold)
                    .foregroundStyle(AriumTheme.accent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            
            HStack {
                Text(L10n.t("settings.totalCompletions"))
                    .applyAppFont(size: 15, weight: .medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(habitStore.getTotalCompletions())")
                    .applyAppFont(size: 15, weight: .semibold)
                    .foregroundStyle(AriumTheme.accent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            
            Button {
                showingPrivacyPolicy = true
            } label: {
                HStack {
                    Text(L10n.t("settings.privacyPolicy"))
                        .applyAppFont(size: 15, weight: .medium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
                    .environmentObject(appThemeManager)
            }
            
            Button {
                showingTermsOfService = true
            } label: {
                HStack {
                    Text(L10n.t("settings.termsOfService"))
                        .applyAppFont(size: 15, weight: .medium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
                    .environmentObject(appThemeManager)
            }
        }
    }
    
    // MARK: - Legacy Section Views (kept for compatibility)
    
    private var languageSection: some View {
        Section {
            SettingsRow(
                iconName: "globe",
                iconColor: AriumTheme.accent,
                title: L10n.t("settings.language"),
                description: languageDescription,
                action: {
                    showingLanguagePicker = true
                }
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
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
                .applyAppFont(size: 13)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
    

    
    private var achievementsSection: some View {
        Section {
            NavigationLink(destination: AchievementsView()) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.t("achievements.title"))
                            .applyAppFont(size: 16, weight: .semibold)
                            .foregroundStyle(.primary)
                        
                        Text(AchievementManager.shared.newAchievementsCount > 0
                            ? "\(AchievementManager.shared.newAchievementsCount) " + L10n.t("achievement.new")
                            : L10n.t("achievements.viewAll"))
                            .applyAppFont(size: 14, weight: .regular)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 72)
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        } header: {
            Text(L10n.t("achievements.title"))
                .applyAppFont(size: 13)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
    

    
    private var notificationsSection: some View {
        Section {
            SettingsRow(
                iconName: "bell.fill",
                iconColor: .orange,
                title: L10n.t("settings.notifications.enable"),
                description: L10n.t("settings.notifications"),
                toggleBinding: $notificationManager.isAuthorized,
                toggleTint: .orange,
                action: {}
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            .onChange(of: notificationManager.isAuthorized) { _, newValue in
                if newValue {
                    Task { _ = await notificationManager.requestAuthorization() }
                }
            }

            if notificationManager.isAuthorized {
                SettingsRow(
                    iconName: "sparkles",
                    iconColor: .yellow,
                    title: L10n.t("settings.notifications.daily"),
                    description: L10n.t("settings.notifications.daily"),
                    toggleBinding: $isDailyMotivationEnabled,
                    toggleTint: .yellow,
                    action: {}
                )
                .listRowBackground(Color(.secondarySystemGroupedBackground))
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .onChange(of: isDailyMotivationEnabled) { _, newValue in
                    Task {
                        if newValue {
                            await notificationManager.scheduleDailyMotivation()
                        } else {
                            notificationManager.cancelDailyMotivation()
                        }
                    }
                }

                SettingsRow(
                    iconName: "flame.fill",
                    iconColor: .red,
                    title: L10n.t("settings.notifications.streaks"),
                    description: L10n.t("settings.notifications.streaks"),
                    toggleBinding: $isStreakWarningEnabled,
                    toggleTint: .red,
                    action: {}
                )
                .listRowBackground(Color(.secondarySystemGroupedBackground))
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            }
        } header: {
            Text(L10n.t("settings.notifications"))
                .applyAppFont(size: 13)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
    
    private var iCloudSyncSection: some View {
        Section {
            SettingsRow(
                iconName: "icloud.fill",
                iconColor: .blue,
                title: L10n.t("settings.icloud.sync"),
                description: L10n.t("settings.icloud.sync.description"),
                toggleBinding: $habitStore.iCloudSyncEnabled,
                toggleTint: .blue,
                action: {}
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))

            if habitStore.iCloudSyncEnabled {
                Button {
                    Task {
                        do {
                            try await habitStore.syncWithiCloud()
                            showingiCloudSyncSuccess = true
                        } catch {
                            print("❌ iCloud sync error: \(error)")
                            showingiCloudSyncError = true
                            
                            if let ckError = error as? CKError {
                                switch ckError.code {
                                case .notAuthenticated:
                                    iCloudSyncError = NetworkError.noConnection
                                case .networkUnavailable, .networkFailure:
                                    iCloudSyncError = NetworkError.noConnection
                                case .quotaExceeded:
                                    iCloudSyncError = NetworkError.serverError
                                default:
                                    iCloudSyncError = NetworkError.unknown
                                }
                            } else {
                                iCloudSyncError = NetworkError.unknown
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            
                            if cloudSyncManager.isSyncing {
                                ProgressView()
                                    .tint(.blue)
                            } else {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.t("settings.icloud.syncNow"))
                                .applyAppFont(size: 16, weight: .semibold)
                                .foregroundStyle(.primary)
                            
                            Text(L10n.t("settings.icloud.syncNow"))
                                .applyAppFont(size: 14, weight: .regular)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .listRowBackground(Color(.secondarySystemGroupedBackground))
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .disabled(cloudSyncManager.isSyncing || isLoadingFromCloud)

                SettingsRow(
                    iconName: isLoadingFromCloud ? "arrow.clockwise" : "arrow.down.circle.fill",
                    iconColor: .blue,
                    title: L10n.t("settings.icloud.loadFromCloud"),
                    description: isLoadingFromCloud ? L10n.t("settings.icloud.loading") : L10n.t("settings.icloud.loadFromCloud.description"),
                    rightIndicator: isLoadingFromCloud ? AnyView(
                        ProgressView()
                            .tint(.blue)
                    ) : nil,
                    showChevron: false,
                    action: {
                        guard !isLoadingFromCloud else { return }
                        isLoadingFromCloud = true
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
                                
                                if let ckError = error as? CKError {
                                    switch ckError.code {
                                    case .notAuthenticated:
                                        iCloudSyncError = NetworkError.noConnection
                                    case .networkUnavailable, .networkFailure:
                                        iCloudSyncError = NetworkError.noConnection
                                    case .quotaExceeded:
                                        iCloudSyncError = NetworkError.serverError
                                    default:
                                        iCloudSyncError = NetworkError.unknown
                                    }
                                } else {
                                    iCloudSyncError = NetworkError.unknown
                                }
                            }
                        }
                    }
                )
                .listRowBackground(Color(.secondarySystemGroupedBackground))
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .disabled(cloudSyncManager.isSyncing)

                if let lastSync = cloudSyncManager.lastSyncDate {
                    SettingsRow(
                        iconName: "checkmark.circle.fill",
                        iconColor: .green,
                        title: L10n.t("settings.icloud.lastSync"),
                        description: lastSync.localizedRelativeTimeString(),
                        showChevron: false,
                        action: {}
                    )
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                }
            }
        } header: {
            Text(L10n.t("settings.icloud.title"))
                .applyAppFont(size: 13)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
    
    
    private var statisticsSection: some View {
        Section {
            SettingsRow(
                iconName: "chart.bar.fill",
                iconColor: AriumTheme.accent,
                title: L10n.t("statistics.viewStats"),
                description: L10n.t("statistics.title"),
                action: {
                    showingStatistics = true
                }
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        } header: {
            Text(L10n.t("statistics.title"))
                .applyAppFont(size: 13)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
        .listSectionSeparator(.hidden)
        .listSectionSpacing(0)
    }
    
    #if DEBUG
    private var debugSection: some View {
        Section {
            SettingsRow(
                iconName: premiumManager.isPremium ? "crown.fill" : "crown",
                iconColor: .orange,
                title: L10n.t("settings.debug.togglePremium"),
                description: premiumManager.isPremium ? L10n.t("settings.active") : L10n.t("settings.freePlan"),
                toggleBinding: Binding(
                    get: { premiumManager.isPremium },
                    set: { newValue in
                        premiumManager.setPremiumStatus(newValue)
                    }
                ),
                toggleTint: .orange,
                action: {}
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))

            SettingsRow(
                iconName: "arrow.clockwise",
                iconColor: AriumTheme.accent,
                title: L10n.t("settings.resetOnboarding"),
                description: L10n.t("settings.resetOnboarding"),
                action: {
                    hasSeenOnboarding = false
                }
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))

            SettingsRow(
                iconName: "trash",
                iconColor: .red,
                title: L10n.t("settings.clearAllHabits"),
                description: L10n.t("settings.clearAllHabits"),
                action: {
                    habitStore.habits.removeAll()
                }
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))

            SettingsRow(
                iconName: "trash.slash",
                iconColor: AriumTheme.accent,
                title: L10n.t("settings.clearCache"),
                description: L10n.t("settings.clearCache"),
                action: {
                    CodingCache.clearCaches()
                    HapticManager.success()
                }
            )
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        } header: {
            Text(L10n.t("settings.debug"))
                .applyAppFont(size: 13)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
    #endif
    
    private var feedbackCard: some View {
        VStack(spacing: 12) {
            // Bir hata gördüm
            ModernSettingsCard(
                iconName: "exclamationmark.triangle.fill",
                iconColor: .red,
                title: L10n.t("settings.feedback.bug"),
                description: L10n.t("settings.feedback.bug.description"),
                action: {
                    currentFeedbackType = .bug
                    showingMailComposer = true
                    feedbackManager.composeMail(type: .bug)
                    analyticsManager.trackFeedback(type: "bug")
                    HapticManager.light()
                }
            )
            
            // Özellik önerisi
            ModernSettingsCard(
                iconName: "lightbulb.fill",
                iconColor: .yellow,
                title: L10n.t("settings.feedback.feature"),
                description: L10n.t("settings.feedback.feature.description"),
                action: {
                    currentFeedbackType = .feature
                    showingMailComposer = true
                    feedbackManager.composeMail(type: .feature)
                    analyticsManager.trackFeedback(type: "feature")
                    HapticManager.light()
                }
            )
            
            // App Store'da değerlendir
            ModernSettingsCard(
                iconName: "star.fill",
                iconColor: .orange,
                title: L10n.t("settings.feedback.review"),
                description: L10n.t("settings.feedback.review.description"),
                action: {
                    feedbackManager.requestAppStoreReview()
                    analyticsManager.trackFeedback(type: "review")
                    HapticManager.success()
                }
            )
        }
    }
    
    private var aboutSection: some View {
        Section {
            VStack(spacing: 16) {
                Image("AppIconMain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(22)
                    .shadow(color: AriumTheme.accent.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Text("Arium")
                    .applyAppFont(size: 24, weight: .bold)
                    .foregroundStyle(AriumTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            
            HStack {
                Text(L10n.t("settings.version"))
                    .applyAppFont(size: 15, weight: .medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(Bundle.main.displayVersion)
                    .applyAppFont(size: 15, weight: .semibold)
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
            
            // swiftlint:disable:next force_unwrapping
            Link(destination: URL(string: "https://7Auri.github.io/arium-privacy/privacy.html")!) {
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
            
            // swiftlint:disable:next force_unwrapping
            Link(destination: URL(string: "https://7Auri.github.io/arium-privacy/terms.html")!) {
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
                .applyAppFont(size: 13)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            // Header Card (now includes inline stats)
            headerCard
            
            // Main Sections
            sectionsContent
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }
    
    private var sectionsContent: some View {
        VStack(spacing: 20) {
            // Language & Appearance
            modernSection(
                title: L10n.t("settings.appearance"),
                icon: "paintpalette.fill",
                iconColor: appThemeManager.accentColor.color
            ) {
                languageCard

                customizationCard
            }

            // Achievements
            modernSection(
                title: L10n.t("achievements.title"),
                icon: "trophy.fill",
                iconColor: .orange
            ) {
                achievementsCard
            }
            
            // Premium
            modernSection(
                title: L10n.t("settings.premium"),
                icon: "crown.fill",
                iconColor: .orange
            ) {
                premiumCard
            }
            
            // AI Personalization (Premium only)
            if premiumManager.isPremium {
                modernSection(
                    title: L10n.t("settings.personalization.title"),
                    icon: "brain.head.profile",
                    iconColor: .purple
                ) {
                    personalizationCard
                }
            }
            
            // Notifications
            modernSection(
                title: L10n.t("settings.notifications"),
                icon: "bell.fill",
                iconColor: .orange
            ) {
                notificationsCard
            }
            
            // iCloud Sync
            modernSection(
                title: L10n.t("settings.icloud.title"),
                icon: "icloud.fill",
                iconColor: .blue
            ) {
                iCloudCard
            }
            
            // Data Management
            modernSection(
                title: L10n.t("settings.data"),
                icon: "externaldrive.fill",
                iconColor: .purple
            ) {
                dataManagementCard
            }
            
            // Statistics
            modernSection(
                title: L10n.t("statistics.title"),
                icon: "chart.bar.fill",
                iconColor: AriumTheme.accent
            ) {
                statisticsCard
            }
            
            // Feedback & Support
            modernSection(
                title: L10n.t("settings.feedback.title"),
                icon: "heart.fill",
                iconColor: .pink
            ) {
                feedbackCard
            }
            
            // Debug Section
            #if DEBUG
            modernSection(
                title: L10n.t("settings.debug"),
                icon: "wrench.and.screwdriver.fill",
                iconColor: .gray
            ) {
                debugCard
            }
            #endif
            
            // About
            aboutCard
        }
        .padding(.horizontal, 20)
    }
    
    private var scrollContent: some View {
        VStack(spacing: 0) {
            mainContent
            Spacer(minLength: 20)
        }
    }
    
    private var navigationContent: some View {
        ScrollView(.vertical) {
            scrollContent
        }
        .background(backgroundGradient)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                Color(.systemGroupedBackground).opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var navigationModifiers: some View {
        navigationContent
            .navigationTitle(L10n.t("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                    .applyAppFont(size: 17, weight: .semibold)
                    .foregroundStyle(AriumTheme.accent)
                }
            }
    }
    
    var body: some View {
        NavigationStack {
            navigationModifiers
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

            .sheet(isPresented: $showingStatistics) {
                StatisticsView(habits: habitStore.habits, isPremium: premiumManager.isPremium)
            }
            .sheet(isPresented: $showingMailComposer) {
                if let type = currentFeedbackType,
                   let mailComposer = feedbackManager.getMailComposeViewController(type: type) {
                    MailComposeView(mailComposer: mailComposer)
                }
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
            // Satın alma beklemede (aile onayı vb.)
            .alert(L10n.t("premium.pending.title"), isPresented: $premiumManager.showingPendingMessage) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(L10n.t("premium.pending.message"))
            }
            // Geri yükleme başarılı
            .alert(L10n.t("premium.restore.success"), isPresented: $premiumManager.showingRestoreSuccess) {
                Button(L10n.t("button.ok")) { }
            }
            // PremiumManager errorMessage alert'i
            .alert(L10n.t("premium.title"), isPresented: Binding(
                get: { premiumManager.errorMessage != nil },
                set: { if !$0 { premiumManager.errorMessage = nil } }
            )) {
                Button(L10n.t("button.ok")) {
                    premiumManager.errorMessage = nil
                }
            } message: {
                if let msg = premiumManager.errorMessage {
                    Text(msg)
                }
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
                ) { selectedHabits, format in
                    do {
                        guard !selectedHabits.isEmpty else {
                            exportError = ExportError.exportFailed
                            return
                        }
                        
                        let url: URL
                        switch format {
                        case .json:
                            // JSON format for backup/restore
                            url = try exportImport.exportToFile(selectedHabits)
                        case .csv:
                            // CSV format for analysis
                            url = try DataExportManager.shared.exportToCSV(habits: selectedHabits)
                        case .pdf:
                            // PDF format for reports
                            url = try DataExportManager.shared.exportToPDF(habits: selectedHabits)
                        }
                        
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
                allowedContentTypes: [.json, .commaSeparatedText],
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
                        
                        // Determine file type by extension
                        let fileExtension = url.pathExtension.lowercased()
                        let importedHabits: [Habit]
                        
                        if fileExtension == "csv" {
                            // Import from CSV
                            print("📄 Detected CSV file, importing...")
                            importedHabits = try DataExportManager.shared.importFromCSV(data: data)
                            print("✅ Successfully imported \(importedHabits.count) habits from CSV")
                        } else {
                            // Import from JSON (default)
                            print("📄 Detected JSON file, importing...")
                            guard let jsonString = String(data: data, encoding: .utf8) else {
                                print("❌ Failed to convert data to string")
                                exportError = ExportError.invalidFormat
                                return
                            }
                            print("✅ JSON string length: \(jsonString.count) characters")
                            
                            importedHabits = try exportImport.importHabits(from: data)
                            print("✅ Successfully imported \(importedHabits.count) habits from JSON")
                        }
                        
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
                    } catch let error as DataExportError {
                        print("❌ Import failed: \(error.localizedDescription)")
                        exportError = ExportError.importFailed
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
                    .applyAppFont(size: 16, weight: .regular)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .applyAppFont(size: 16, weight: .semibold)
                        .foregroundStyle(AriumTheme.accent)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
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
                                .applyAppFont(size: 12)
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
                                .applyAppFont(size: 12)
                                .foregroundStyle(.orange)
                        }
                        
                        if item.isExisting {
                            Text("(Existing)")
                                .applyAppFont(size: 12)
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


// MARK: - Settings Row Component

struct SettingsRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String
    let rightIndicator: AnyView?
    let showChevron: Bool
    let toggleBinding: Binding<Bool>?
    let toggleTint: Color?
    let action: () -> Void
    
    init(
        iconName: String,
        iconColor: Color,
        title: String,
        description: String,
        rightIndicator: AnyView? = nil,
        showChevron: Bool = true,
        toggleBinding: Binding<Bool>? = nil,
        toggleTint: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.rightIndicator = rightIndicator
        self.showChevron = showChevron
        self.toggleBinding = toggleBinding
        self.toggleTint = toggleTint
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.2), iconColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .applyAppFont(size: 20, weight: .semibold)
                        .foregroundStyle(iconColor)
                }
                
                // Title and Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .applyAppFont(size: 16, weight: .semibold)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .applyAppFont(size: 14, weight: .regular)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Right Indicator (optional) + Toggle or Chevron
                if let indicator = rightIndicator {
                    indicator
                }
                
                if let toggleBinding = toggleBinding {
                    Toggle("", isOn: toggleBinding)
                        .labelsHidden()
                        .tint(toggleTint ?? iconColor)
                } else if showChevron {
                    Image(systemName: "chevron.right")
                        .applyAppFont(size: 14, weight: .semibold)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Settings Card

struct ModernSettingsCard: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String
    let rightIndicator: AnyView?
    let showChevron: Bool
    let toggleBinding: Binding<Bool>?
    let toggleTint: Color?
    let badge: Int?
    let action: () -> Void
    
    init(
        iconName: String,
        iconColor: Color,
        title: String,
        description: String,
        rightIndicator: AnyView? = nil,
        showChevron: Bool = true,
        toggleBinding: Binding<Bool>? = nil,
        toggleTint: Color? = nil,
        badge: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.rightIndicator = rightIndicator
        self.showChevron = showChevron
        self.toggleBinding = toggleBinding
        self.toggleTint = toggleTint
        self.badge = badge
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.25), iconColor.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: iconColor.opacity(0.2), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: iconName)
                        .applyAppFont(size: 22, weight: .semibold)
                        .foregroundStyle(iconColor)

                    // Badge
                    if let badge = badge, badge > 0 {
                        Text("\(badge)")
                            .applyAppFont(size: 10, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(.red)
                            )
                            .offset(x: 18, y: -18)
                    }
                }

                // Title and Description
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .applyAppFont(size: 17, weight: .semibold)
                        .foregroundStyle(.primary)

                    Text(description)
                        .applyAppFont(size: 14, weight: .regular)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Right Indicator (optional) + Toggle or Chevron
                if let indicator = rightIndicator {
                    indicator
                }
                
                if let toggleBinding = toggleBinding {
                    Toggle("", isOn: toggleBinding)
                        .labelsHidden()
                        .tint(toggleTint ?? iconColor)
                } else if showChevron {
                    Image(systemName: "chevron.right")
                        .applyAppFont(size: 13, weight: .semibold)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(iconColor.opacity(0.15), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Stat Card

struct QuickStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.25), iconColor.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            Text(value)
                .applyAppFont(size: 24, weight: .bold)
                .foregroundStyle(.primary)
            
            Text(label)
                .applyAppFont(size: 12, weight: .medium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(iconColor.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Export Format Extension

extension ExportFormat {
    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV"
        case .pdf: return "PDF"
        }
    }
    
    var description: String {
        switch self {
        case .json: return L10n.t("export.json.description")
        case .csv: return L10n.t("export.csv.description")
        case .pdf: return L10n.t("export.pdf.description")
        }
    }
    
    var color: Color {
        switch self {
        case .json: return .blue
        case .csv: return .green
        case .pdf: return .red
        }
    }
}

// MARK: - Export Habit Picker Sheet

struct ExportHabitPickerSheet: View {
    let habits: [Habit]
    @Binding var selectedHabits: Set<UUID>
    let onExport: ([Habit], ExportFormat) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var selectedFormat: ExportFormat = .json
    
    var selectedHabitsArray: [Habit] {
        habits.filter { selectedHabits.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Format Selection
                Section {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button {
                            selectedFormat = format
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(format.color.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: format.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(format.color)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(format.displayName)
                                        .applyAppFont(size: 16, weight: .semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text(format.description)
                                        .applyAppFont(size: 12)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(format.color)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } header: {
                    Text(L10n.t("export.format"))
                }
                
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
                        onExport(selectedHabitsArray, selectedFormat)
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

#Preview {
    SettingsView()
        .environmentObject(HabitStore())
}
