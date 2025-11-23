//
//  HabitTemplatesView.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import SwiftUI

struct HabitTemplatesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    @ObservedObject var viewModel: AddHabitViewModel
    @StateObject private var premiumManager = PremiumManager.shared
    @State private var showingPremiumAlert = false
    @State private var showingError = false
    @State private var currentError: AppError?
    
    var body: some View {
        NavigationStack {
            if premiumManager.isPremium {
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
            } else {
                // Premium Locked View
                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text(L10n.t("premium.title"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(L10n.t("premium.templates.message"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        showingPremiumAlert = true
                    } label: {
                        Text(L10n.t("premium.button"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AriumTheme.accent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .navigationTitle(L10n.t("habit.templates.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L10n.t("button.cancel")) {
                            dismiss()
                        }
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
                    Text(L10n.t("premium.message"))
                }
                .errorAlert(error: $currentError)
                .loadingOverlay(isLoading: premiumManager.isLoading, message: premiumManager.isLoading ? L10n.t("premium.purchasing") : nil)
                .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                    Button(L10n.t("button.ok")) { }
                } message: {
                    Text(L10n.t("premium.purchase.success.message"))
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

