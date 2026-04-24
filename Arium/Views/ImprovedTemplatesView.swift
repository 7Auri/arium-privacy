//
//  ImprovedTemplatesView.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import SwiftUI

struct ImprovedTemplatesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    @ObservedObject var viewModel: AddHabitViewModel
    @StateObject private var premiumManager = PremiumManager.shared
    
    @State private var searchText = ""
    @State private var selectedCategory: HabitCategory? = nil
    @State private var showOnlyFree = false
    @State private var showOnlyPopular = false
    @State private var showOnlyPremium = false
    @State private var showingPremiumAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filters
                filterSection
                
                // Templates Grid
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16, pinnedViews: []) {
                            // Popular section (Featured)
                            // Only show if NO filters are active (default view)
                            if !showOnlyFree && !showOnlyPopular && !showOnlyPremium && selectedCategory == nil && searchText.isEmpty {
                                popularSection
                            }
                            
                            // All templates section
                            allTemplatesSection
                        }
                        .padding()
                    }
                    .onChange(of: selectedCategory) { oldCategory, newCategory in
                        if let category = newCategory {
                            withAnimation {
                                proxy.scrollTo("category-\(category.rawValue)", anchor: .top)
                            }
                        }
                    }
                }
            }
            .navigationTitle(L10n.t("habit.templates.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                    .foregroundColor(AriumTheme.accent)
                }
            }
            .alert(L10n.t("premium.title"), isPresented: $showingPremiumAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("premium.restore.button")) {
                    Task { await premiumManager.restorePurchases() }
                }
                Button(L10n.t("premium.button")) {
                    Task { await premiumManager.purchasePremium() }
                }
            } message: {
                Text(L10n.t("premium.templates.message"))
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(L10n.t("template.search.placeholder"), text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Filters
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All filter
                TemplateFilterChip(
                    title: L10n.t("template.filter.all"),
                    isSelected: selectedCategory == nil && !showOnlyPopular && !showOnlyPremium && !showOnlyFree
                ) {
                    withAnimation {
                        selectedCategory = nil
                        showOnlyPopular = false
                        showOnlyPremium = false
                        showOnlyFree = false
                    }
                }
                
                // Popular filter
                TemplateFilterChip(
                    icon: "star.fill",
                    title: L10n.t("template.filter.popular"),
                    color: .orange,
                    isSelected: showOnlyPopular
                ) {
                    showOnlyPopular.toggle()
                    if showOnlyPopular {
                        showOnlyFree = false
                        showOnlyPremium = false
                        selectedCategory = nil
                    }
                }
                
                // Premium filter
                TemplateFilterChip(
                    icon: "crown.fill",
                    title: L10n.t("template.filter.premium"),
                    color: AriumTheme.warning,
                    isSelected: showOnlyPremium
                ) {
                    showOnlyPremium.toggle()
                    if showOnlyPremium {
                        showOnlyFree = false
                        showOnlyPopular = false
                        selectedCategory = nil
                    }
                }
                
                // Category filters
                ForEach([HabitCategory.health, .personal, .learning, .work, .finance, .social], id: \.self) { category in
                    TemplateFilterChip(
                        icon: nil,
                        emoji: category.icon,
                        title: L10n.t("category.\(category.rawValue)"),
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                            showOnlyPopular = false
                            showOnlyFree = false
                            showOnlyPremium = false
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Popular Section
    
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text(L10n.t("template.section.popular"))
                    .applyAppFont(size: 17, weight: .semibold)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                 // Always show popular templates here, unfiltered (except by premium status if user is free, handled in computed prop)
                ForEach(popularTemplatesFiltered) { template in
                    TemplateCardCompact(template: template) {
                        selectTemplate(template)
                    }
                }
            }
        }
    }
    
    // MARK: - All Templates Section
    
    private var allTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(sectionTitle)
                    .applyAppFont(size: 17, weight: .semibold)
                Spacer()
                Text(String(format: L10n.t("template.count"), filteredTemplates.count))
                    .applyAppFont(size: 12)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(filteredTemplates) { template in
                    TemplateCardCompact(template: template) {
                        selectTemplate(template)
                    }
                }
            }
        }
        .id(selectedCategory != nil ? "category-\(selectedCategory!.rawValue)" : "all-templates")
    }
    
    // MARK: - Computed Properties
    
    private var filteredTemplates: [HabitTemplate] {
        var templates = HabitTemplate.templates
        
        // Apply search filter
        if !searchText.isEmpty {
            templates = templates.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            templates = templates.filter { $0.category == category }
        }
        
        // Apply free filter
        if showOnlyFree {
            templates = templates.filter { !$0.isPremium }
        }
        
        // Apply premium filter
        if showOnlyPremium {
            templates = templates.filter { $0.isPremium }
        }
        
        // Apply popular filter
        if showOnlyPopular {
            templates = templates.filter { $0.isPopular }
        }
        
        // If NO filters are set (default view), exclude popular templates from this list
        // because they are already shown in the "popularSection" above.
        // We check the exact same condition used to show popularSection
        let isDefaultView = !showOnlyFree && !showOnlyPopular && !showOnlyPremium && selectedCategory == nil && searchText.isEmpty
        
        if isDefaultView {
             // Exclude templates that are in the popular section
             // Note: popularTemplatesFiltered handles the 'hide premium from popular if user is free' logic
             // But simpler: just exclude any template marked as isPopular?
             // Or better: exclude exactly the IDs shown above.
             // Let's just exclude isPopular == true to be safe and consistent.
             templates = templates.filter { !$0.isPopular }
        }
        
        return templates
    }
    
    private var sectionTitle: String {
        if let category = selectedCategory {
            return L10n.t("category.\(category.rawValue)") + " " + L10n.t("template.section.all")
        } else if showOnlyPopular {
            return L10n.t("template.section.popular")
        } else if showOnlyFree {
            return L10n.t("template.filter.free") + " " + L10n.t("template.section.all")
        } else {
            return L10n.t("template.section.all")
        }
    }
    
    private var popularTemplatesFiltered: [HabitTemplate] {
        if premiumManager.isPremium {
            return HabitTemplate.popularTemplates
        } else {
            return HabitTemplate.popularTemplates.filter { !$0.isPremium }
        }
    }
    
    // MARK: - Actions
    
    private func selectTemplate(_ template: HabitTemplate) {
        // Prevent free users from selecting premium templates
        if template.isPremium && !premiumManager.isPremium {
            // Show premium upgrade alert
            showingPremiumAlert = true
            HapticManager.warning()
            return
        }
        
        viewModel.title = template.title
        viewModel.notes = template.description
        viewModel.selectedCategory = template.category
        viewModel.goalDays = template.suggestedGoalDays
        HapticManager.success()
        dismiss()
    }
}

