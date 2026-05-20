//
//  AIHabitCreatorSheet.swift
//  Arium
//
//  AI-powered habit creator. User types a few words, gets back a structured
//  habit suggestion they can review, edit, and save. Premium-only — gated
//  by the caller, not this view.
//

import SwiftUI

struct AIHabitCreatorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var habitStore: HabitStore
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @StateObject private var aiService = AIHabitService.shared
    
    /// Called after a habit is successfully saved. The owning view uses this
    /// to dismiss its own sheet (e.g. AddHabit) so the user lands back on
    /// home with the new habit visible, not stuck inside two stacked sheets.
    var onSaved: (() -> Void)?
    
    @State private var inputText = ""
    @State private var suggestion: AIHabitSuggestion?
    @State private var errorMessage: String?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AriumTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        header
                        
                        if let suggestion = suggestion {
                            suggestionCard(suggestion)
                        } else {
                            inputCard
                            examplesCard
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .applyAppFont(size: 14, weight: .medium)
                                .foregroundColor(AriumTheme.danger)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AriumTheme.danger.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                VStack {
                    Spacer()
                    bottomBar
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle(L10n.t("ai.habit.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.cancel")) { dismiss() }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isInputFocused = true
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .pink.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            Text(L10n.t("ai.habit.subtitle"))
                .applyAppFont(size: 15, weight: .regular)
                .foregroundColor(AriumTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Input
    
    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("ai.habit.inputLabel"))
                .applyAppFont(size: 13, weight: .semibold)
                .foregroundColor(AriumTheme.textSecondary)
            
            TextField(L10n.t("ai.habit.inputPlaceholder"), text: $inputText, axis: .vertical)
                .lineLimit(3...6)
                .applyAppFont(size: 17, weight: .regular)
                .focused($isInputFocused)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AriumTheme.cardBackground)
                )
        }
    }
    
    private var examplesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.t("ai.habit.examplesLabel"))
                .applyAppFont(size: 13, weight: .semibold)
                .foregroundColor(AriumTheme.textSecondary)
            
            ForEach([
                "ai.habit.example1",
                "ai.habit.example2",
                "ai.habit.example3",
            ], id: \.self) { key in
                Button {
                    HapticManager.selection()
                    inputText = L10n.t(key)
                    isInputFocused = false
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AriumTheme.textTertiary)
                        Text(L10n.t(key))
                            .applyAppFont(size: 14, weight: .regular)
                            .foregroundColor(AriumTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AriumTheme.textTertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AriumTheme.cardBackground.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AriumTheme.textTertiary.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Suggestion
    
    private func suggestionCard(_ suggestion: AIHabitSuggestion) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(suggestion.category.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: suggestion.iconSymbol)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(suggestion.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .applyAppFont(size: 20, weight: .bold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    HStack(spacing: 6) {
                        Text(suggestion.category.icon)
                            .applyAppFont(size: 11)
                        Text(suggestion.category.localizedName)
                            .applyAppFont(size: 12, weight: .medium)
                            .foregroundColor(suggestion.category.color)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AriumTheme.cardBackground)
            )
            
            HStack(spacing: 12) {
                metricTile(
                    icon: "calendar",
                    value: "\(suggestion.goalDays)",
                    label: L10n.t("ai.habit.goalDays")
                )
                metricTile(
                    icon: "clock",
                    value: String(format: "%02d:00", suggestion.reminderHour),
                    label: L10n.t("ai.habit.reminderTime")
                )
                if suggestion.dailyRepetitions > 1 {
                    metricTile(
                        icon: "repeat",
                        value: "\(suggestion.dailyRepetitions)×",
                        label: L10n.t("ai.habit.repetitions")
                    )
                }
            }
            
            if !suggestion.encouragement.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.purple)
                        .padding(.top, 2)
                    Text(suggestion.encouragement)
                        .applyAppFont(size: 14, weight: .medium)
                        .foregroundColor(AriumTheme.textPrimary)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.08), .pink.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            
            Button {
                HapticManager.selection()
                self.suggestion = nil
                errorMessage = nil
                isInputFocused = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text(L10n.t("ai.habit.tryAgain"))
                }
                .applyAppFont(size: 14, weight: .medium)
                .foregroundColor(AriumTheme.textSecondary)
            }
        }
    }
    
    private func metricTile(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(appThemeManager.accentColor.color)
            Text(value)
                .applyAppFont(size: 18, weight: .bold)
                .foregroundColor(AriumTheme.textPrimary)
            Text(label)
                .applyAppFont(size: 11, weight: .medium)
                .foregroundColor(AriumTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AriumTheme.cardBackground)
        )
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.3)
            
            HStack(spacing: 12) {
                if suggestion == nil {
                    Button {
                        Task { await generate() }
                    } label: {
                        HStack(spacing: 8) {
                            if aiService.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "sparkles")
                                Text(L10n.t("ai.habit.generate"))
                            }
                        }
                        .applyAppFont(size: 16, weight: .semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 || aiService.isLoading)
                    .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 ? 0.5 : 1)
                } else {
                    Button {
                        HapticManager.success()
                        save()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                            Text(L10n.t("ai.habit.save"))
                        }
                        .applyAppFont(size: 16, weight: .semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [appThemeManager.accentColor.color, appThemeManager.accentColor.color.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: appThemeManager.accentColor.color.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
    
    // MARK: - Actions
    
    private func generate() async {
        errorMessage = nil
        isInputFocused = false
        do {
            let result = try await aiService.suggestHabit(
                from: inputText,
                language: l10nManager.currentLanguage
            )
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                suggestion = result
            }
            HapticManager.medium()
        } catch let error as AIHabitError {
            errorMessage = error.errorDescription
            HapticManager.warning()
        } catch {
            errorMessage = L10n.t("ai.error.unavailable")
            HapticManager.warning()
        }
    }
    
    private func save() {
        guard let suggestion = suggestion else { return }
        
        // Build a Habit from the suggestion. Reminder time defaults to the
        // suggested hour. We auto-enable reminders only if the user already
        // granted notification permission system-wide — otherwise saving
        // would silently fail to schedule (no permission) and frustrate
        // the user. If they haven't, we leave it disabled and they can
        // toggle it from habit detail later.
        let reminderTime = Calendar.current.date(
            bySettingHour: suggestion.reminderHour,
            minute: 0,
            second: 0,
            of: Date()
        )
        let shouldEnableReminder = NotificationManager.shared.isAuthorized
        
        // Daily repetitions: only honour the model's suggestion for premium
        // users, since multi-rep is a paid feature. Free users get a single
        // rep regardless. We're already gating this whole flow behind
        // premium so this is mostly defence-in-depth.
        let isPremium = PremiumManager.shared.isPremium
        let repetitions = isPremium ? suggestion.dailyRepetitions : 1
        
        // For multi-rep habits, replicate the reminder time so each rep
        // fires at the same hour by default. The user can fan them out in
        // habit detail if they want.
        let reminderTimes: [Date]? = (repetitions > 1 && reminderTime != nil)
            ? Array(repeating: reminderTime!, count: repetitions)
            : nil
        
        let habit = Habit(
            title: suggestion.title,
            notes: suggestion.encouragement,
            goalDays: suggestion.goalDays,
            reminderTime: reminderTime,
            reminderTimes: reminderTimes,
            isReminderEnabled: shouldEnableReminder,
            category: suggestion.category,
            dailyRepetitions: repetitions
        )
        
        do {
            try habitStore.addHabit(habit)
            dismiss()
            // Tell whoever opened us — typically AddHabit — to also close
            // so the user ends up back on home with the new habit visible.
            onSaved?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
