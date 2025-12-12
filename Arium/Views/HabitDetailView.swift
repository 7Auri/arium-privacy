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
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    
    @State private var showingNoteAlert = false
    @State private var noteText = ""
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    @State private var toast: ToastItem?
    
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
            .toast($toast)
        }
        .onAppear {
            handleAppear()
        }
        .onChange(of: habitStore.habits) { oldHabits, newHabits in
            handleHabitsChange()
            
            // Check if habit was updated (not deleted)
            let habitId = viewModel.habit.id
            if let oldHabit = oldHabits.first(where: { $0.id == habitId }),
               let newHabit = newHabits.first(where: { $0.id == habitId }),
               oldHabit != newHabit {
                // Habit was updated
                let appThemeManager = AppThemeManager.shared
                let message = appThemeManager.accentColor == .cat ? L10n.t("habit.update.success.cat") : L10n.t("habit.update.success")
                toast = ToastItem(message: message, type: .success)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh habit when app comes to foreground
            refreshHabit()
            viewModel.refreshCompletionForNewDay()
        }
    }
    
    private var headerView: some View {
        HabitDetailHeaderView(habit: viewModel.habit)
    }
    
    private var notesView: some View {
        Group {
            if !viewModel.habit.notes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .applyAppFont(size: 16, weight: .semibold)
                            .foregroundStyle(viewModel.habit.theme.accent)
                        
                        Text(L10n.t("habit.notes"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    
                    Text(viewModel.habit.notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(viewModel.habit.theme.accent.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Weekly Progress View
    
    private var weeklyProgressView: some View {
        HabitDetailWeeklyProgressView(habit: viewModel.habit)
    }
    
    // MARK: - Notes History View
    
    private var notesHistoryView: some View {
        let notesWithDates = getNotesWithDates()
        
        return Group {
            if !notesWithDates.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "note.text.badge.plus")
                            .applyAppFont(size: 16, weight: .semibold)
                            .foregroundStyle(viewModel.habit.theme.accent)
                        
                        Text(L10n.t("habit.notesHistory"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(notesWithDates.prefix(5), id: \.date) { item in
                            NoteHistoryItem(
                                date: item.date,
                                note: item.note,
                                accentColor: viewModel.habit.theme.accent
                            )
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(viewModel.habit.theme.accent.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private func getNotesWithDates() -> [(date: Date, note: String)] {
        var notesWithDates: [(date: Date, note: String)] = []
        
        for (dateKey, note) in viewModel.habit.completionNotes {
            if let date = dateKey.toDate(), !note.isEmpty {
                notesWithDates.append((date: date, note: note))
            }
        }
        
        return notesWithDates.sorted(by: { $0.date > $1.date })
    }
    
    private var statsView: some View {
        HabitDetailStatsView(habit: viewModel.habit)
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
                            .applyAppFont(size: 15)
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
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AriumTheme.accentLight.opacity(0.2),
                                        AriumTheme.accentLight.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AriumTheme.accent, AriumTheme.accent.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text(L10n.t("habit.history.empty"))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AriumTheme.textSecondary)
                    
                    Text(L10n.t("habit.history.empty.subtitle"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AriumTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
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
                                    .applyAppFont(size: 17)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Text(date.localizedTimeString())
                                    .applyAppFont(size: 12)
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
                
                // Weekly Progress View (New)
                weeklyProgressView
                
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
                
                // Enhanced Notes History View
                notesHistoryView
                
                // Calendar Heatmap (Premium)
                if premiumManager.isPremium {
                    CalendarHeatmapView(habit: viewModel.habit, monthsToShow: 12)
                }
                
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
                            // Store previous state to determine if we just completed it
                            let wasCompleted = updatedHabit.isCompletedToday
                            
                            updatedHabit.toggleRepetitionCompletion(at: index)
                            
                            let isNowCompleted = updatedHabit.isCompletedToday
                            // Identify if we just finished it
                            let allCompleted = isNowCompleted && !wasCompleted 
                            
                            // If just marking as completed (even if already was? no, wasCompleted check prevents completion handling if untoggling)
                            // Actually the original logic "Returns true if all repetitions are now completed (and weren't before)"
                            // My manual check: isNowCompleted && !wasCompleted achieves exactly that.
                            habitStore.updateHabit(updatedHabit)
                            viewModel.habit = updatedHabit
                            HapticManager.success()
                            let appThemeManager = AppThemeManager.shared
                            let message = appThemeManager.accentColor == .cat ? L10n.t("habit.update.success.cat") : L10n.t("habit.update.success")
                            toast = ToastItem(message: message, type: .success)
                            
                            // If all repetitions are now completed, show note pop-up
                            if allCompleted && premiumManager.isPremium {
                                noteText = ""
                                showingNoteAlert = true
                            } else if allCompleted {
                                // Free users: just show success feedback
                                HapticManager.success()
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
        // Toggle completion AND save note
        habitStore.toggleHabitCompletion(habitId, note: noteText)
        refreshHabit()
        showingNoteAlert = false
    }
    
    private func handleNoteSkip(habitId: UUID) {
        // Just complete, no note
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
        VStack(spacing: 0) {
            // Top section with app name and habit title
            VStack(spacing: 16) {
                // App name - subtle
                Text("Arium")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(accentColor.opacity(0.7))
                
                // Habit title - prominent
                Text(habit.title)
                    .applyAppFont(size: 48, weight: .bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
            .padding(.top, 80)
            .padding(.bottom, 40)
            
            Spacer()
            
            // Center section with streak
            VStack(spacing: 12) {
                // Streak badge - modern card style
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.orange.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(habit.streak)")
                            .applyAppFont(size: 56, weight: .bold)
                            .foregroundColor(.black)
                        
                        Text(L10n.t("habit.streak"))
                            .applyAppFont(size: 18, weight: .medium)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Bottom section with stats
            HStack(spacing: 20) {
                // Total completions card
                VStack(spacing: 10) {
                    Text("\(habit.completionDates.count)")
                        .applyAppFont(size: 36, weight: .bold)
                        .foregroundColor(accentColor)
                    
                    Text(L10n.t("statistics.totalCompletions"))
                        .applyAppFont(size: 14, weight: .medium)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                )
                
                // Completion rate card
                VStack(spacing: 10) {
                    Text("\(completionRate)%")
                        .applyAppFont(size: 36, weight: .bold)
                        .foregroundColor(accentColor)
                    
                    Text(L10n.t("statistics.completionRate"))
                        .applyAppFont(size: 14, weight: .medium)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var daysTrackingView: some View {
        EmptyView()
    }
    
    private var appNameView: some View {
        EmptyView()
    }
    
    private var habitTitleView: some View {
        EmptyView()
    }
    
    private var streakView: some View {
        EmptyView()
    }
    
    private var statsView: some View {
        EmptyView()
    }
    
    private var completionCountView: some View {
        EmptyView()
    }
    
    private var completionRateView: some View {
        EmptyView()
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

// MARK: - Weekly Day View

struct WeeklyDayView: View {
    let dayInfo: (date: Date, isCompleted: Bool, hasNote: Bool)
    let accentColor: Color
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L10n.currentLanguage == "tr" ? "tr_TR" : "en_US")
        formatter.dateFormat = "EEE"
        return formatter.string(from: dayInfo.date).prefix(1).uppercased()
    }
    
    private var dayNumber: String {
        let calendar = Calendar.current
        return "\(calendar.component(.day, from: dayInfo.date))"
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(dayInfo.date)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(dayName)
                .applyAppFont(size: 11, weight: .semibold)
                .foregroundStyle(isToday ? accentColor : .secondary)
            
            ZStack {
                Circle()
                    .fill(
                        dayInfo.isCompleted
                        ? accentColor
                        : Color(.tertiarySystemBackground)
                    )
                    .frame(width: 36, height: 36)
                
                if dayInfo.isCompleted {
                    Image(systemName: "checkmark")
                        .applyAppFont(size: 14, weight: .bold)
                        .foregroundStyle(.white)
                } else {
                    Text(dayNumber)
                        .applyAppFont(size: 14, weight: .semibold)
                        .foregroundStyle(.secondary)
                }
                
                // Note indicator
                if dayInfo.hasNote {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 8, height: 8)
                        .offset(x: 14, y: -14)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Note History Item

struct NoteHistoryItem: View {
    let date: Date
    let note: String
    let accentColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Date indicator
            VStack(spacing: 4) {
                Text(date.localizedDateString(format: "MMM"))
                    .applyAppFont(size: 11, weight: .semibold)
                    .foregroundStyle(accentColor)
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(accentColor.opacity(0.1))
            .cornerRadius(8)
            
            // Note content
            VStack(alignment: .leading, spacing: 4) {
                Text(note)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
        }
    }
}

#Preview {
    HabitDetailView(habit: Habit(title: "Read", notes: "Read 30 minutes daily", streak: 5))
        .environmentObject(HabitStore())
}