// MARK: - Template Filter Chip

struct TemplateFilterChip: View {
    let icon: String?
    var emoji: String? = nil
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    init(icon: String? = nil, emoji: String? = nil, title: String, color: Color = AriumTheme.accent, isSelected: Bool, action: @escaping () -> Void) {
        self.icon = icon
        self.emoji = emoji
        self.title = title
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let emoji = emoji {
                    Text(emoji)
                        .applyAppFont(size: 17)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .applyAppFont(size: 12, weight: .bold)
                }
                
                Text(title)
                    .applyAppFont(size: 12, weight: .bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? 
                    color :
                    Color(.systemGray6)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Template Card Compact

struct TemplateCardCompact: View {
    let template: HabitTemplate
    let action: () -> Void
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: template.icon)
                        .applyAppFont(size: 22, weight: .bold)
                        .foregroundColor(categoryColor)
                    
                    Spacer()
                    
                    if template.isPremium {
                        Image(systemName: "crown.fill")
                            .applyAppFont(size: 12)
                            .foregroundColor(.orange)
                    }
                    
                    if template.isPopular {
                        Image(systemName: "star.fill")
                            .applyAppFont(size: 12)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(template.title)
                    .applyAppFont(size: 15, weight: .bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text(template.description)
                    .applyAppFont(size: 12)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "target")
                        .applyAppFont(size: 11)
                    Text("\(template.suggestedGoalDays) \(L10n.t("habit.days"))")
                        .applyAppFont(size: 11)
                    Spacer()
                    Text(template.category.displayName)
                        .applyAppFont(size: 11)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(categoryColor.opacity(0.2))
                        .foregroundColor(categoryColor)
                        .cornerRadius(4)
                }
                .foregroundColor(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(categoryColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var categoryColor: Color {
        switch template.category {
        case .health: return .green
        case .personal: return .pink
        case .learning: return .purple
        case .work: return .blue
        case .finance: return .orange
        case .social: return .indigo
        }
    }
}

