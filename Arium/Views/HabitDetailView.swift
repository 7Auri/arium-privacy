//
//  HabitDetailView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct HabitDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    @StateObject private var viewModel: HabitDetailViewModel
    @StateObject private var premiumManager = PremiumManager.shared
    
    @State private var showingNoteAlert = false
    @State private var noteText = ""
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    
    init(habit: Habit) {
        _viewModel = StateObject(wrappedValue: HabitDetailViewModel(habit: habit))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if hasHabit {
                    mainContentView
                } else {
                    habitNotFoundView
                }
            }
            .navigationTitle(viewModel.habit.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                    .foregroundColor(AriumTheme.accent)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        HapticManager.selection()
                        Task {
                            await generateShareImage()
                            showingShareSheet = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AriumTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                shareSheetContent
            }
            .sheet(isPresented: $viewModel.showingStatistics) {
                StatisticsView(habit: viewModel.habit, isPremium: premiumManager.isPremium)
            }
            .sheet(isPresented: $showingNoteAlert) {
                noteSheetView
            }
            .alert(L10n.t("habit.delete.confirm"), isPresented: $viewModel.showingDeleteAlert) {
                deleteAlertButtons
            } message: {
                Text(L10n.t("habit.delete.message"))
            }
        }
        .onAppear {
            handleAppear()
        }
        .onChange(of: habitStore.habits) { _, _ in
            handleHabitsChange()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                ProgressRing(
                    progress: viewModel.habit.isCompletedToday ? 1.0 : 0.0,
                    lineWidth: 8,
                    color: viewModel.habit.theme.accent
                )
                .frame(width: 120, height: 120)
                
                VStack(spacing: 4) {
                    Image(systemName: viewModel.habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 30))
                        .foregroundColor(viewModel.habit.theme.accent)
                    
                    Text("\(viewModel.habit.streak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(L10n.t("habit.streak"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Category Badge
            HStack(spacing: 6) {
                Image(systemName: viewModel.habit.category.icon)
                    .font(.caption)
                Text(viewModel.habit.category.localizedName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(viewModel.habit.category.color)
            )
            .shadow(
                color: viewModel.habit.category.color.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var notesView: some View {
        Group {
            if !viewModel.habit.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t("habit.notes"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.habit.notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            }
        }
    }
    
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("habit.stats"))
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 12) {
                MiniStatCard(
                    title: "\(viewModel.habit.goalDays) \(L10n.t("habit.days"))",
                    value: "\(Int(viewModel.getCompletionPercentage(days: viewModel.habit.goalDays) * 100))%",
                    color: viewModel.habit.theme.accent
                )
                
                MiniStatCard(
                    title: L10n.t("habit.stats.30days"),
                    value: "\(Int(viewModel.getCompletionPercentage(days: 30) * 100))%",
                    color: viewModel.habit.theme.accent
                )
                
                MiniStatCard(
                    title: L10n.t("habit.stats.total"),
                    value: "\(viewModel.habit.completionDates.count)",
                    color: viewModel.habit.theme.accent
                )
            }
        }
    }
    
    private var startDateView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Text(L10n.t("habit.startDate"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    if !premiumManager.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Button {
                    if premiumManager.isPremium {
                        viewModel.showingStartDatePicker.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.habit.effectiveStartDate.localizedDateString())
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Image(systemName: premiumManager.isPremium ? "calendar" : "lock.fill")
                            .font(.caption)
                            .foregroundColor(viewModel.habit.theme.accent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
                }
                .disabled(!premiumManager.isPremium)
            }
            
            if premiumManager.isPremium && viewModel.showingStartDatePicker {
                DatePicker(
                    "",
                    selection: $viewModel.editableStartDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
                .onChange(of: viewModel.editableStartDate) { _, newValue in
                    viewModel.updateStartDate(newValue, store: habitStore)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .opacity(premiumManager.isPremium ? 1.0 : 0.7)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showingStartDatePicker)
    }
    
    private var goalDaysView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text(L10n.t("habit.goalDays"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                if !premiumManager.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            if premiumManager.isPremium {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach([7, 14, 21, 30, 60, 90], id: \.self) { days in
                            GoalDayButton(
                                days: days,
                                isSelected: viewModel.habit.goalDays == days,
                                accentColor: viewModel.habit.theme.accent
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    viewModel.updateGoalDays(days, store: habitStore)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        GoalDayButton(
                            days: 21,
                            isSelected: true,
                            accentColor: viewModel.habit.theme.accent
                        ) {
                            // Locked
                        }
                        .disabled(true)
                        
                        Text(L10n.t("premium.featureMessage"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
        .opacity(premiumManager.isPremium ? 1.0 : 0.7)
    }
    
    private var themeView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text(L10n.t("habit.theme"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(HabitTheme.allThemes) { theme in
                        ModernThemeButton(
                            theme: theme,
                            isSelected: viewModel.habit.theme.id == theme.id
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                viewModel.updateTheme(theme, store: habitStore)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
    }
    
    private var reminderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.t("settings.notifications"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Toggle("", isOn: $viewModel.habit.isReminderEnabled)
                    .labelsHidden()
                    .tint(viewModel.habit.theme.accent)
                    .onChange(of: viewModel.habit.isReminderEnabled) { _, newValue in
                        viewModel.toggleReminder(newValue, store: habitStore)
                    }
            }
            
            if viewModel.habit.isReminderEnabled {
                DatePicker(
                    L10n.t("notification.reminder.title"),
                    selection: $viewModel.editableReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .tint(viewModel.habit.theme.accent)
                .onChange(of: viewModel.editableReminderTime) { _, newValue in
                    viewModel.updateReminderTime(newValue, store: habitStore)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.habit.isReminderEnabled)
    }
    
    private var completionButton: some View {
        Button {
            if viewModel.habit.isCompletedToday {
                // If already completed, just toggle off
                HapticManager.light()
                habitStore.toggleHabitCompletion(viewModel.habit.id)
                refreshHabit()
            } else {
                // If not completed, check premium for notes
                HapticManager.success()
                if premiumManager.isPremium {
                    noteText = ""
                    showingNoteAlert = true
                } else {
                    // Free users: just complete without notes
                    habitStore.toggleHabitCompletion(viewModel.habit.id)
                    refreshHabit()
                }
            }
        } label: {
            HStack {
                Image(systemName: viewModel.habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                
                Text(viewModel.habit.isCompletedToday ? L10n.t("habit.completed") : L10n.t("habit.notCompleted"))
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.habit.isCompletedToday
                ? viewModel.habit.theme.accent
                : Color(.tertiaryLabel)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    private var statisticsButton: some View {
        Button {
            viewModel.showingStatistics = true
        } label: {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                
                Text(L10n.t("statistics.viewStats"))
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(viewModel.habit.theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 1)
            )
        }
    }
    
    private var historyView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("habit.history"))
                .font(.headline)
                .foregroundStyle(.primary)
            
            if viewModel.getCompletionHistory().isEmpty {
                Text(L10n.t("habit.history.empty"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.getCompletionHistory().prefix(10), id: \.self) { date in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(viewModel.habit.theme.accent)
                                
                                Text(date.localizedDateString())
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Text(date.localizedTimeString())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Show note if exists
                            if let note = viewModel.habit.noteForDate(date), !note.isEmpty {
                                Text(note)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        if date != viewModel.getCompletionHistory().prefix(10).last {
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            }
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            viewModel.showingDeleteAlert = true
        } label: {
            Text(L10n.t("habit.delete"))
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .cornerRadius(12)
        }
    }
    
    private var hasHabit: Bool {
        habitStore.habits.contains(where: { $0.id == viewModel.habit.id })
    }
    
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                notesView
                statsView
                
                // Daily Repetitions Section (Premium)
                if viewModel.habit.dailyRepetitions > 1 {
                    repetitionsView
                }
                
                startDateView
                goalDaysView
                themeView
                reminderView
                completionButton
                statisticsButton
                historyView
                deleteButton
                Spacer(minLength: 40)
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Repetitions View (Premium)
    
    private var repetitionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Repetition progress header
            RepetitionProgressView(habit: viewModel.habit, compact: false)
            
            // Individual repetition checkboxes
            VStack(spacing: 8) {
                ForEach(0..<viewModel.habit.dailyRepetitions, id: \.self) { index in
                    RepetitionCheckboxView(
                        habit: viewModel.habit,
                        index: index,
                        onToggle: { index in
                            var updatedHabit = viewModel.habit
                            updatedHabit.toggleRepetition(at: index)
                            do {
                                try habitStore.updateHabit(updatedHabit)
                                viewModel.habit = updatedHabit
                                HapticManager.success()
                            } catch {
                                HapticManager.error()
                            }
                        }
                    )
                }
            }
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(viewModel.habit.theme.accent.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var habitNotFoundView: some View {
        VStack {
            Text(L10n.t("habit.notFound"))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func handleAppear() {
        let habitId = viewModel.habit.id
        if !habitStore.habits.contains(where: { $0.id == habitId }) {
            DispatchQueue.main.async {
                dismiss()
            }
            return
        }
        viewModel.refreshCompletionForNewDay()
        refreshHabit()
    }
    
    private func handleHabitsChange() {
        let habitId = viewModel.habit.id
        if !habitStore.habits.contains(where: { $0.id == habitId }) {
            dismiss()
        } else {
            refreshHabit()
        }
    }
    
    private func refreshHabit() {
        let habitId = viewModel.habit.id
        if let updated = habitStore.habits.first(where: { $0.id == habitId }) {
            viewModel.habit = updated
        }
    }
    
    @ViewBuilder
    private var shareSheetContent: some View {
        if let image = shareImage {
            ShareSheet(items: [image])
        } else {
            EmptyView()
        }
    }
    
    private var noteSheetView: some View {
        let habitId = viewModel.habit.id
        let themeColor = viewModel.habit.theme.accent
        
        return DailyNoteSheet(
            noteText: $noteText,
            themeColor: themeColor,
            onComplete: {
                handleNoteComplete(habitId: habitId)
            },
            onSkip: {
                handleNoteSkip(habitId: habitId)
            }
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
    }
    
    private var deleteAlertButtons: some View {
        Group {
            Button(L10n.t("button.cancel"), role: .cancel) { }
            Button(L10n.t("habit.delete"), role: .destructive) {
                handleDeleteHabit()
            }
        }
    }
    
    private func handleNoteComplete(habitId: UUID) {
        habitStore.toggleHabitCompletion(habitId, note: noteText)
        refreshHabit()
        showingNoteAlert = false
    }
    
    private func handleNoteSkip(habitId: UUID) {
        habitStore.toggleHabitCompletion(habitId)
        refreshHabit()
        showingNoteAlert = false
    }
    
    private func handleDeleteHabit() {
        habitStore.deleteHabit(viewModel.habit)
        dismiss()
    }
    
    private func generateShareText() -> String {
        let emoji: String
        if viewModel.habit.streak >= 30 {
            emoji = "🏆"
        } else if viewModel.habit.streak >= 7 {
            emoji = "🔥"
        } else {
            emoji = "✨"
        }
        
        var text = """
        \(emoji) \(viewModel.habit.title)
        
        📊 Streak: \(viewModel.habit.streak) days
        ✅ Completed: \(viewModel.habit.completionDates.count) times
        🎯 Goal: \(viewModel.habit.goalDays) days
        """
        
        if viewModel.habit.isCompletedToday {
            text += "\n\n✅ Completed today!"
        }
        
        text += "\n\n#Arium #HabitTracking"
        
        return text
    }
    
    private func generateShareImage() async {
        let habit = viewModel.habit
        let shareView = HabitShareView(habit: habit)
        let renderer = ImageRenderer(content: shareView)
        // Use scale 2.0 for better performance while maintaining quality
        renderer.scale = 2.0
        // Render on main thread for better performance
        await MainActor.run {
            shareImage = renderer.uiImage
        }
    }
    
    private func currentLocaleIdentifier() -> String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        return lang == "tr" ? "tr_TR" : "en_US"
    }
}

// MARK: - Daily Note Sheet
struct DailyNoteSheet: View {
    @Binding var noteText: String
    let themeColor: Color
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Content Area
                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.t("habit.note.title"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    TextField(L10n.t("habit.note.placeholder"), text: $noteText, axis: .vertical)
                        .lineLimit(3...8)
                        .textFieldStyle(.plain)
                        .padding(16)
                        .frame(minHeight: 100)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFocused ? themeColor : Color(.separator), lineWidth: isFocused ? 2 : 1)
                        )
                        .focused($isFocused)
                        .onChange(of: noteText) { _, newValue in
                            if newValue.count > 100 {
                                noteText = String(newValue.prefix(100))
                            }
                        }
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Spacer()
                        Text("\(noteText.count)/100")
                            .font(.caption)
                            .foregroundStyle(noteText.count >= 100 ? .red : .secondary)
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 20)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        onComplete()
                    } label: {
                        Text(L10n.t("habit.complete"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeColor)
                            .cornerRadius(16)
                    }
                    
                    Button {
                        onSkip()
                    } label: {
                        Text(L10n.t("habit.skipNote"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle(L10n.t("habit.note.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.cancel")) {
                        onSkip()
                    }
                }
            }
        }
        .onAppear {
            // Delay focus to ensure sheet is fully presented
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}

// MARK: - Habit Share View

struct HabitShareView: View {
    let habit: Habit
    
    private var accentColor: Color {
        habit.theme.accent
    }
    
    private var gradientColors: [Color] {
        [
            accentColor.opacity(0.25),
            accentColor.opacity(0.08),
            Color.white
        ]
    }
    
    private var daysSinceStart: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.startOfDay(for: habit.effectiveStartDate)
        return calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
    }
    
    private var completionRate: Int {
        // Calculate completion rate based on goal days (more meaningful for sharing)
        // Total completions / Goal days
        let totalCompletions = habit.completionDates.count
        let goalDays = habit.goalDays
        guard goalDays > 0 else { return 0 }
        
        let rate = Double(totalCompletions) / Double(goalDays)
        return min(100, Int(rate * 100))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            contentView
        }
        .frame(width: 1200, height: 1200) // Higher resolution for better quality
        .background(Color.white) // Ensure white background for sharing
    }
    
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative circles for visual interest
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: 400, height: 400)
                .offset(x: -200, y: -200)
            
            Circle()
                .fill(accentColor.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: 250, y: 300)
            
            Circle()
                .fill(accentColor.opacity(0.08))
                .frame(width: 250, height: 250)
                .offset(x: -150, y: 400)
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 28) {
            appNameView
            habitTitleView
            daysTrackingView
            streakView
            statsView
        }
        .padding(60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var daysTrackingView: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(accentColor)
            
            Text(String(format: L10n.t("share.daysTracking"), habit.goalDays))
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(accentColor.opacity(0.1))
        )
    }
    
    private var appNameView: some View {
        Text("Arium")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundColor(accentColor)
    }
    
    private var habitTitleView: some View {
        Text(habit.title)
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 60)
    }
    
    private var streakView: some View {
        HStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.orange)
            
            Text("\(habit.streak)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            Text(L10n.t("habit.streak"))
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private var statsView: some View {
        HStack(spacing: 32) {
            completionCountView
            completionRateView
        }
        .padding(.top, 16)
    }
    
    private var completionCountView: some View {
        VStack(spacing: 8) {
            Text("\(habit.completionDates.count)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(accentColor)
            Text(L10n.t("statistics.totalCompletions"))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private var completionRateView: some View {
        VStack(spacing: 8) {
            Text("\(completionRate)%")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(accentColor)
            Text(L10n.t("statistics.completionRate"))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

#Preview {
    HabitDetailView(habit: Habit(title: "Read", notes: "Read 30 minutes daily", streak: 5))
        .environmentObject(HabitStore())
}
