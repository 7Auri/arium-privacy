//
//  HomeView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var habitStore: HabitStore
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var sheetCoordinator = SheetCoordinator()
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    
    // Force view update when language changes
    @State private var languageUpdateTrigger = UUID()
    
    @State private var noteText = ""
    @State private var habitToDelete: Habit?
    @State private var showingDeleteAlert = false
    @AppStorage("isSnowEnabled") private var isSnowEnabled = true
    @State private var snowAutoDisableTask: Task<Void, Never>?
    @State private var showingConfetti = false
    @State private var currentCelebrationType: ConfettiManager.CelebrationType = .allHabitsCompleted
    @State private var celebrationStats: (habitsCount: Int, maxStreak: Int)?
    @State private var toast: ToastItem?
    
    // Günlük kutlama ekranı kontrolü için
    @AppStorage("lastCelebrationShownDate") private var lastCelebrationShownDate: String = ""
    
    // Konfetti kontrolü için cache - sürekli tetiklenmeyi önlemek için
    @State private var lastCheckedCompletionRate: Double = -1
    @State private var lastCheckedDate: Date = Date.distantPast
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AriumTheme.background,
                AriumTheme.background,
                AriumTheme.accentLight.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var headerBackgroundGradient: some View {
        LinearGradient(
            colors: [
                AriumTheme.background,
                AriumTheme.background.opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(edges: .top)
    }
    
    private var headerView: some View {
        ModernHeaderView(
            greeting: viewModel.getGreeting(),
            remainingSlots: habitStore.remainingFreeSlots,
            isPremium: premiumManager.isPremium,
            isSnowEnabled: $isSnowEnabled,
            onSettingsTap: { sheetCoordinator.showSettings() },
            onAchievementsTap: { sheetCoordinator.showAchievements() },
            onInsightsTap: { sheetCoordinator.showInsights() },
            onStatisticsTap: { sheetCoordinator.showStatistics() }
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(headerBackgroundGradient)
    }
    
    var body: some View {
        mainContent
            .overlay {
                // Snow animation for Christmas theme (on top of everything)
                if appThemeManager.accentColor == .christmas && isSnowEnabled {
                    SnowAnimationView()
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }
            }
            .onAppear {
                // Auto-disable snow after 30 seconds if enabled
                if appThemeManager.accentColor == .christmas && isSnowEnabled {
                    snowAutoDisableTask?.cancel()
                    snowAutoDisableTask = Task {
                        try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                        if !Task.isCancelled {
                            await MainActor.run {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    isSnowEnabled = false
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: appThemeManager.accentColor) { oldValue, newValue in
                // Cancel auto-disable if theme changes
                if newValue != .christmas {
                    snowAutoDisableTask?.cancel()
                    snowAutoDisableTask = nil
                } else if newValue == .christmas && isSnowEnabled {
                    // Restart auto-disable timer when switching to Christmas theme
                    snowAutoDisableTask?.cancel()
                    snowAutoDisableTask = Task {
                        try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                        if !Task.isCancelled {
                            await MainActor.run {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    isSnowEnabled = false
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: isSnowEnabled) { oldValue, newValue in
                // Cancel auto-disable if user manually toggles
                if !newValue {
                    snowAutoDisableTask?.cancel()
                    snowAutoDisableTask = nil
                } else if newValue && appThemeManager.accentColor == .christmas {
                    // Restart auto-disable timer if user manually enables
                    snowAutoDisableTask?.cancel()
                    snowAutoDisableTask = Task {
                        try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                        if !Task.isCancelled {
                            await MainActor.run {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    isSnowEnabled = false
                                }
                            }
                        }
                    }
                }
            }
            .onDisappear {
                // Clean up timer when view disappears
                snowAutoDisableTask?.cancel()
                snowAutoDisableTask = nil
            }
            .onChange(of: FontManager.shared.selectedFont) { _, _ in
                // Force view update when font changes
            }
    }
    
    private var scrollableContent: some View {
        HomeContentView(
            premiumManager: premiumManager,
            viewModel: viewModel,
            sheetCoordinator: sheetCoordinator,
            noteText: $noteText,
            habitToDelete: $habitToDelete,
            showingDeleteAlert: $showingDeleteAlert
        )
        .environmentObject(habitStore)
        .refreshable {
            await refreshHabits()
        }
        .onChange(of: habitStore.habits) { oldHabits, newHabits in
            // State değişikliğini bir sonraki run loop'ta yaparak "Modifying state during view update" hatasını önle
            DispatchQueue.main.async {
                // Check if a habit was deleted
                if oldHabits.count > newHabits.count {
                    let message = appThemeManager.accentColor == .cat ? L10n.t("habit.delete.success.cat") : L10n.t("habit.delete.success")
                    toast = ToastItem(message: message, type: .success)
                }
                
                // Sadece gerçekten değişiklik varsa kontrol et
                let currentRate = viewModel.completionRate(for: viewModel.selectedDate, habits: newHabits)
                let currentDate = viewModel.selectedDate
                
                // Completion rate 1.0'a ulaştıysa her zaman celebration kontrolü yap
                // Cache'i bypass et
                if currentRate >= 0.99 {
                    lastCheckedCompletionRate = currentRate
                    lastCheckedDate = currentDate
                    checkForConfetti(habits: newHabits)
                    return
                }
                
                // Aynı tarih ve aynı completion rate ise tekrar kontrol etme (sadece rate < 0.99 için)
                if Calendar.current.isDate(currentDate, inSameDayAs: lastCheckedDate) && 
                   abs(currentRate - lastCheckedCompletionRate) < 0.01 {
                    return
                }
                
                lastCheckedCompletionRate = currentRate
                lastCheckedDate = currentDate
                
                checkForConfetti(habits: newHabits)
            }
        }
        .onChange(of: viewModel.selectedDate) { oldDate, newDate in
            // Tarih değiştiğinde celebration kontrolü yap
            DispatchQueue.main.async {
                checkForConfetti(habits: habitStore.habits)
            }
        }
    }
    
    private var contentStack: some View {
        ZStack {
            // Modern gradient background
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern Header - Fixed at top
                headerView
                
                // Scrollable Content
                scrollableContent
            }
            
            // Confetti Overlay - Enhanced with message
            if showingConfetti {
                ConfettiView(celebrationType: currentCelebrationType)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onAppear {
                        // Keep confetti visible for celebration duration
                        let duration = currentCelebrationType.duration
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                            withAnimation(.easeOut(duration: 0.5)) {
                                showingConfetti = false
                            }
                            
                            // Show share option after confetti (sadece günde bir kez)
                            if let stats = celebrationStats, shouldShowCelebrationSheet() {
                                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                sheetCoordinator.showShareCelebration(
                                    celebrationType: currentCelebrationType,
                                    habitsCount: stats.habitsCount,
                                    maxStreak: stats.maxStreak,
                                    date: viewModel.selectedDate
                                )
                                // Son gösterim tarihini kaydet
                                markCelebrationShown()
                            }
                        }
                    }
            }
            
            // Modern Floating Add Button - Always visible
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ModernAddButton {
                        if habitStore.canAddMoreHabits {
                            sheetCoordinator.showAddHabit()
                        } else {
                            viewModel.showingPremiumAlert = true
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private var mainContent: some View {
        NavigationStack {
            contentStack
                .navigationBarHidden(true)
        }
        .modifier(AlertsModifier(
            viewModel: viewModel,
            habitStore: habitStore,
            premiumManager: premiumManager,
            achievementManager: achievementManager,
            habitToDelete: $habitToDelete,
            showingDeleteAlert: $showingDeleteAlert
        ))
        .toast($toast)
        .onAppear {
            // Free kullanıcılar için kategori filtresini sıfırla
            if !premiumManager.isPremium {
                viewModel.selectedCategory = nil
            }
        }
        .onChange(of: premiumManager.isPremium) { oldValue, newValue in
            // Premium durumu değiştiğinde kategori filtresini sıfırla
            if !newValue {
                viewModel.selectedCategory = nil
            }
        }
        .sheet(isPresented: $sheetCoordinator.showingSheet) {
            sheetCoordinator.sheetContent(
                habitStore: habitStore,
                premiumManager: premiumManager,
                noteText: $noteText,
                showingInsights: .constant(false),
                shareImage: nil,
                habitForNote: nil
            )
        }
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func refreshHabits() async {
        // Simulate refresh delay for better UX
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        await habitStore.updateTodayStatus()
        HapticManager.light()
    }
    @MainActor
    private func checkForConfetti(habits: [Habit]) {
        guard !habits.isEmpty else {
            #if DEBUG
            print("🎉 Celebration check - No habits, skipping")
            #endif
            return
        }
        
        // Calculate completion rate for selected date
        let rate = viewModel.completionRate(for: viewModel.selectedDate, habits: habits)
        
        // Debug: Completion rate'i kontrol et (her zaman göster)
        print("🎉 Celebration check - Rate: \(rate), showingConfetti: \(showingConfetti), habits: \(habits.count)")
        print("   Selected date: \(viewModel.selectedDate)")
        print("   Last celebration date: \(lastCelebrationShownDate)")
        print("   Last checked rate: \(lastCheckedCompletionRate)")
        
        // Sadece yeni bir başarı olduğunda kutlama göster (günde bir kez)
        // rate >= 0.99 kullan (floating point karşılaştırması için)
        // Yeni completion kontrolü: Eğer completion rate yeni 1.0'a ulaştıysa, lastCelebrationShownDate'i sıfırla
        let isNewCompletion = lastCheckedCompletionRate < 0.99 && rate >= 0.99
        if isNewCompletion {
            print("   ⚠️ Completion rate yeni 1.0'a ulaştı - lastCelebrationShownDate sıfırlanıyor")
            // State değişikliğini view update dışında yap
            DispatchQueue.main.async {
                self.lastCelebrationShownDate = ""
            }
        }
        
        // shouldShowCelebration kontrolü - yeni completion durumunda true döndürmeli
        if rate >= 0.99 && !showingConfetti && (shouldShowCelebration() || isNewCompletion) {
            // Check for streak-based celebrations first
            let maxStreak = habits.map { $0.streak }.max() ?? 0
            let celebrationType: ConfettiManager.CelebrationType
            
            if maxStreak >= 100 {
                celebrationType = .streak100Days
            } else if maxStreak >= 30 {
                celebrationType = .streak30Days
            } else if maxStreak >= 7 {
                celebrationType = .streak7Days
            } else {
                celebrationType = .allHabitsCompleted
            }
            
            // Show confetti celebration with haptic feedback
            HapticManager.heavy()
            
            // Store stats for sharing
            celebrationStats = (habits.count, maxStreak)
            
            // State değişikliğini bir sonraki run loop'ta yaparak "Modifying state during view update" hatasını önle
            // DispatchQueue kullan - Task yerine
            DispatchQueue.main.async {
                // Show confetti with spring animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    self.showingConfetti = true
                    self.currentCelebrationType = celebrationType
                }
            }
            
            // Track celebration with performance monitoring
            let startTime = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            AnalyticsManager.shared.trackEvent("all_habits_completed", parameters: [
                "date": dateFormatter.string(from: viewModel.selectedDate),
                "total_habits": habits.count,
                "max_streak": maxStreak,
                "celebration_type": String(describing: celebrationType)
            ])
            
            // Track confetti performance
            let confettiManager = ConfettiManager.shared
            AnalyticsManager.shared.trackConfettiShown(
                type: celebrationType,
                particleCount: celebrationType.particleCount(intensity: confettiManager.intensity),
                startTime: startTime
            )
            
            // Kutlama gösterildiğini işaretle (sadece gerçekten gösterildiğinde)
            // State değişikliğini async yap - view update dışında
            print("✅ Celebration gösteriliyor! Type: \(celebrationType)")
            DispatchQueue.main.async {
                self.markCelebrationShown()
            }
        } else if rate < 1.0 && showingConfetti {
            // Hide confetti if completion rate drops - Task içinde yap
            Task { @MainActor in
                withAnimation(.easeOut(duration: 0.3)) {
                    showingConfetti = false
                }
            }
        }
    }
    
    /// Kutlama ekranının bugün gösterilip gösterilmeyeceğini kontrol eder
    private func shouldShowCelebration() -> Bool {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        // Eğer bugün daha önce gösterilmediyse, göster
        let shouldShow = lastCelebrationShownDate != todayString
        
        // Debug
        print("   shouldShowCelebration: \(shouldShow), lastCelebrationShownDate: '\(lastCelebrationShownDate)', todayString: '\(todayString)'")
        
        return shouldShow
    }
    
    /// Kutlama ekranının bugün gösterilip gösterilmeyeceğini kontrol eder (sheet için)
    private func shouldShowCelebrationSheet() -> Bool {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        // Eğer bugün daha önce gösterilmediyse, göster
        return lastCelebrationShownDate != todayString
    }
    
    /// Kutlama gösterildiğini işaretle
    private func markCelebrationShown() {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        lastCelebrationShownDate = dateFormatter.string(from: today)
    }
}

// MARK: - Extracted Content

private struct HomeContentView: View {
    @EnvironmentObject var habitStore: HabitStore
    @ObservedObject var premiumManager: PremiumManager
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var sheetCoordinator: SheetCoordinator
    @Binding var noteText: String
    @Binding var habitToDelete: Habit?
    @Binding var showingDeleteAlert: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Üst kısım: ScrollView içinde (sabit)
            ScrollView {
                VStack(spacing: 16) {
                    WeeklyCalendarView(selectedDate: $viewModel.selectedDate)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    ModernStatsView(
                        totalCompletions: habitStore.habits.reduce(0) { $0 + $1.completionDates.count },
                        longestStreak: habitStore.habits.map { $0.streak }.max() ?? 0,
                        completionRate: viewModel.completionRate(for: viewModel.selectedDate, habits: habitStore.habits)
                    )
                    .padding(.horizontal, 20)

                    if premiumManager.isPremium {
                        CategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                    }

                    SearchBarView(searchText: $viewModel.searchText)
                        .padding(.horizontal, 20)
                }
            }
            .frame(maxHeight: 300) // Üst kısmın maksimum yüksekliği
            
            // Debug: Alışkanlık sayısını kontrol et
            let allHabits = habitStore.habits
            let filteredHabits = viewModel.filteredHabits(from: allHabits)
            
            // List'in animasyon sorunlarını önlemek için stable ID kullan
            // ID çakışmasını önlemek için hash kullan - sadece count ve hash
            let listId = "\(filteredHabits.count)-\(filteredHabits.map { $0.id.uuidString }.sorted().joined().hashValue)"
            
            #if DEBUG
            let _ = print("🔍 Debug - Toplam alışkanlık: \(allHabits.count), Filtrelenmiş: \(filteredHabits.count)")
            let _ = print("   Seçili kategori: \(viewModel.selectedCategory?.rawValue ?? "Tümü")")
            let _ = print("   Arama metni: '\(viewModel.searchText)'")
            #endif
            
            // Alt kısım: List (ScrollView dışında, kendi scroll'u var)
            if allHabits.isEmpty {
                ModernEmptyStateView(
                    onAddHabit: {
                        if habitStore.canAddMoreHabits {
                            sheetCoordinator.showAddHabit()
                        } else {
                            viewModel.showingPremiumAlert = true
                        }
                    }
                )
                .padding(.top, 40)
            } else if filteredHabits.isEmpty {
                // Alışkanlık var ama filtreleme sonucu boş
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .applyAppFont(size: 60, weight: .light)
                        .foregroundColor(AriumTheme.textSecondary)
                    
                    Text(L10n.t("home.no.results"))
                        .applyAppFont(size: 20, weight: .semibold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(L10n.t("home.no.results.subtitle"))
                        .applyAppFont(size: 16, weight: .regular)
                        .foregroundColor(AriumTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button {
                        viewModel.selectedCategory = nil
                        viewModel.searchText = ""
                    } label: {
                        Text(L10n.t("button.clear.filters"))
                            .applyAppFont(size: 16, weight: .semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AriumTheme.accent)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 60)
            } else {
                // Debug: List'in görünürlüğünü test et
                #if DEBUG
                let _ = print("✅ List render ediliyor - \(filteredHabits.count) alışkanlık")
                #endif
                
                // List (ScrollView dışında, kendi scroll'u var)
                // Animasyon sorunlarını önlemek için id modifier'ı kullan
                List {
                    ForEach(filteredHabits) { habit in
                        #if DEBUG
                        let _ = print("   📝 Alışkanlık render ediliyor: \(habit.title)")
                        #endif
                        ModernHabitCard(
                            habit: habit,
                            onTap: {
                                HapticManager.selection()
                                sheetCoordinator.showHabitDetail(habit)
                            },
                            onToggle: {
                                if habit.dailyRepetitions > 1 {
                                    HapticManager.selection()
                                    sheetCoordinator.showHabitDetail(habit)
                                } else if viewModel.isCompleted(habit, on: viewModel.selectedDate) {
                                    HapticManager.light()
                                    viewModel.toggleCompletion(habit, date: viewModel.selectedDate, store: habitStore)
                                } else {
                                    HapticManager.success()
                                    if premiumManager.isPremium {
                                        noteText = ""
                                        sheetCoordinator.showDailyNote(for: habit)
                                    } else {
                                        viewModel.toggleCompletion(habit, date: viewModel.selectedDate, store: habitStore)
                                    }
                                }
                            },
                            onDelete: {
                                HapticManager.warning()
                                habitToDelete = habit
                                showingDeleteAlert = true
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // Sağa kaydırma - Sil
                            Button(role: .destructive) {
                                HapticManager.warning()
                                habitToDelete = habit
                                showingDeleteAlert = true
                            } label: {
                                Label(L10n.t("button.delete"), systemImage: "trash.fill")
                            }
                            
                            // Tamamlanmamışsa tamamla butonu
                            if !habit.isCompletedToday {
                                Button {
                                    HapticManager.success()
                                    if premiumManager.isPremium {
                                        noteText = ""
                                        sheetCoordinator.showDailyNote(for: habit)
                                    } else {
                                        viewModel.toggleCompletion(habit, date: viewModel.selectedDate, store: habitStore)
                                    }
                                } label: {
                                    Label(L10n.t("habit.completed"), systemImage: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            // Sola kaydırma - Sil
                            Button(role: .destructive) {
                                HapticManager.warning()
                                habitToDelete = habit
                                showingDeleteAlert = true
                            } label: {
                                Label(L10n.t("button.delete"), systemImage: "trash.fill")
                            }
                        }
                    }
                }
                .id(listId) // Stable ID - sadece habits değiştiğinde List yeniden oluşturulur
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .animation(.none, value: filteredHabits.count) // Silme animasyonunu devre dışı bırak
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Modern Header

struct ModernHeaderView: View {
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    let greeting: String
    let remainingSlots: Int
    let isPremium: Bool
    @Binding var isSnowEnabled: Bool
    let onSettingsTap: () -> Void
    let onAchievementsTap: () -> Void
    let onInsightsTap: () -> Void
    let onStatisticsTap: () -> Void
    
    @State private var showingSlotsInfo = false
    @State private var showingPremiumError = false
    @State private var premiumError: AppError?
    
    var body: some View {
        VStack(spacing: 12) {
            // Top row: Greeting, App Name, and Settings
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .applyAppFont(size: 28, weight: .bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AriumTheme.textPrimary, AriumTheme.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text(L10n.t("app.name"))
                        .applyAppFont(size: 18, weight: .semibold)
                        .tracking(2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    appThemeManager.accentColor.color,
                                    appThemeManager.accentColor.color.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineLimit(1)
                        .shadow(color: appThemeManager.accentColor.color.opacity(0.4), radius: 6, x: 0, y: 3)
                }
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    HapticManager.selection()
                    onSettingsTap()
                }) {
                    Image(systemName: "gearshape.fill")
                        .applyAppFont(size: 18, weight: .medium)
                        .foregroundStyle(AriumTheme.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(AriumTheme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
                .interactiveButton(haptic: .selection)
                .accessibilityLabel(L10n.t("settings.title"))
                .accessibilityHint(L10n.t("settings.accessibility.hint"))
            }
            
            // Bottom row: Action buttons
            HStack(spacing: 12) {
                Spacer()
                
                // Snow Toggle Button (only for Christmas theme)
                if appThemeManager.accentColor == .christmas {
                    Button(action: {
                        HapticManager.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isSnowEnabled.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isSnowEnabled ? 
                                            [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)] :
                                            [Color.gray.opacity(0.2), Color.gray.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            
                            Text("❄")
                                .applyAppFont(size: 20)
                                .opacity(isSnowEnabled ? 1.0 : 0.5)
                        }
                        .shadow(color: isSnowEnabled ? Color.cyan.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel(L10n.t("snow.toggle"))
                    .accessibilityHint(isSnowEnabled ? L10n.t("snow.toggle.disable") : L10n.t("snow.toggle.enable"))
                    .accessibilityValue(isSnowEnabled ? L10n.t("snow.enabled") : L10n.t("snow.disabled"))
                }
                
                // Insights Button (Magic Wand) - NEW
                Button(action: {
                    HapticManager.selection()
                    onInsightsTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "wand.and.stars")
                            .applyAppFont(size: 18, weight: .semibold)
                            .foregroundStyle(Color.purple)
                    }
                    .shadow(color: Color.purple.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .interactiveButton(haptic: .selection)
                .accessibilityLabel(L10n.t("insights.title"))
                .accessibilityHint(L10n.t("insights.accessibility.hint"))
                
                // Statistics Button
                Button(action: {
                    HapticManager.selection()
                    onStatisticsTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "chart.bar.fill")
                            .applyAppFont(size: 18, weight: .semibold)
                            .foregroundStyle(Color.blue)
                    }
                    .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .interactiveButton(haptic: .selection)
                .accessibilityLabel(L10n.t("statistics.title"))
                .accessibilityHint(L10n.t("statistics.accessibility.hint"))

                // Achievements Button
                Button(action: {
                    HapticManager.selection()
                    onAchievementsTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Text(appThemeManager.accentColor == .christmas ? "🎄" : "🏆")
                            .applyAppFont(size: 20)
                        
                        // Badge for new achievements
                        if achievementManager.newAchievementsCount > 0 {
                            Text("\(achievementManager.newAchievementsCount)")
                                .applyAppFont(size: 10, weight: .bold)
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(.red)
                                )
                                .offset(x: 14, y: -14)
                        }
                    }
                    .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .interactiveButton(haptic: .selection)
                .accessibilityLabel(L10n.t("achievements.title"))
                .accessibilityHint(L10n.t("achievements.accessibility.hint"))
                .accessibilityValue(achievementManager.newAchievementsCount > 0 ? 
                    String(format: L10n.t("achievements.newCount"), achievementManager.newAchievementsCount) : 
                    "")
                
                if !isPremium {
                    // Remaining Slots Badge (Tıklanabilir)
                    Button(action: {
                        showingSlotsInfo = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .applyAppFont(size: 12, weight: .semibold)
                            Text("\(remainingSlots)")
                                .applyAppFont(size: 16, weight: .bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [AriumTheme.accent, AriumTheme.accent.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: AriumTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .alert(L10n.t("home.slots.title"), isPresented: $showingSlotsInfo) {
                        Button(L10n.t("button.done"), role: .cancel) { }
                        Button(L10n.t("premium.button")) {
                            Task {
                                do {
                                    try await premiumManager.purchasePremium()
                                } catch {
                                    showingPremiumError = true
                                    premiumError = error as? AppError ?? PremiumError.unknown
                                }
                            }
                        }
                    } message: {
                        Text(String(format: L10n.t("home.slots.message"), remainingSlots))
                    }
                    .errorAlert(error: $premiumError)
                    .loadingOverlay(isLoading: premiumManager.isLoading, message: premiumManager.isLoading ? L10n.t("premium.purchasing") : nil)
                    .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                        Button(L10n.t("button.ok")) { }
                    } message: {
                        Text(L10n.t("premium.purchase.success.message"))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Modern Stats View

struct ModernStatsView: View {
    @ObservedObject private var l10nManager = L10nManager.shared
    let totalCompletions: Int
    let longestStreak: Int
    let completionRate: Double
    
    var body: some View {
        HStack(spacing: 12) {
            ModernStatCard(
                icon: "checkmark.circle.fill",
                value: "\(totalCompletions)",
                label: L10n.t("home.stats.total"),
                gradient: [AriumTheme.success, AriumTheme.success.opacity(0.7)]
            )
            
            ModernStatCard(
                icon: "flame.fill",
                value: "\(longestStreak)",
                label: L10n.t("home.stats.streak"),
                gradient: [AriumTheme.warning, AriumTheme.warning.opacity(0.7)]
            )
            
            ModernStatCard(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(Int(completionRate * 100))%",
                label: L10n.t("home.stats.rate"),
                gradient: [AriumTheme.accent, AriumTheme.accent.opacity(0.7)]
            )
        }
    }
}

struct ModernStatCard: View {
    let icon: String
    let value: String
    let label: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .applyAppFont(size: 22, weight: .semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .applyAppFont(size: 20, weight: .bold)
                .foregroundStyle(AriumTheme.textPrimary)
            
            Text(label)
                .applyAppFont(size: 11, weight: .medium)
                .foregroundStyle(AriumTheme.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                // Glass effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(AriumTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                gradient[0].opacity(0.08),
                                gradient[1].opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            AriumTheme.cardBorder,
                            AriumTheme.cardBorder.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Swipeable Habit Card

struct SwipeableHabitCard: View {
    let habit: Habit
    let onTap: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onComplete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    private let swipeThreshold: CGFloat = 100
    private let deleteThreshold: CGFloat = 60 // 80'den 60'a düşürüldü - daha kolay silme
    
    var body: some View {
        ZStack {
            // Background actions
            HStack {
                Spacer()
                
                // Right swipe actions (Complete/Delete)
                if dragOffset > 0 {
                    HStack(spacing: 12) {
                        if !habit.isCompletedToday {
                            Button(action: {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                                onComplete()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "checkmark")
                                        .applyAppFont(size: 20, weight: .bold)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                            onDelete()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 50, height: 50)
                                Image(systemName: "trash.fill")
                                    .applyAppFont(size: 18, weight: .bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .accessibilityLabel(L10n.t("habit.delete"))
                        .accessibilityHint(L10n.t("habit.delete.hint"))
                    }
                    .padding(.trailing, 20)
                    .opacity(min(dragOffset / swipeThreshold, 1.0))
                }
            }
            
            // Left swipe actions (Delete/Complete)
            HStack {
                if dragOffset < 0 {
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                            onDelete()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 50, height: 50)
                                Image(systemName: "trash.fill")
                                    .applyAppFont(size: 18, weight: .bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .accessibilityLabel(L10n.t("habit.delete"))
                        .accessibilityHint(L10n.t("habit.delete.hint"))
                        
                        if !habit.isCompletedToday {
                            Button(action: {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                                onComplete()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "checkmark")
                                        .applyAppFont(size: 20, weight: .bold)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.leading, 20)
                    .opacity(min(abs(dragOffset) / swipeThreshold, 1.0))
                }
                
                Spacer()
            }
            
            // Main card - Swipeable wrapper
            ZStack {
                ModernHabitCard(
                    habit: habit,
                    onTap: onTap,
                    onToggle: onToggle,
                    onDelete: onDelete,
                    isSwipeable: true // Swipeable olduğunu belirt
                )
            }
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 5) // Çok düşük threshold - hemen algıla
                    .onChanged { value in
                        isDragging = true
                        // Sadece yatay kaydırmaya izin ver, dikey kaydırmayı engelle
                        let horizontalMovement = value.translation.width
                        let verticalMovement = abs(value.translation.height)
                        
                        // Yatay hareket dikey hareketten fazlaysa swipe olarak algıla
                        if abs(horizontalMovement) > verticalMovement {
                            dragOffset = horizontalMovement
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        
                        let swipeDistance = abs(value.translation.width)
                        let swipeVelocity = abs(value.predictedEndTranslation.width - value.translation.width)
                        
                        // Hızlı kaydırma veya yeterli mesafe
                        if swipeDistance > deleteThreshold || swipeVelocity > 300 {
                            // Swipe far enough - trigger action
                            if value.translation.width > deleteThreshold {
                                // Right swipe - complete or delete
                                if !habit.isCompletedToday {
                                    onComplete()
                                } else {
                                    onDelete()
                                }
                            } else if value.translation.width < -deleteThreshold {
                                // Left swipe - delete
                                onDelete()
                            }
                            
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        } else {
                            // Not far enough - snap back
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
    }
}

// MARK: - Modern Habit Card

struct ModernHabitCard: View {
    let habit: Habit
    let onTap: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    var isSwipeable: Bool = false // Swipeable modda gesture'ları devre dışı bırak
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Compact Completion Button with Animations
            CompletionButton(habit: habit, onToggle: onToggle)
            
            // Content - Compact Layout
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(habit.title)
                        .applyAppFont(size: 16, weight: .semibold)
                        .foregroundStyle(AriumTheme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Streak Badge - Compact
                    if habit.streak > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .applyAppFont(size: 11, weight: .semibold)
                                .foregroundStyle(.orange)
                            Text("\(habit.streak)")
                                .applyAppFont(size: 12, weight: .bold)
                                .foregroundStyle(AriumTheme.textPrimary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(AriumTheme.warning.opacity(0.12))
                        )
                    }
                }
                
                if !habit.notes.isEmpty {
                    Text(habit.notes)
                        .applyAppFont(size: 13, weight: .regular)
                        .foregroundStyle(AriumTheme.textSecondary)
                        .lineLimit(1)
                }
                
                // Category Badge & Repetition Progress - Compact
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Text(habit.category.icon)
                            .applyAppFont(size: 10)
                        Text(habit.category.localizedName)
                            .applyAppFont(size: 11, weight: .medium)
                    }
                    .foregroundStyle(habit.category.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(habit.category.color.opacity(0.15))
                    .cornerRadius(6)
                    
                    // Repetition Progress (if > 1)
                    if habit.dailyRepetitions > 1 {
                        RepetitionProgressView(habit: habit, compact: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .padding(.horizontal, 0)
        .background(
            ZStack {
                // Base card - More compact
                RoundedRectangle(cornerRadius: 16)
                    .fill(AriumTheme.cardBackground)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                habit.theme.accent.opacity(habit.isCompletedToday ? 0.12 : 0.06),
                                habit.theme.accent.opacity(habit.isCompletedToday ? 0.06 : 0.03),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    habit.isCompletedToday ? habit.theme.accent.opacity(0.5) : Color(.separator).opacity(0.25),
                    lineWidth: habit.isCompletedToday ? 1.5 : 0.5
                )
        )
        .shadow(
            color: habit.isCompletedToday ? habit.theme.accent.opacity(0.2) : Color.black.opacity(0.03),
            radius: habit.isCompletedToday ? 8 : 4,
            x: 0,
            y: habit.isCompletedToday ? 4 : 2
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .brightness(isPressed ? -0.05 : 0)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isSwipeable { // Swipeable modda tap gesture'ı devre dışı
                HapticManager.selection()
                onTap()
            }
        }
        // Swipeable modda press gesture'ı tamamen kaldır - swipe ile çakışmasın
        .background(
            Group {
                if !isSwipeable {
                    Color.clear
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 20)
                                .onChanged { _ in
                                    if !isPressed {
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                            isPressed = true
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isPressed = false
                                    }
                                }
                        )
                }
            }
        )
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label(L10n.t("button.delete"), systemImage: "trash")
            }
        }
    }
}

// MARK: - Modern Completion Button

struct ModernCompletionButton: View {
    let isCompleted: Bool
    let color: Color
    let onToggle: () -> Void
    
    @State private var animateCompletion = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                animateCompletion = true
            }
            onToggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateCompletion = false
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isCompleted ? [color, color.opacity(0.8)] : [AriumTheme.cardBackground],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isCompleted ? Color.clear : color.opacity(0.4),
                                lineWidth: 2.5
                            )
                    )
                    .shadow(
                        color: isCompleted ? color.opacity(0.4) : Color.clear,
                        radius: isCompleted ? 8 : 0,
                        x: 0,
                        y: isCompleted ? 4 : 0
                    )
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .applyAppFont(size: 20, weight: .bold)
                        .foregroundStyle(.white)
                        .scaleEffect(animateCompletion ? 1.3 : 1.0)
                        .opacity(animateCompletion ? 0.5 : 1.0)
                }
                
                // Celebration particles
                if animateCompletion {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(color)
                            .frame(width: 4, height: 4)
                            .offset(
                                x: cos(Double(index) * .pi / 3) * 30,
                                y: sin(Double(index) * .pi / 3) * 30
                            )
                            .opacity(0)
                            .animation(
                                .easeOut(duration: 0.4).delay(Double(index) * 0.02),
                                value: animateCompletion
                            )
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Streak Badge

struct ModernStreakBadge: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("\(streak)")
                .applyAppFont(size: 13, weight: .bold)
                .foregroundStyle(AriumTheme.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(AriumTheme.warning.opacity(0.12))
        )
        .overlay(
            Capsule()
                .strokeBorder(AriumTheme.warning.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Modern Empty State

struct ModernEmptyStateView: View {
    let onAddHabit: () -> Void
    
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @State private var isAnimating = false
    @State private var sparkleRotation: Double = 0
    
    // Accessibility
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                // Arka plan sadece cat theme değilse göster (cat theme için arka plan yok)
                if appThemeManager.accentColor != .cat {
                    // Outer glow circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AriumTheme.accentLight.opacity(0.2),
                                    AriumTheme.accentLight.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                }
                
                // Icon - Cat theme shows Lottie animation, others show sparkles
                if appThemeManager.accentColor == .cat {
                    LottieAnimationView(
                        animationName: "cat-idle",
                        loopMode: .loop,
                        speed: 0.5 // Daha yavaş, daha doğal görünsün
                    )
                    .frame(width: 150, height: 150) // Daha küçük boyut - layout'u bozmamak için
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                    .opacity(isAnimating ? 1.0 : 0.85)
                } else {
                    Image(systemName: "sparkles")
                        .applyAppFont(size: 60, weight: .light)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AriumTheme.accent, AriumTheme.accent.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(sparkleRotation))
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.5)
                }
            }
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                    withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                        sparkleRotation = 360
                    }
                } else {
                    isAnimating = true
                    sparkleRotation = 0
                }
            }
            .accessibilityLabel(L10n.t("home.empty.title"))
            .accessibilityHint(L10n.t("home.empty.subtitle"))
            
            VStack(spacing: 16) {
                Text(appThemeManager.accentColor == .cat ? L10n.t("home.empty.cat.title") : L10n.t("home.empty.title"))
                    .applyAppFont(size: 28, weight: .bold)
                    .foregroundStyle(AriumTheme.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
                
                Text(appThemeManager.accentColor == .cat ? L10n.t("home.empty.cat.subtitle") : L10n.t("home.empty.subtitle"))
                    .applyAppFont(size: 17, weight: .regular)
                    .foregroundStyle(AriumTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
                
                // Add first habit button
                Button {
                    HapticManager.success()
                    onAddHabit()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(L10n.t("home.empty.addFirst"))
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [
                                AriumTheme.accent,
                                AriumTheme.accent.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: AriumTheme.accent.opacity(0.35),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 10)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                    isAnimating = true
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Category Filter View

struct CategoryFilterView: View {
    @Binding var selectedCategory: HabitCategory?
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories button
                CategoryFilterChip(
                    title: L10n.t("habit.allCategories"),
                    icon: "square.grid.2x2",
                    iconType: .sfSymbol,
                    color: appThemeManager.accentColor.color,
                    isSelected: selectedCategory == nil
                ) {
                    HapticManager.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                }
                .id("all-categories-\(l10nManager.currentLanguage)")
                
                // Category chips
                ForEach(HabitCategory.allCases) { category in
                    CategoryFilterChip(
                        title: category.localizedName,
                        icon: category.icon,
                        iconType: .emoji,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        HapticManager.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                    .id("\(category.id)-\(l10nManager.currentLanguage)")
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Category Filter Chip

enum IconType {
    case sfSymbol
    case emoji
}

struct CategoryFilterChip: View {
    let title: String
    let icon: String
    let iconType: IconType
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: 8) {
                // Icon with background circle
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 24, height: 24)
                    }
                    
                    if iconType == .sfSymbol {
                        Image(systemName: icon)
                            .applyAppFont(size: isSelected ? 15 : 14, weight: .semibold)
                            .foregroundStyle(isSelected ? .white : color)
                    } else {
                        Text(icon)
                            .applyAppFont(size: isSelected ? 15 : 14)
                            .foregroundStyle(isSelected ? .white : color)
                    }
                }
                
                Text(title)
                    .applyAppFont(size: 15, weight: .semibold)
                    .foregroundStyle(isSelected ? .white : color)
            }
            .padding(.horizontal, isSelected ? 18 : 16)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        // Selected: Gradient background
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
                    } else {
                        // Unselected: Subtle background with border
                        Capsule()
                            .fill(color.opacity(0.08))
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [color.opacity(0.4), color.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    }
                }
            )
            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.0 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Add Button

struct ModernAddButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.medium()
            action()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AriumTheme.accent, AriumTheme.accent.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                    }
                )
                .shadow(color: AriumTheme.accent.opacity(0.4), radius: 16, x: 0, y: 8)
                .scaleEffect(isPressed ? 0.90 : 1.0)
                .brightness(isPressed ? -0.1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(L10n.t("button.add"))
        .accessibilityHint(L10n.t("habit.new"))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    HapticManager.light()
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isSearchFocused: Bool
    @ObservedObject private var l10nManager = L10nManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .applyAppFont(size: 16, weight: .medium)
                .foregroundStyle(AriumTheme.textSecondary)
            
            TextField(L10n.t("home.search.placeholder"), text: $searchText)
                .focused($isSearchFocused)
                .applyAppFont(size: 16, weight: .regular)
                .foregroundStyle(AriumTheme.textPrimary)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .id("search-\(l10nManager.currentLanguage)")
            
            if !searchText.isEmpty {
                Button {
                    withAnimation {
                        searchText = ""
                        isSearchFocused = false
                    }
                    HapticManager.light()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .applyAppFont(size: 16, weight: .medium)
                        .foregroundStyle(AriumTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AriumTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSearchFocused ? AriumTheme.accent.opacity(0.5) : Color(.separator).opacity(0.3), lineWidth: isSearchFocused ? 2 : 1)
        )
    }
}

// MARK: - Snow Animation View

struct SnowAnimationView: View {
    @State private var snowflakes: [Snowflake] = []
    @State private var animationTimer: Timer?
    
    struct Snowflake: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var speed: CGFloat
        var opacity: Double
        var rotation: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(snowflakes) { flake in
                    Text("❄")
                        .font(.system(size: flake.size))
                        .opacity(flake.opacity)
                        .rotationEffect(.degrees(flake.rotation))
                        .position(x: flake.x, y: flake.y)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                let screenSize = CGSize(
                    width: geometry.size.width,
                    height: max(geometry.size.height, UIScreen.main.bounds.height)
                )
                createSnowflakes(in: screenSize)
                startAnimation(in: screenSize)
            }
            .onDisappear {
                stopAnimation()
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                // Update animation when size changes (e.g., rotation)
                let screenSize = CGSize(
                    width: newSize.width,
                    height: max(newSize.height, UIScreen.main.bounds.height)
                )
                stopAnimation()
                createSnowflakes(in: screenSize)
                startAnimation(in: screenSize)
            }
        }
    }
    
    private func createSnowflakes(in size: CGSize) {
        let screenHeight = max(size.height, UIScreen.main.bounds.height)
        // Reduced from 80 to 40 for better performance
        snowflakes = (0..<40).map { _ in
            Snowflake(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -screenHeight * 0.5...0),
                size: CGFloat.random(in: 12...20),
                speed: CGFloat.random(in: 1.5...3),
                opacity: Double.random(in: 0.4...0.8),
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func startAnimation(in size: CGSize) {
        let screenHeight = max(size.height, UIScreen.main.bounds.height)
        // Increased interval from 0.03 to 0.06 for better performance
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { _ in
            Task { @MainActor in
                for index in snowflakes.indices {
                    snowflakes[index].y += snowflakes[index].speed
                    snowflakes[index].rotation += 1
                    
                    // Reset snowflake when it goes off screen
                    if snowflakes[index].y > screenHeight + 50 {
                        snowflakes[index].y = -50
                        snowflakes[index].x = CGFloat.random(in: 0...size.width)
                        snowflakes[index].rotation = Double.random(in: 0...360)
                    }
                    
                    // Slight horizontal drift (wind effect)
                    snowflakes[index].x += sin(snowflakes[index].y / 100) * 0.3
                    
                    // Keep x within bounds
                    if snowflakes[index].x < 0 {
                        snowflakes[index].x = size.width
                    } else if snowflakes[index].x > size.width {
                        snowflakes[index].x = 0
                    }
                }
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview {
    HomeView()
        .environmentObject(HabitStore())
}
