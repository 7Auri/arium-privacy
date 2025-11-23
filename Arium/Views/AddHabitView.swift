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
    @State private var showingTemplates = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Templates Button
                    Button(action: {
                        showingTemplates = true
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text(L10n.t("habit.templates.use"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showingTemplates) {
                        HabitTemplatesView(viewModel: viewModel)
                    }
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("habit.title"))
                            .font(.footnote)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        
                        TextField(L10n.t("habit.title"), text: $viewModel.title)
                            .textFieldStyle(ModernTextFieldStyle())
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
                    }
                    
                    // Category Selector (Premium)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.t("habit.category"))
                                .font(.footnote)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                            
                            if !habitStore.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if habitStore.isPremium {
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
                                        showingPremiumAlert = true
                                    }
                                    
                                    // Diğer kategoriler kilitli olarak göster
                                    ForEach(HabitCategory.allCases.filter { $0 != .personal }) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: false,
                                            isLocked: true
                                        ) {
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
                                
                                if !habitStore.isPremium {
                                    Image(systemName: "crown.fill")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                if habitStore.isPremium {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.showingDatePicker.toggle()
                                    }
                                } else {
                                    showingPremiumAlert = true
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(viewModel.startDate.localizedDateString())
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    
                                    Image(systemName: habitStore.isPremium ? "calendar" : "lock.fill")
                                        .font(.caption)
                                        .foregroundColor(viewModel.selectedTheme.accent)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                            }
                        }
                        
                        if habitStore.isPremium && viewModel.showingDatePicker {
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
                    .opacity(habitStore.isPremium ? 1.0 : 0.7)
                    
                    // Goal Days Selector (Premium)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text(L10n.t("habit.goalDays"))
                                .font(.footnote)
                                .textCase(.uppercase)
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
                                    ForEach(viewModel.goalOptions, id: \.self) { days in
                                        GoalDayButton(
                                            days: days,
                                            isSelected: viewModel.goalDays == days,
                                            accentColor: viewModel.selectedTheme.accent
                                        ) {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                                viewModel.goalDays = days
                                            }
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
                                    showingPremiumAlert = true
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
                    .opacity(habitStore.isPremium ? 1.0 : 0.7)
                    
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
                    // Premium upgrade action
                }
            } message: {
                Text(L10n.t("premium.featureMessage"))
            }
            .onAppear {
                // Free kullanıcılar için kategoriyi Personal olarak sabitle
                if !habitStore.isPremium {
                    viewModel.selectedCategory = .personal
                }
            }
        }
    }
    
    private func saveHabit() {
        HapticManager.success()
        let habit = viewModel.createHabit()
        habitStore.addHabit(habit)
        viewModel.reset()
        dismiss()
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
            VStack(spacing: 6) {
                Text("\(days)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(isSelected ? accentColor : .primary)
                
                Text(L10n.t("habit.days"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 70, height: 70)
            .background(
                isSelected 
                ? accentColor.opacity(0.1) 
                : Color(.tertiarySystemBackground)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? accentColor : Color(.separator),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? accentColor.opacity(0.2) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddHabitView()
        .environmentObject(HabitStore())
}
