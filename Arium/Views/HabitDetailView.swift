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
    
    @State private var showingNoteAlert = false
    @State private var noteText = ""
    
    init(habit: Habit) {
        _viewModel = StateObject(wrappedValue: HabitDetailViewModel(habit: habit))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                    VStack(spacing: 24) {
                        // Header with Progress Ring
                        headerView
                        
                        // Stats Cards
                        statsView
                        
                        // Start Date Selector
                        startDateView
                        
                        // Goal Days Selector
                        goalDaysView
                        
                        // Completion Button
                        completionButton
                        
                        // Statistics Button
                        statisticsButton
                        
                        // History
                        historyView
                        
                        // Delete Button
                        deleteButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            .background(Color(.systemBackground))
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
            }
            .sheet(isPresented: $viewModel.showingStatistics) {
                StatisticsView(habit: viewModel.habit, isPremium: habitStore.isPremium)
            }
            .sheet(isPresented: $showingNoteAlert) {
                DailyNoteSheet(
                    noteText: $noteText,
                    themeColor: viewModel.habit.theme.accent,
                    onComplete: {
                        habitStore.toggleHabitCompletion(viewModel.habit.id, note: noteText)
                        refreshHabit()
                        showingNoteAlert = false
                    },
                    onSkip: {
                        habitStore.toggleHabitCompletion(viewModel.habit.id)
                        refreshHabit()
                        showingNoteAlert = false
                    }
                )
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
            .alert(L10n.t("habit.delete.confirm"), isPresented: $viewModel.showingDeleteAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("habit.delete"), role: .destructive) {
                    habitStore.deleteHabit(viewModel.habit)
                    dismiss()
                }
            } message: {
                Text(L10n.t("habit.delete.message"))
            }
        }
        .onAppear {
            viewModel.refreshCompletionForNewDay()
            refreshHabit()
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
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .cardStyle()
            
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
                    
                    if !habitStore.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Button {
                    if habitStore.isPremium {
                        viewModel.showingStartDatePicker.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.habit.effectiveStartDate.localizedDateString())
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Image(systemName: habitStore.isPremium ? "calendar" : "lock.fill")
                            .font(.caption)
                            .foregroundColor(viewModel.habit.theme.accent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
                }
                .disabled(!habitStore.isPremium)
            }
            
            if habitStore.isPremium && viewModel.showingStartDatePicker {
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
        .opacity(habitStore.isPremium ? 1.0 : 0.7)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showingStartDatePicker)
    }
    
    private var goalDaysView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(L10n.t("habit.goalDays"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                if !habitStore.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            if habitStore.isPremium {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([7, 14, 21, 30, 60, 90], id: \.self) { days in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    viewModel.updateGoalDays(days, store: habitStore)
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(days)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(viewModel.habit.goalDays == days ? viewModel.habit.theme.accent : .primary)
                                    
                                    Text(L10n.t("habit.days"))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 60, height: 60)
                                .background(
                                    viewModel.habit.goalDays == days
                                    ? viewModel.habit.theme.accent.opacity(0.1)
                                    : Color(.tertiarySystemBackground)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            viewModel.habit.goalDays == days ? viewModel.habit.theme.accent : Color(.separator),
                                            lineWidth: viewModel.habit.goalDays == days ? 2 : 1
                                        )
                                )
                                .shadow(
                                    color: viewModel.habit.goalDays == days ? viewModel.habit.theme.accent.opacity(0.2) : Color.clear,
                                    radius: viewModel.habit.goalDays == days ? 6 : 0,
                                    x: 0,
                                    y: viewModel.habit.goalDays == days ? 3 : 0
                                )
                                .scaleEffect(viewModel.habit.goalDays == days ? 1.02 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            } else {
                Text(L10n.t("premium.featureMessage"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .opacity(habitStore.isPremium ? 1.0 : 0.7)
    }
    
    private var completionButton: some View {
        Button {
            if viewModel.habit.isCompletedToday {
                // If already completed, just toggle off
                habitStore.toggleHabitCompletion(viewModel.habit.id)
                refreshHabit()
            } else {
                // If not completed, check premium for notes
                if habitStore.isPremium {
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
    
    private func refreshHabit() {
        if let updated = habitStore.habits.first(where: { $0.id == viewModel.habit.id }) {
            viewModel.habit = updated
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
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t("habit.note.title"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    TextField(L10n.t("habit.note.placeholder"), text: $noteText, axis: .vertical)
                        .lineLimit(3...5)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isFocused ? themeColor : Color(.separator), lineWidth: isFocused ? 2 : 1)
                        )
                        .focused($isFocused)
                        .onChange(of: noteText) { _, newValue in
                            if newValue.count > 100 {
                                noteText = String(newValue.prefix(100))
                            }
                        }
                    
                    HStack {
                        Spacer()
                        Text("\(noteText.count)/100")
                            .font(.caption2)
                            .foregroundStyle(noteText.count >= 100 ? .red : .secondary)
                    }
                }
                .padding(20)
                
                Spacer()
                
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
                            .cornerRadius(12)
                    }
                    
                    Button {
                        onSkip()
                    } label: {
                        Text(L10n.t("habit.skipNote"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle(L10n.t("habit.note.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            isFocused = true
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
