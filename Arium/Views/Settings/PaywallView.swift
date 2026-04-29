//
//  PaywallView.swift
//  Arium
//
//  Full-screen paywall with monthly, yearly, and lifetime options.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var appThemeManager = AppThemeManager.shared
    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Plans
                    if premiumManager.isProductLoading {
                        ProgressView()
                            .tint(appThemeManager.accentColor.color)
                            .padding(.vertical, 20)
                    } else if premiumManager.products.isEmpty {
                        Text(L10n.t("premium.error.loadFailed"))
                            .applyAppFont(size: 14)
                            .foregroundStyle(.secondary)
                            .padding()
                            .onTapGesture {
                                Task { await premiumManager.loadProducts() }
                            }
                    } else {
                        plansSection
                    }
                    
                    // Purchase Button
                    purchaseButton
                    
                    // Restore + Legal
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
            .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                Button(L10n.t("button.ok")) { dismiss() }
            } message: {
                Text(L10n.t("premium.purchase.success.message"))
            }
            .alert(L10n.t("premium.pending.title"), isPresented: $premiumManager.showingPendingMessage) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(L10n.t("premium.pending.message"))
            }
            .alert(L10n.t("premium.restore.success"), isPresented: $premiumManager.showingRestoreSuccess) {
                Button(L10n.t("button.ok")) { dismiss() }
            }
            .alert(L10n.t("premium.title"), isPresented: Binding(
                get: { premiumManager.errorMessage != nil },
                set: { if !$0 { premiumManager.errorMessage = nil } }
            )) {
                Button(L10n.t("button.ok")) { premiumManager.errorMessage = nil }
            } message: {
                if let msg = premiumManager.errorMessage {
                    Text(msg)
                }
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
                    .environmentObject(appThemeManager)
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
                    .environmentObject(appThemeManager)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 20)
            
            Text(L10n.t("paywall.title"))
                .applyAppFont(size: 28, weight: .bold)
                .multilineTextAlignment(.center)
            
            Text(L10n.t("paywall.subtitle"))
                .applyAppFont(size: 16)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(icon: "infinity", text: L10n.t("paywall.feature.unlimited"))
            featureRow(icon: "brain.head.profile", text: L10n.t("paywall.feature.ai"))
            featureRow(icon: "paintbrush.fill", text: L10n.t("paywall.feature.themes"))
            featureRow(icon: "repeat", text: L10n.t("paywall.feature.repetitions"))
            featureRow(icon: "doc.text.fill", text: L10n.t("paywall.feature.templates"))
            featureRow(icon: "chart.bar.fill", text: L10n.t("paywall.feature.stats"))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 28)
            
            Text(text)
                .applyAppFont(size: 15)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.green)
        }
    }
    
    // MARK: - Plans
    
    private var plansSection: some View {
        VStack(spacing: 10) {
            ForEach(premiumManager.sortedProducts, id: \.id) { product in
                let plan = PremiumPlan(rawValue: product.id)
                planCard(product: product, plan: plan, isSelected: selectedPlan == plan)
                    .onTapGesture {
                        if let plan = plan {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlan = plan
                            }
                            HapticManager.selection()
                        }
                    }
            }
        }
    }
    
    private func planCard(product: Product, plan: PremiumPlan?, isSelected: Bool) -> some View {
        HStack(spacing: 14) {
            // Radio button
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 14, height: 14)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(planDisplayName(plan))
                        .applyAppFont(size: 16, weight: .semibold)
                    
                    if plan == .yearly {
                        Text(L10n.t("paywall.bestValue"))
                            .applyAppFont(size: 11, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                    
                    if plan == .lifetime {
                        Text(L10n.t("paywall.oneTime"))
                            .applyAppFont(size: 11, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.purple)
                            .clipShape(Capsule())
                    }
                }
                
                Text(planSubtitle(product, plan: plan))
                    .applyAppFont(size: 13)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(product.displayPrice)
                .applyAppFont(size: 18, weight: .bold)
                .foregroundStyle(isSelected ? .orange : .primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                )
        )
    }
    
    private func planDisplayName(_ plan: PremiumPlan?) -> String {
        switch plan {
        case .monthly: return L10n.t("paywall.plan.monthly")
        case .yearly: return L10n.t("paywall.plan.yearly")
        case .lifetime: return L10n.t("paywall.plan.lifetime")
        case .none: return ""
        }
    }
    
    private func planSubtitle(_ product: Product, plan: PremiumPlan?) -> String {
        switch plan {
        case .monthly: return L10n.t("paywall.plan.monthly.subtitle")
        case .yearly: return L10n.t("paywall.plan.yearly.subtitle")
        case .lifetime: return L10n.t("paywall.plan.lifetime.subtitle")
        case .none: return ""
        }
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        Button {
            guard let product = premiumManager.product(for: selectedPlan) else { return }
            Task {
                await premiumManager.purchase(product)
            }
        } label: {
            Group {
                if premiumManager.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(L10n.t("paywall.subscribe"))
                        .applyAppFont(size: 17, weight: .bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.orange, .orange.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(premiumManager.isLoading || premiumManager.products.isEmpty)
    }
    
    // MARK: - Footer
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            // Restore
            Button {
                Task { await premiumManager.restorePurchases() }
            } label: {
                Text(L10n.t("premium.restore.button"))
                    .applyAppFont(size: 14, weight: .medium)
                    .foregroundStyle(appThemeManager.accentColor.color)
            }
            
            // Auto-renew disclaimer
            if selectedPlan != .lifetime {
                Text(L10n.t("paywall.autoRenew"))
                    .applyAppFont(size: 11)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Legal links
            HStack(spacing: 16) {
                Button {
                    showingTermsOfService = true
                } label: {
                    Text(L10n.t("settings.termsOfService"))
                        .applyAppFont(size: 12)
                        .foregroundStyle(.secondary)
                }
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Button {
                    showingPrivacyPolicy = true
                } label: {
                    Text(L10n.t("settings.privacyPolicy"))
                        .applyAppFont(size: 12)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}
