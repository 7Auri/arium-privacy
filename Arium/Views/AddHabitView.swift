//
//  AddHabitView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    @StateObject private var viewModel = AddHabitViewModel()
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    
    @State private var showingPremiumAlert = false
    @State private var premiumAlertMessage = ""
    @State private var showingTemplates = false
    @State private var showingError = false
    @State private var currentError: AppError?
    @State private var toast: ToastItem?
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Templates Button
                    Button(action: {
                        showingTemplates = true
                    }) {
                        HStack(spacing: 12) {
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
                                
                                Image(systemName: "sparkles")
                                    .applyAppFont(size: 18, weight: .semibold)
                                    .foregroundStyle(AriumTheme.accent)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("habit.templates.use"))
                                    .applyAppFont(size: 16, weight: .semibold)
                                    .foregroundStyle(.primary)
                                
                                Text(L10n.t("habit.templates.description"))
                                    .applyAppFont(size: 13, weight: .regular)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemBackground))
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AriumTheme.accent.opacity(0.08),
                                                AriumTheme.accent.opacity(0.03),
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
                                .stroke(AriumTheme.accent.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(
                            color: AriumTheme.accent.opacity(0.1),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
        .sheet(isPresented: $showingTemplates) {
            ImprovedTemplatesView(viewModel: viewModel)
                .environmentObject(habitStore)
        }
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("habit.title"))
                            .applyAppFont(size: 13)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        
                        TextField(L10n.t("habit.title"), text: $viewModel.title)
                            .textFieldStyle(ModernTextFieldStyle())
                            .submitLabel(.next)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    // Notes Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("habit.notes"))
                            .applyAppFont(size: 13)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $viewModel.notes)
                            .frame(minHeight: 110, maxHeight: 180) // Flexible height for responsiveness
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(Color(.secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    // Category Selector
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.t("habit.category"))
                                .applyAppFont(size: 13)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            
                            if !premiumManager.isPremium {
                                Image(systemName: "crown.fill")
                                    .applyAppFont(size: 11)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                        }
                        
                        if premiumManager.isPremium {
                            // Premium: All categories
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(HabitCategory.allCases) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: viewModel.selectedCategory == category
                                        ) {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                                viewModel.selectedCategory = category
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // Free: Only Personal category
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    CategoryButton(
                                        category: .personal,
                                        isSelected: true
                                    ) {
                                        // Do nothing - locked to personal
                                    }
                                }
                            }
                        }
                    }
                    
                    // Theme Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.t("habit.theme"))
                            .applyAppFont(size: 13)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(HabitTheme.availableThemes) { theme in
                                    ModernThemeButton(
                                        theme: theme,
                                        isSelected: viewModel.selectedTheme.id == theme.id
                                    ) {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                            viewModel.selectedTheme = theme
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Start Date Selector
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.t("habit.startDate"))
                                .applyAppFont(size: 13)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            
                            if !premiumManager.isPremium {
                                Image(systemName: "crown.fill")
                                    .applyAppFont(size: 11)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                            
                            if premiumManager.isPremium {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.showingDatePicker.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(viewModel.startDate.localizedDateString())
                                            .applyAppFont(size: 15)
                                            .foregroundStyle(.primary)
                                        
                                        Image(systemName: "calendar")
                                            .font(.caption)
                                            .foregroundColor(viewModel.selectedTheme.accent)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(8)
                                }
                            } else {
                                Text(viewModel.startDate.localizedDateString())
                                    .applyAppFont(size: 15)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if premiumManager.isPremium && viewModel.showingDatePicker {
                            DatePicker(
                                "",
                                selection: $viewModel.startDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    
                    // Goal Days Selector
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.t("habit.goalDays"))
                                .applyAppFont(size: 13)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            
                            if !premiumManager.isPremium {
                                Image(systemName: "crown.fill")
                                    .applyAppFont(size: 11)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                        }
                        
                        if premiumManager.isPremium {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.goalOptions, id: \.self) { days in
                                        if days == -1 {
                                            // Custom button
                                            Button(action: {
                                                viewModel.showingCustomGoalInput = true
                                            }) {
                                                VStack(spacing: 4) {
                                                    Text(L10n.t("goalDays.custom"))
                                                        .applyAppFont(size: 14, weight: .semibold)
                                                    Image(systemName: "pencil.circle")
                                                        .applyAppFont(size: 12)
                                                }
                                                .foregroundColor(viewModel.selectedTheme.accent)
                                                .frame(width: 70, height: 60)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(viewModel.selectedTheme.accent.opacity(0.1))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(viewModel.selectedTheme.accent, lineWidth: 1.5)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        } else {
                                            GoalDayButton(
                                                days: days,
                                                isSelected: viewModel.goalDays == days && !viewModel.goalOptions.contains(viewModel.goalDays) == false,
                                                accentColor: viewModel.selectedTheme.accent
                                            ) {
                                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                                    viewModel.goalDays = days
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Show custom value if set
                                    if !viewModel.goalOptions.dropLast().contains(viewModel.goalDays) && viewModel.goalDays != -1 {
                                        GoalDayButton(
                                            days: viewModel.goalDays,
                                            isSelected: true,
                                            accentColor: viewModel.selectedTheme.accent
                                        ) {
                                            // Already selected
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } else {
                            // Free tier - locked to 21 days
                            GoalDayButton(
                                days: 21,
                                isSelected: true,
                                accentColor: viewModel.selectedTheme.accent
                            ) {
                                // Do nothing - locked to 21 days
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .opacity(premiumManager.isPremium ? 1.0 : 0.7)
                    
                    // Reminders Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.t("settings.notifications"))
                                .applyAppFont(size: 13)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $viewModel.isReminderEnabled)
                                .labelsHidden()
                                .tint(viewModel.selectedTheme.accent)
                        }
                        
                        if viewModel.isReminderEnabled {
                            if viewModel.dailyRepetitions > 1 {
                                // Multiple Reminders (Premium)
                                VStack(spacing: 12) {
                                    ForEach(0..<viewModel.dailyRepetitions, id: \.self) { index in
                                        let label = viewModel.repetitionLabels?.indices.contains(index) == true 
                                            ? viewModel.repetitionLabels![index]
                                            : ((viewModel.dailyRepetitions <= 5) ? getDefaultLabel(for: index) : String(format: L10n.t("repetition.number"), index + 1))
                                        
                                        HStack {
                                            Text(label)
                                                .applyAppFont(size: 15)
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            
                                            DatePicker(
                                                "",
                                                selection: Binding(
                                                    get: { 
                                                        if viewModel.reminderTimes.indices.contains(index) {
                                                            return viewModel.reminderTimes[index]
                                                        }
                                                        return Date()
                                                    },
                                                    set: { newDate in
                                                        if viewModel.reminderTimes.indices.contains(index) {
                                                            viewModel.reminderTimes[index] = newDate
                                                        } else {
                                                            // Should vary rarely happen due to sync
                                                            while viewModel.reminderTimes.count <= index {
                                                                viewModel.reminderTimes.append(newDate)
                                                            }
                                                            viewModel.reminderTimes[index] = newDate
                                                        }
                                                    }
                                                ),
                                                displayedComponents: .hourAndMinute
                                            )
                                            .labelsHidden()
                                        }
                                        .padding()
                                        .background(Color(.tertiarySystemBackground))
                                        .cornerRadius(12)
                                    }
                                }
                            } else {
                                // Single Reminder
                                HStack {
                                    Text(L10n.t("notification.reminder.time"))
                                        .applyAppFont(size: 15)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    DatePicker(
                                        "",
                                        selection: $viewModel.reminderTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    
                    // Daily Repetitions Section (Premium)
                    DailyRepetitionSettingsView(
                        dailyRepetitions: $viewModel.dailyRepetitions,
                        repetitionLabels: $viewModel.repetitionLabels
                    )
                    
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(
                ZStack {
                    Color(.systemBackground)
                    if appThemeManager.accentColor == .cat {
                        CatThemeBackground()
                            .opacity(0.5)
                    }
                }
            )
            .navigationTitle(L10n.t("habit.new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.cancel")) {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t("button.save")) {
                        saveHabit()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.canSave ? AriumTheme.accent : Color(.tertiaryLabel))
                    .disabled(!viewModel.canSave)
                }
            }
            .alert(L10n.t("premium.title"), isPresented: $showingPremiumAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("premium.button")) {
                    Task {
                        await premiumManager.purchasePremium()
                    }
                }
            } message: {
                Text(premiumAlertMessage.isEmpty ? L10n.t("premium.featureMessage") : premiumAlertMessage)
            }
            .errorAlert(error: $currentError)
            .loadingOverlay(isLoading: premiumManager.isLoading || habitStore.isLoading, message: premiumManager.isLoading ? L10n.t("premium.purchasing") : nil)
            .toast($toast)
            .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(L10n.t("premium.purchase.success.message"))
            }
            .alert(L10n.t("goalDays.custom.prompt"), isPresented: $viewModel.showingCustomGoalInput) {
                TextField(L10n.t("goalDays.custom.placeholder"), text: $viewModel.customGoalDays)
                    .keyboardType(.numberPad)
                Button(L10n.t("button.ok")) {
                    viewModel.setCustomGoalDays(viewModel.customGoalDays)
                    viewModel.customGoalDays = ""
                }
                Button(L10n.t("button.cancel"), role: .cancel) {
                    viewModel.customGoalDays = ""
                }
            }
            .onAppear {
                // Free kullanıcılar için kategoriyi Personal olarak sabitle
                if !premiumManager.isPremium {
                    viewModel.selectedCategory = .personal
                }
            }
        }
    }
    
    private func saveHabit() {
        do {
            let habit = viewModel.createHabit()
            try habitStore.addHabit(habit)
            HapticManager.success()
            let appThemeManager = AppThemeManager.shared
            let message = appThemeManager.accentColor == .cat ? L10n.t("habit.save.success.cat") : L10n.t("habit.save.success")
            toast = ToastItem(message: message, type: .success)
            viewModel.reset()
            
            // Dismiss after a short delay to show toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch let error as HabitError {
            showingError = true
            currentError = error
            HapticManager.error()
        } catch {
            showingError = true
            currentError = HabitError.saveFailed
            HapticManager.error()
        }
    }
    
    private func currentLocaleIdentifier() -> String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        return lang == "tr" ? "tr_TR" : "en_US"
    }
    
    private func getDefaultLabel(for index: Int) -> String {
        switch viewModel.dailyRepetitions {
        case 2:
            return index == 0 ? L10n.t("repetition.morning") : L10n.t("repetition.evening")
        case 3:
            let labels = [L10n.t("repetition.morning"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
            return labels[index]
        case 4:
            let labels = [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
            return labels[index]
        case 5:
            let labels = [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening"), L10n.t("repetition.night")]
            return labels[index]
        default:
            return String(format: L10n.t("repetition.number"), index + 1)
        }
    }
}

// MARK: - Modern Text Field Style

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 1)
            )
    }
}

// MARK: - Modern Theme Button

struct ModernThemeButton: View {
    let theme: HabitTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(theme.accent)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(theme.accent.opacity(0.5), lineWidth: isSelected ? 3 : 0)
                        )
                        .shadow(
                            color: isSelected ? theme.accent.opacity(0.25) : Color.clear,
                            radius: isSelected ? 8 : 0,
                            x: 0,
                            y: isSelected ? 4 : 0
                        )
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                    
                    if let icon = theme.icon {
                        Text(icon)
                            .applyAppFont(size: 28)
                    }
                }
                
                Text(theme.localizedName)
                    .applyAppFont(size: 12)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .frame(width: 70)
            }
            .padding(.vertical, 2)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goal Day Button

// MARK: - Category Button Component

struct CategoryButton: View {
    let category: HabitCategory
    let isSelected: Bool
    var isLocked: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color.opacity(0.2) : Color(.tertiarySystemBackground))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: category.systemIcon)
                        .applyAppFont(size: 24)
                        .foregroundStyle(isSelected ? category.color : .secondary)
                        .opacity(isLocked ? 0.5 : 1.0)
                    
                    // Lock icon overlay
                    if isLocked && !isSelected {
                        Image(systemName: "lock.fill")
                            .applyAppFont(size: 12)
                            .foregroundStyle(.secondary)
                            .offset(x: 20, y: 20)
                    }
                }
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ? category.color : Color(.separator),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                
                // Category name
                Text(category.localizedName)
                    .applyAppFont(size: 12, weight: isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? category.color : .secondary)
                    .opacity(isLocked ? 0.6 : 1.0)
                    .lineLimit(1)
            }
            .frame(width: 90)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? category.lightColor : Color.clear)
            )
            .opacity(isLocked ? 0.6 : 1.0)
            .shadow(
                color: isSelected ? category.color.opacity(0.2) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked && !isSelected)
    }
}

// MARK: - Goal Day Button Component

struct GoalDayButton: View {
    let days: Int
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("\(days)")
                    .applyAppFont(size: 28, weight: .bold)
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(L10n.t("habit.days"))
                    .applyAppFont(size: 11, weight: .medium)
                    .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .frame(width: 80, height: 80)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color(.tertiarySystemBackground)
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.clear : Color(.separator).opacity(0.3),
                        lineWidth: isSelected ? 0 : 1
                    )
            )
            .shadow(
                color: isSelected ? accentColor.opacity(0.3) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: isSelected ? 6 : 0
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddHabitView()
        .environmentObject(HabitStore())
}
