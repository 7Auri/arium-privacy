//
//  CustomTemplateCreatorView.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import SwiftUI

struct CustomTemplateCreatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var premiumManager = PremiumManager.shared
    
    @State private var templateTitle = ""
    @State private var templateDescription = ""
    @State private var selectedCategory: HabitCategory = .personal
    @State private var goalDays = 21
    @State private var selectedIcon = "star.fill"
    @State private var showingIconPicker = false
    @State private var savedTemplates: [HabitTemplate] = []
    
    let goalOptions = [7, 14, 21, 30, 60, 90]
    
    var body: some View {
        NavigationStack {
            if premiumManager.isPremium {
                Form {
                    // Template Info
                    Section(L10n.t("customTemplate.details")) {
                        TextField(L10n.t("customTemplate.name"), text: $templateTitle)
                        TextField(L10n.t("customTemplate.description"), text: $templateDescription, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    
                    // Category Selection
                    Section(L10n.t("customTemplate.category")) {
                        Picker(L10n.t("customTemplate.category"), selection: $selectedCategory) {
                            ForEach([HabitCategory.health, .personal, .learning, .work, .finance, .social], id: \.self) { category in
                                HStack {
                                    Text(category.icon)
                                    Text(L10n.t("category.\(category.rawValue)"))
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Goal Days
                    Section(L10n.t("customTemplate.goal")) {
                        Picker(L10n.t("customTemplate.days"), selection: $goalDays) {
                            ForEach(goalOptions, id: \.self) { days in
                                Text("\(days) \(L10n.t("habit.days"))").tag(days)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Icon Selection
                    Section(L10n.t("customTemplate.icon")) {
                        Button(action: { showingIconPicker = true }) {
                            HStack {
                                Image(systemName: selectedIcon)
                                    .font(.title2)
                                    .foregroundColor(categoryColor)
                                    .frame(width: 40, height: 40)
                                    .background(categoryColor.opacity(0.2))
                                    .cornerRadius(8)
                                
                                Text(L10n.t("customTemplate.icon.choose"))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Preview
                    Section(L10n.t("customTemplate.preview")) {
                        TemplateCardCompact(
                            template: HabitTemplate(
                                id: UUID(),
                                title: templateTitle.isEmpty ? L10n.t("customTemplate.name.placeholder") : templateTitle,
                                description: templateDescription.isEmpty ? L10n.t("customTemplate.description.placeholder") : templateDescription,
                                category: selectedCategory,
                                suggestedGoalDays: goalDays,
                                icon: selectedIcon,
                                isPopular: false,
                                isPremium: true,
                                dailyRepetitions: 1,
                                repetitionLabels: nil
                            )
                        ) {}
                        .disabled(true)
                    }
                    
                    // Saved Templates
                    if !savedTemplates.isEmpty {
                        Section(L10n.t("customTemplate.myTemplates")) {
                            ForEach(savedTemplates) { template in
                                HStack {
                                    Image(systemName: template.icon)
                                        .foregroundColor(categoryColor)
                                    VStack(alignment: .leading) {
                                        Text(template.title)
                                            .font(.subheadline.bold())
                                        Text(template.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .onDelete(perform: deleteTemplate)
                        }
                    }
                }
                .navigationTitle(L10n.t("customTemplate.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(L10n.t("button.cancel")) {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L10n.t("customTemplate.save")) {
                            saveTemplate()
                        }
                        .disabled(!canSave)
                        .foregroundColor(canSave ? AriumTheme.accent : .secondary)
                    }
                }
                .sheet(isPresented: $showingIconPicker) {
                    IconPickerView(selectedIcon: $selectedIcon)
                }
                .onAppear {
                    loadSavedTemplates()
                }
            } else {
                // Premium required view
                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text(L10n.t("customTemplate.premium.feature"))
                        .font(.title.bold())
                    
                    Text(L10n.t("customTemplate.premium.message"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text(L10n.t("premium.upgrade.button"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AriumTheme.accent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .navigationTitle(L10n.t("customTemplate.premium.title"))
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canSave: Bool {
        !templateTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var categoryColor: Color {
        switch selectedCategory {
        case .health: return .green
        case .personal: return .pink
        case .learning: return .purple
        case .work: return .blue
        case .finance: return .orange
        case .social: return .indigo
        }
    }
    
    // MARK: - Actions
    
    private func saveTemplate() {
        let template = HabitTemplate(
            id: UUID(),
            title: templateTitle,
            description: templateDescription,
            category: selectedCategory,
            suggestedGoalDays: goalDays,
            icon: selectedIcon,
            isPopular: false,
            isPremium: true,
            dailyRepetitions: 1,
            repetitionLabels: nil
        )
        
        savedTemplates.append(template)
        saveToUserDefaults()
        
        // Reset form
        templateTitle = ""
        templateDescription = ""
        selectedCategory = .personal
        goalDays = 21
        selectedIcon = "star.fill"
        
        HapticManager.success()
    }
    
    private func deleteTemplate(at offsets: IndexSet) {
        savedTemplates.remove(atOffsets: offsets)
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? CodingCache.encoder.encode(savedTemplates) {
            UserDefaults.standard.set(encoded, forKey: "CustomTemplates")
        }
    }
    
    private func loadSavedTemplates() {
        if let data = UserDefaults.standard.data(forKey: "CustomTemplates"),
           let templates = try? CodingCache.decoder.decode([HabitTemplate].self, from: data) {
            savedTemplates = templates
        }
    }
}

// MARK: - Icon Picker

struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIcon: String
    
    let icons = [
        // Common
        "star.fill", "heart.fill", "flame.fill", "bolt.fill", "leaf.fill",
        // Health
        "figure.run", "figure.walk", "moon.fill", "drop.fill", "pills.fill",
        "figure.mind.and.body", "heart.circle.fill", "waveform.path.ecg",
        // Personal
        "brain.head.profile", "book.fill", "book.closed.fill", "sunrise.fill",
        "quote.bubble.fill", "sparkles", "hand.raised.fill",
        // Learning
        "graduationcap.fill", "globe", "headphones", "pencil", "lightbulb.fill",
        // Work
        "chevron.left.forwardslash.chevron.right", "briefcase.fill", "envelope.fill",
        "brain.fill", "person.2.fill", "chart.line.uptrend.xyaxis",
        // Finance
        "banknote.fill", "chart.pie.fill", "cart.fill", "creditcard.fill",
        // Social
        "phone.fill", "person.3.fill", "hand.thumbsup.fill", "message.fill",
        // Other
        "calendar", "clock.fill", "target", "checkmark.circle.fill"
    ]
    
    let columns = [GridItem(.adaptive(minimum: 70))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = icon
                            HapticManager.selection()
                            dismiss()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: icon)
                                    .font(.title)
                                    .foregroundColor(selectedIcon == icon ? AriumTheme.accent : .primary)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        selectedIcon == icon ?
                                        AriumTheme.accent.opacity(0.2) :
                                            Color(.systemGray6)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedIcon == icon ? AriumTheme.accent : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.t("iconPicker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("iconPicker.done")) {
                        dismiss()
                    }
                    .foregroundColor(AriumTheme.accent)
                }
            }
        }
    }
}

