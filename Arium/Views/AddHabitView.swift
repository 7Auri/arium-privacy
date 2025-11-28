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
    
    @State private var showingPremiumAlert = false
    @State private var premiumAlertMessage = ""
    @State private var showingTemplates = false
    @State private var showingError = false
    @State private var currentError: AppError?
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Templates Button
                    Button(action: {
                        if premiumManager.isPremium {
                            showingTemplates = true
                        } else {
                            premiumAlertMessage = L10n.t("premium.templates.message")
                            showingPremiumAlert = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        premiumManager.isPremium
                                        ? LinearGradient(
                                            colors: [AriumTheme.accent.opacity(0.2), AriumTheme.accent.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [Color(.tertiarySystemBackground), Color(.tertiarySystemBackground)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: premiumManager.isPremium ? "sparkles" : "lock.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(
                                        premiumManager.isPremium
                                        ? AriumTheme.accent
                                        : Color(.secondaryLabel)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("habit.templates.use"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text(premiumManager.isPremium ? L10n.t("habit.templates.description") : L10n.t("premium.templates.message"))
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            if !premiumManager.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .orange.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemBackground))
                                
                                if premiumManager.isPremium {
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
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    premiumManager.isPremium
                                    ? AriumTheme.accent.opacity(0.3)
                                    : Color(.separator).opacity(0.3),
                                    lineWidth: premiumManager.isPremium ? 1.5 : 1
                                )
                        )
                        .shadow(
                            color: premiumManager.isPremium
                            ? AriumTheme.accent.opacity(0.1)
                            : Color.clear,
                            radius: premiumManager.isPremium ? 8 : 0,
                            x: 0,
                            y: premiumManager.isPremium ? 4 : 0
                        )
                    }
        .sheet(isPresented: $showingTemplates) {
            ImprovedTemplatesView(viewModel: viewModel)
                .environmentObject(habitStore)
        }
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("habit.title"))
                            .font(.footnote)
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
                            .font(.footnote)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $viewModel.notes)
                            .frame(height: 110)
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
                    
                    // Category Selector (Premium)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.t("habit.category"))
                                .font(.footnote)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            
                            if !premiumManager.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if premiumManager.isPremium {
                            // Premium: Tüm kategoriler
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
                            // Free: Sadece Personal kategorisi (görünür ama değiştirilemez)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    CategoryButton(
                                        category: .personal,
                                        isSelected: true,
                                        isLocked: true
                                    ) {
                                        premiumAlertMessage = L10n.t("premium.categoryLocked")
                                        showingPremiumAlert = true
                                    }
                                    
                                    // Diğer kategoriler kilitli olarak göster
                                    ForEach(HabitCategory.allCases.filter { $0 != .personal }) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: false,
                                            isLocked: true
                                        ) {
                                            premiumAlertMessage = L10n.t("premium.categoryLocked")
                                            showingPremiumAlert = true
                                        }
                                    }
                                }
                            }
                            
                            // Premium upgrade mesajı
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                Text(L10n.t("premium.categoryLocked"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    // Theme Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.t("habit.theme"))
                            .font(.footnote)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(HabitTheme.allThemes) { theme in
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
                    
                    // Start Date Selector (Premium)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Text(L10n.t("habit.startDate"))
                                    .font(.footnote)
                                    .textCase(.uppercase)
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
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.showingDatePicker.toggle()
                                    }
                                } else {
                                    if !premiumManager.isPremium {
                                        premiumAlertMessage = L10n.t("premium.featureMessage")
                                        showingPremiumAlert = true
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(viewModel.startDate.localizedDateString())
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    
                                    Image(systemName: premiumManager.isPremium ? "calendar" : "lock.fill")
                                        .font(.caption)
                                        .foregroundColor(viewModel.selectedTheme.accent)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
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
                    .opacity(premiumManager.isPremium ? 1.0 : 0.7)
                    
                    // Goal Days Selector (Premium)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text(L10n.t("habit.goalDays"))
                                .font(.footnote)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            
                            if !premiumManager.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
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
                                                        .font(.system(size: 14, weight: .semibold))
                                                    Image(systemName: "pencil.circle")
                                                        .font(.caption)
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
                            VStack(spacing: 8) {
                                GoalDayButton(
                                    days: 21,
                                    isSelected: true,
                                    accentColor: viewModel.selectedTheme.accent
                                ) {
                                    if !premiumManager.isPremium {
                                        premiumAlertMessage = L10n.t("premium.goalDaysLocked")
                                        showingPremiumAlert = true
                                    }
                                }
                                
                                Text(L10n.t("premium.goalDaysLocked"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
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
                    
                    // Daily Repetitions Section (Premium)
                    DailyRepetitionSettingsView(
                        dailyRepetitions: $viewModel.dailyRepetitions,
                        repetitionLabels: $viewModel.repetitionLabels
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(Color(.systemBackground))
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
                        do {
                            try await premiumManager.purchasePremium()
                        } catch {
                            showingError = true
                            currentError = error as? AppError ?? PremiumError.unknown
                        }
                    }
                }
            } message: {
                Text(premiumAlertMessage.isEmpty ? L10n.t("premium.featureMessage") : premiumAlertMessage)
            }
            .errorAlert(error: $currentError)
            .loadingOverlay(isLoading: premiumManager.isLoading || habitStore.isLoading, message: premiumManager.isLoading ? L10n.t("premium.purchasing") : nil)
            .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(L10n.t("premium.purchase.success.message"))
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
            viewModel.reset()
            dismiss()
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
                
                Text(theme.localizedName)
                    .font(.caption)
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
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(isSelected ? category.color : .secondary)
                        .opacity(isLocked ? 0.5 : 1.0)
                    
                    // Lock icon overlay
                    if isLocked && !isSelected {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
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
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
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
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(L10n.t("habit.days"))
                    .font(.system(size: 11, weight: .medium))
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
