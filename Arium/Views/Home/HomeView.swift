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
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    
    // Force view update when language changes
    @State private var languageUpdateTrigger = UUID()
    
    @State private var showingNoteSheet = false
    @State private var noteText = ""
    @State private var selectedHabitForNote: Habit?
    @State private var habitToDelete: Habit?
    @State private var showingDeleteAlert = false
    @State private var showingAchievements = false
    @AppStorage("isSnowEnabled") private var isSnowEnabled = true
    @State private var snowAutoDisableTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        AriumTheme.background,
                        AriumTheme.background,
                        AriumTheme.accentLight.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header - Fixed at top
                    ModernHeaderView(
                        greeting: viewModel.getGreeting(),
                        remainingSlots: habitStore.remainingFreeSlots,
                        isPremium: premiumManager.isPremium,
                        isSnowEnabled: $isSnowEnabled,
                        onSettingsTap: { viewModel.showingSettings = true },
                        onAchievementsTap: { showingAchievements = true }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .background(
                        LinearGradient(
                            colors: [
                                AriumTheme.background,
                                AriumTheme.background.opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .top)
                    )
                    
                    // Scrollable Content
                    ScrollView {
                        VStack(spacing: 16) {
                            // Today's Summary Card
                            if !habitStore.habits.isEmpty {
                                TodaySummaryCard(
                                    completed: viewModel.completedToday(from: habitStore.habits),
                                    total: viewModel.filteredHabits(from: habitStore.habits).count,
                                    longestStreak: habitStore.getLongestStreak(),
                                    completionRate: viewModel.todayCompletionRate(from: habitStore.habits)
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                
                                // Quick Filters
                                QuickFilterView(selectedFilter: $viewModel.selectedFilter)
                                    .padding(.horizontal, 20)
                                
                                // Stats - Premium Style
                                ModernStatsView(
                                    totalCompletions: habitStore.getTotalCompletions(),
                                    longestStreak: habitStore.getLongestStreak(),
                                    completionRate: habitStore.getCompletionRate()
                                )
                                .padding(.horizontal, 20)
                                
                                // Category Filter (Premium only)
                                if premiumManager.isPremium {
                                    CategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                                }
                                
                                // Search Bar
                                SearchBarView(searchText: $viewModel.searchText)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Habits List or Empty State
                            if habitStore.habits.isEmpty {
                                ModernEmptyStateView()
                                    .padding(.top, 40)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.filteredHabits(from: habitStore.habits)) { habit in
                                        SwipeableHabitCard(
                                            habit: habit,
                                            onTap: {
                                                HapticManager.selection()
                                                viewModel.selectedHabit = habit
                                            },
                                            onToggle: {
                                                // If habit has daily repetitions, open detail view instead
                                                if habit.dailyRepetitions > 1 {
                                                    HapticManager.selection()
                                                    viewModel.selectedHabit = habit
                                                } else if habit.isCompletedToday {
                                                    // Already completed, just toggle off
                                                    HapticManager.light()
                                                    viewModel.toggleHabitCompletion(habit, store: habitStore)
                                                } else {
                                                    // Not completed, check premium for notes
                                                    HapticManager.success()
                                                    if premiumManager.isPremium {
                                                        selectedHabitForNote = habit
                                                        noteText = ""
                                                        showingNoteSheet = true
                                                    } else {
                                                        // Free users: just complete without notes
                                                        viewModel.toggleHabitCompletion(habit, store: habitStore)
                                                    }
                                                }
                                            },
                                            onDelete: {
                                                HapticManager.warning()
                                                habitToDelete = habit
                                                showingDeleteAlert = true
                                            },
                                            onComplete: {
                                                HapticManager.success()
                                                if premiumManager.isPremium {
                                                    selectedHabitForNote = habit
                                                    noteText = ""
                                                    showingNoteSheet = true
                                                } else {
                                                    viewModel.toggleHabitCompletion(habit, store: habitStore)
                                                }
                                            }
                                        )
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                    .refreshable {
                        await refreshHabits()
                    }
                }
                
                // Modern Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ModernAddButton {
                            viewModel.attemptAddHabit(store: habitStore)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 16)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
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
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingAddHabit) {
                AddHabitView()
                    .environmentObject(habitStore)
            }
            .sheet(item: $viewModel.selectedHabit) { habit in
                HabitDetailView(habit: habit)
                    .environmentObject(habitStore)
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
                    .environmentObject(habitStore)
            }
            .sheet(isPresented: $showingAchievements) {
                NavigationStack {
                    AchievementsView()
                        .environmentObject(habitStore)
                        .environmentObject(premiumManager)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(L10n.t("button.done")) {
                                    showingAchievements = false
                                }
                            }
                        }
                }
            }
            .sheet(isPresented: $showingNoteSheet) {
                if let habit = selectedHabitForNote {
                    DailyNoteSheet(
                        noteText: $noteText,
                        themeColor: habit.theme.accent,
                        onComplete: {
                            habitStore.toggleHabitCompletion(habit.id, note: noteText)
                            showingNoteSheet = false
                        },
                        onSkip: {
                            habitStore.toggleHabitCompletion(habit.id)
                            showingNoteSheet = false
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
                }
            }
            .alert(L10n.t("habit.delete.confirm"), isPresented: $showingDeleteAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) {
                    habitToDelete = nil
                }
                Button(L10n.t("button.delete"), role: .destructive) {
                    if let habit = habitToDelete {
                        HapticManager.warning()
                        viewModel.deleteHabit(habit, store: habitStore)
                        habitToDelete = nil
                    }
                }
            } message: {
                if let habit = habitToDelete {
                    Text(L10n.t("habit.delete.message"))
                }
            }
            .alert(L10n.t("premium.title"), isPresented: $viewModel.showingPremiumAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("premium.button")) {
                    Task {
                        do {
                            try await premiumManager.purchasePremium()
                        } catch {
                            viewModel.showingError = true
                            viewModel.currentError = error as? AppError ?? PremiumError.unknown
                        }
                    }
                }
            } message: {
                Text(L10n.t("premium.message"))
            }
            .errorAlert(error: $viewModel.currentError)
            .loadingOverlay(isLoading: habitStore.isLoading || premiumManager.isLoading)
            .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(L10n.t("premium.purchase.success.message"))
            }
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
            .alert(
                "🏆 " + (achievementManager.latestUnlockedAchievement?.title ?? L10n.t("achievement.unlocked.title")),
                isPresented: $achievementManager.showingUnlockAlert
            ) {
                Button(L10n.t("button.ok")) {
                    achievementManager.showingUnlockAlert = false
                }
            } message: {
                if let achievement = achievementManager.latestUnlockedAchievement {
                    Text(achievement.description + "\n\n" + String(format: L10n.t("achievement.xp"), achievement.xpReward))
                }
            }
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
    
    @State private var showingSlotsInfo = false
    @State private var showingPremiumError = false
    @State private var premiumError: AppError?
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AriumTheme.textPrimary, AriumTheme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Arium")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                appThemeManager.accentColor.color,
                                appThemeManager.accentColor.color.opacity(0.8),
                                Color.blue.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: appThemeManager.accentColor.color.opacity(0.4), radius: 6, x: 0, y: 3)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
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
                                .font(.system(size: 20))
                                .opacity(isSnowEnabled ? 1.0 : 0.5)
                        }
                        .shadow(color: isSnowEnabled ? Color.cyan.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                }
                
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
                            .font(.system(size: 20))
                        
                        // Badge for new achievements
                        if achievementManager.newAchievementsCount > 0 {
                            Text("\(achievementManager.newAchievementsCount)")
                                .font(.system(size: 10, weight: .bold))
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
                
                if !isPremium {
                    // Remaining Slots Badge (Tıklanabilir)
                    Button(action: {
                        showingSlotsInfo = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(remainingSlots)")
                                .font(.system(size: 16, weight: .bold))
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
                
                // Settings Button
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AriumTheme.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(AriumTheme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
            }
        }
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
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AriumTheme.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
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
    private let deleteThreshold: CGFloat = 80
    
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
                                        .font(.system(size: 20, weight: .bold))
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
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
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
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        
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
                                        .font(.system(size: 20, weight: .bold))
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
            
            // Main card
            ModernHabitCard(
                habit: habit,
                onTap: onTap,
                onToggle: onToggle,
                onDelete: onDelete
            )
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        isDragging = false
                        
                        if abs(value.translation.width) > deleteThreshold {
                            // Swipe far enough - trigger action
                            if value.translation.width > deleteThreshold {
                                // Right swipe - complete or delete
                                if !habit.isCompletedToday {
                                    onComplete()
                                } else {
                                    onDelete()
                                }
                            } else {
                                // Left swipe - delete or complete
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
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Compact Completion Button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(
                            habit.isCompletedToday 
                                ? habit.theme.accent 
                                : Color.clear
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    habit.isCompletedToday 
                                        ? Color.clear 
                                        : habit.theme.accent.opacity(0.4),
                                    lineWidth: 2.5
                                )
                        )
                    
                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content - Compact Layout
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AriumTheme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Streak Badge - Compact
                    if habit.streak > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.orange)
                            Text("\(habit.streak)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
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
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AriumTheme.textSecondary)
                        .lineLimit(1)
                }
                
                // Category Badge & Repetition Progress - Compact
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Text(habit.category.icon)
                            .font(.system(size: 10))
                        Text(habit.category.localizedName)
                            .font(.system(size: 11, weight: .medium))
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
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
                        .font(.system(size: 20, weight: .bold))
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
                .font(.system(size: 13, weight: .bold, design: .rounded))
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
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @State private var isAnimating = false
    @State private var sparkleRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                // Pulsing background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AriumTheme.accentLight.opacity(0.3),
                                AriumTheme.accentLight.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.8 : 1.0)
                
                // Rotating sparkles
                Image(systemName: "sparkles")
                    .font(.system(size: 50, weight: .light))
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
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
                withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                    sparkleRotation = 360
                }
            }
            
            VStack(spacing: 12) {
                Text(L10n.t("home.empty.title"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AriumTheme.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
                
                Text(L10n.t("home.empty.subtitle"))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AriumTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                    isAnimating = true
                }
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Category Filter View

struct CategoryFilterView: View {
    @Binding var selectedCategory: HabitCategory?
    @ObservedObject private var l10nManager = L10nManager.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories button
                CategoryFilterChip(
                    title: L10n.t("habit.allCategories"),
                    icon: "square.grid.2x2",
                    iconType: .sfSymbol,
                    color: AriumTheme.accent,
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
                            .font(.system(size: isSelected ? 15 : 14, weight: .semibold))
                            .foregroundStyle(isSelected ? .white : color)
                    } else {
                        Text(icon)
                            .font(.system(size: isSelected ? 15 : 14))
                            .foregroundStyle(isSelected ? .white : color)
                    }
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
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
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Today's Summary Card

struct TodaySummaryCard: View {
    let completed: Int
    let total: Int
    let longestStreak: Int
    let completionRate: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("home.today.title"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AriumTheme.textSecondary)
                    
                    Text("\(completed)/\(total)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AriumTheme.textPrimary)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(
                            AriumTheme.cardBorder.opacity(0.2),
                            lineWidth: 8
                        )
                    
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(
                            LinearGradient(
                                colors: [AriumTheme.accent, AriumTheme.accentLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completionRate)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(completionRate * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AriumTheme.accent)
                    }
                }
                .frame(width: 70, height: 70)
            }
            
            // Stats Row
            HStack(spacing: 20) {
                // Streak
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("\(longestStreak)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AriumTheme.textPrimary)
                    Text(L10n.t("habit.days"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AriumTheme.textSecondary)
                }
                
                Spacer()
                
                // Completion Status
                HStack(spacing: 6) {
                    if completed == total && total > 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.green)
                        Text(L10n.t("home.today.allCompleted"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.green)
                    } else {
                        Text(L10n.t("home.today.inProgress"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AriumTheme.textSecondary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AriumTheme.cardBackground)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                AriumTheme.accent.opacity(0.1),
                                AriumTheme.accentLight.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            AriumTheme.accent.opacity(0.3),
                            AriumTheme.accentLight.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: AriumTheme.accent.opacity(0.15), radius: 20, x: 0, y: 8)
    }
}

// MARK: - Quick Filter View

struct QuickFilterView: View {
    @Binding var selectedFilter: HomeViewModel.QuickFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(HomeViewModel.QuickFilter.allCases, id: \.self) { filter in
                    QuickFilterChip(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                        HapticManager.selection()
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct QuickFilterChip: View {
    let filter: HomeViewModel.QuickFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(filter.localizedName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : AriumTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? AriumTheme.accent : AriumTheme.cardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : AriumTheme.cardBorder.opacity(0.3), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? AriumTheme.accent.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AriumTheme.textSecondary)
            
            TextField(L10n.t("home.search.placeholder"), text: $searchText)
                .focused($isSearchFocused)
                .font(.system(size: 16, weight: .regular))
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
                        .font(.system(size: 16, weight: .medium))
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
