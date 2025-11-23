//
//  HabitTemplatesView.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import SwiftUI

struct HabitTemplatesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AddHabitViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(HabitTemplate.templates) { template in
                        TemplateCard(template: template) {
                            viewModel.title = template.title
                            viewModel.notes = template.description
                            viewModel.selectedCategory = template.category
                            viewModel.goalDays = template.suggestedGoalDays
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.t("habit.templates.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("button.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TemplateCard: View {
    let template: HabitTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(template.category.color)
                
                VStack(spacing: 4) {
                    Text(template.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(template.suggestedGoalDays) \(L10n.t("habit.days"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

