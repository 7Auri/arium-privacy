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
            ScrollView {
                VStack(spacing: 24) {
                    // Free Templates Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.t("templates.free"))
                            .applyAppFont(size: 20, weight: .bold)
                            .foregroundColor(AriumTheme.textPrimary)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(HabitTemplate.freeTemplates) { template in
                                TemplateCard(
                                    template: template,
                                    isPremiumUser: premiumManager.isPremium
                                ) {
                                    viewModel.title = template.title
                                    viewModel.notes = template.description
                                    viewModel.selectedCategory = template.category
                                    viewModel.goalDays = template.suggestedGoalDays
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Premium Templates Section
                    if premiumManager.isPremium {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(L10n.t("templates.premium"))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AriumTheme.textPrimary)
                                
                                Image(systemName: "crown.fill")
                                    .foregroundColor(AriumTheme.warning)
                                    .applyAppFont(size: 12)
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(HabitTemplate.premiumTemplates) { template in
                                    TemplateCard(
                                        template: template,
                                        isPremiumUser: premiumManager.isPremium
                                    ) {
                                        viewModel.title = template.title
                                        viewModel.notes = template.description
                                        viewModel.selectedCategory = template.category
                                        viewModel.goalDays = template.suggestedGoalDays
                                        dismiss()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Premium Upsell Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .applyAppFont(size: 22, weight: .semibold)
                                    .foregroundColor(AriumTheme.warning)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L10n.t("templates.premium.unlock"))
                                        .applyAppFont(size: 17, weight: .semibold)
                                        .foregroundColor(AriumTheme.textPrimary)
                                    
                                    Text(L10n.t("templates.premium.message"))
                                        .applyAppFont(size: 12)
                                        .foregroundColor(AriumTheme.textSecondary)
                                }
                                
                                Spacer()
                            }
                            
                            Button {
                                showingPremiumAlert = true
                            } label: {
                                Text(L10n.t("premium.button"))
                                    .applyAppFont(size: 17, weight: .semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AriumTheme.accent)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
            .alert(L10n.t("premium.title"), isPresented: $showingPremiumAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("premium.restore.button")) {
                    Task { await premiumManager.restorePurchases() }
                }
                Button(L10n.t("premium.button")) {
                    Task { await premiumManager.purchasePremium() }
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

struct TemplateCard: View {
    let template: HabitTemplate
    let isPremiumUser: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    Image(systemName: template.icon)
                        .applyAppFont(size: 32)
                        .foregroundStyle(template.category.color)
                        .frame(height: 32)
                    
                    VStack(spacing: 4) {
                        Text(template.title)
                            .applyAppFont(size: 17, weight: .semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text(template.description)
                            .applyAppFont(size: 12)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(minHeight: 32, maxHeight: 32)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .applyAppFont(size: 11)
                            .foregroundStyle(.orange)
                        Text("\(template.suggestedGoalDays) \(L10n.t("habit.days"))")
                            .applyAppFont(size: 12)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 160)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // Premium Badge (only show if template is premium and user is not premium)
                if template.isPremium && !isPremiumUser {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .applyAppFont(size: 11)
                        Text("PRO")
                            .applyAppFont(size: 11)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AriumTheme.warning)
                    .cornerRadius(8)
                    .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
