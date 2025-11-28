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
    @StateObject private var premiumManager = PremiumManager.shared
    
    @State private var showingNoteSheet = false
    @State private var noteText = ""
    @State private var selectedHabitForNote: Habit?
    
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
                    // Modern Header
                    ModernHeaderView(
                        greeting: viewModel.getGreeting(),
                        remainingSlots: habitStore.remainingFreeSlots,
                        isPremium: premiumManager.isPremium,
                        onSettingsTap: { viewModel.showingSettings = true }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Stats - Premium Style
                    if !habitStore.habits.isEmpty {
                        ModernStatsView(
                            totalCompletions: habitStore.getTotalCompletions(),
                            longestStreak: habitStore.getLongestStreak(),
                            completionRate: habitStore.getCompletionRate()
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Category Filter (Premium only)
                        if premiumManager.isPremium {
                            CategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                        }
                        
                        // Search Bar
                        if !habitStore.habits.isEmpty {
                            SearchBarView(searchText: $viewModel.searchText)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                        }
                    }
                    
                    // Habits List or Empty State
                    if habitStore.habits.isEmpty {
                        ModernEmptyStateView()
                    } else {
                        List {
                            ForEach(viewModel.filteredHabits(from: habitStore.habits)) { habit in
                                ModernHabitCard(
                                    habit: habit,
                                    onTap: {
                                        HapticManager.selection()
                                        viewModel.selectedHabit = habit
                                    },
                                    onToggle: {
                                        if habit.isCompletedToday {
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
                                        viewModel.deleteHabit(habit, store: habitStore)
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        HapticManager.warning()
                                        viewModel.deleteHabit(habit, store: habitStore)
                                    } label: {
                                        Label(L10n.t("button.delete"), systemImage: "trash.fill")
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                        .refreshable {
                            await refreshHabits()
                        }
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
                        .padding(.bottom, 20)
                    }
                }
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
    @StateObject private var premiumManager = PremiumManager.shared
    let greeting: String
    let remainingSlots: Int
    let isPremium: Bool
    let onSettingsTap: () -> Void
    
    @State private var showingSlotsInfo = false
    @State private var showingPremiumError = false
    @State private var premiumError: AppError?
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AriumTheme.textPrimary, AriumTheme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(L10n.t("home.title"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AriumTheme.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
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

// MARK: - Modern Habit Card

struct ModernHabitCard: View {
    let habit: Habit
    let onTap: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Modern Completion Button
            ModernCompletionButton(
                isCompleted: habit.isCompletedToday,
                color: habit.theme.accent,
                onToggle: onToggle
            )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(habit.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AriumTheme.textPrimary)
                    .lineLimit(2)
                
                if !habit.notes.isEmpty {
                    Text(habit.notes)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AriumTheme.textSecondary)
                        .lineLimit(2)
                }
                
                // Category Badge & Repetition Progress
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text(habit.category.icon)
                            .font(.caption2)
                        Text(habit.category.localizedName)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(habit.category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(habit.category.color.opacity(0.15))
                    .cornerRadius(8)
                    
                    // Repetition Progress (if > 1)
                    if habit.dailyRepetitions > 1 {
                        RepetitionProgressView(habit: habit, compact: true)
                    }
                }
            }
            
            Spacer()
            
            // Streak Badge
            if habit.streak > 0 {
                ModernStreakBadge(streak: habit.streak)
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base card
                RoundedRectangle(cornerRadius: 20)
                    .fill(AriumTheme.cardBackground)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                habit.theme.accent.opacity(0.08),
                                habit.theme.accent.opacity(0.03),
                                Color.clear
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
                    habit.isCompletedToday ? habit.theme.accent.opacity(0.4) : Color(.separator).opacity(0.3),
                    lineWidth: habit.isCompletedToday ? 2 : 1
                )
        )
        .shadow(
            color: habit.isCompletedToday ? habit.theme.accent.opacity(0.15) : Color.black.opacity(0.05),
            radius: habit.isCompletedToday ? 16 : 8,
            x: 0,
            y: habit.isCompletedToday ? 8 : 4
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
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                        isPressed = false
                    }
                }
        )
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
        HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("\(streak)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AriumTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(AriumTheme.warning.opacity(0.12))
        )
        .overlay(
            Capsule()
                .strokeBorder(AriumTheme.warning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Modern Empty State

struct ModernEmptyStateView: View {
    @ObservedObject private var l10nManager = L10nManager.shared
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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All Categories button
                CategoryFilterChip(
                    title: L10n.t("habit.allCategories"),
                    icon: "square.grid.2x2",
                    color: .purple,
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                }
                
                // Category chips
                ForEach(HabitCategory.allCases) { category in
                    CategoryFilterChip(
                        title: category.localizedName,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: isSelected ? 0 : 1)
            )
            .shadow(
                color: isSelected ? color.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
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

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isSearchFocused: Bool
    
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

#Preview {
    HomeView()
        .environmentObject(HabitStore())
}
