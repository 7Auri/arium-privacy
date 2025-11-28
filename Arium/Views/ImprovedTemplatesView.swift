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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filters
                filterSection
                
                // Templates Grid
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Popular section (if not filtered)
                        if !showOnlyFree && selectedCategory == nil && searchText.isEmpty {
                            popularSection
                        }
                        
                        // All templates section
                        allTemplatesSection
                    }
                    .padding()
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
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search templates...", text: $searchText)
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
                // Popular filter
                FilterChip(
                    title: "⭐ Popular",
                    isSelected: showOnlyPopular
                ) {
                    showOnlyPopular.toggle()
                    if showOnlyPopular {
                        showOnlyFree = false
                    }
                }
                
                // Free filter
                if !premiumManager.isPremium {
                    FilterChip(
                        title: "🆓 Free",
                        isSelected: showOnlyFree
                    ) {
                        showOnlyFree.toggle()
                        if showOnlyFree {
                            showOnlyPopular = false
                        }
                    }
                }
                
                // Category filters
                ForEach([HabitCategory.health, .personal, .learning, .work, .finance, .social], id: \.self) { category in
                    FilterChip(
                        title: category.icon + " " + L10n.t("category.\(category.rawValue)"),
                        isSelected: selectedCategory == category
                    ) {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                            showOnlyPopular = false
                            showOnlyFree = false
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
                Text("Popular Templates")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(HabitTemplate.popularTemplates) { template in
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
                    .font(.headline)
                Spacer()
                Text("\(filteredTemplates.count) templates")
                    .font(.caption)
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
        
        // Apply popular filter
        if showOnlyPopular {
            templates = templates.filter { $0.isPopular }
        }
        
        // Filter premium templates if not premium user
        if !premiumManager.isPremium {
            templates = templates.filter { !$0.isPremium }
        }
        
        return templates
    }
    
    private var sectionTitle: String {
        if let category = selectedCategory {
            return L10n.t("category.\(category.rawValue)") + " Templates"
        } else if showOnlyPopular {
            return "Popular Templates"
        } else if showOnlyFree {
            return "Free Templates"
        } else {
            return "All Templates"
        }
    }
    
    // MARK: - Actions
    
    private func selectTemplate(_ template: HabitTemplate) {
        viewModel.title = template.title
        viewModel.notes = template.description
        viewModel.selectedCategory = template.category
        viewModel.goalDays = template.suggestedGoalDays
        dismiss()
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AriumTheme.accent : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
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
                        .font(.title2)
                        .foregroundColor(categoryColor)
                    
                    Spacer()
                    
                    if template.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    if template.isPopular {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(template.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "target")
                        .font(.caption2)
                    Text("\(template.suggestedGoalDays) days")
                        .font(.caption2)
                    Spacer()
                    Text(template.category.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(categoryColor.opacity(0.2))
                        .foregroundColor(categoryColor)
                        .cornerRadius(4)
                }
                .foregroundColor(.secondary)
            }
            .padding(12)
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

