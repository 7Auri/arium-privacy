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
    @State private var trialDaysByPlan: [PremiumPlan: Int] = [:]
    
    var trigger: String = "generic"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    
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
                    
                    purchaseButton
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
                        premiumManager.analyticsPaywallDismissed(action: "close")
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                premiumManager.analyticsPaywallShown(trigger: trigger)
                Task { await refreshTrialEligibility() }
            }
            .onChange(of: premiumManager.products.map(\.id)) { _, _ in
                Task { await refreshTrialEligibility() }
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
        VStack(spacing: 14) {
            heroFeatureCard(
                icon: "sparkles",
                gradient: [.purple, .pink],
                titleKey: "paywall.hero.aiCreate.title",
                bodyKey: "paywall.hero.aiCreate.body"
            )
            heroFeatureCard(
                icon: "brain.head.profile",
                gradient: [.indigo, .purple],
                titleKey: "paywall.hero.ai.title",
                bodyKey: "paywall.hero.ai.body"
            )
            heroFeatureCard(
                icon: "chart.bar.xaxis",
                gradient: [.green, .mint],
                titleKey: "paywall.hero.stats.title",
                bodyKey: "paywall.hero.stats.body"
            )
            heroFeatureCard(
                icon: "infinity",
                gradient: [.orange, .red],
                titleKey: "paywall.hero.unlimited.title",
                bodyKey: "paywall.hero.unlimited.body"
            )
            
            // Secondary features as compact chips
            secondaryFeaturesChips
        }
    }
    
    private func heroFeatureCard(icon: String, gradient: [Color], titleKey: String, bodyKey: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.18) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.t(titleKey))
                    .applyAppFont(size: 16, weight: .semibold)
                    .foregroundStyle(.primary)
                Text(L10n.t(bodyKey))
                    .applyAppFont(size: 13)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    private var secondaryFeaturesChips: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.t("paywall.alsoIncluded"))
                .applyAppFont(size: 13, weight: .medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            FlexibleChipsView(items: [
                (icon: "icloud", textKey: "paywall.feature.sync"),
                (icon: "paintbrush.fill", textKey: "paywall.feature.themes"),
                (icon: "repeat", textKey: "paywall.feature.repetitions"),
                (icon: "doc.text.fill", textKey: "paywall.feature.templates"),
                (icon: "trophy.fill", textKey: "paywall.feature.achievements"),
                (icon: "leaf.fill", textKey: "paywall.feature.garden"),
                (icon: "square.and.arrow.up", textKey: "paywall.feature.export")
            ])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                            premiumManager.analyticsPlanSelected(plan: plan)
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
        case .yearly:
            if let trialDays = trialDaysByPlan[.yearly], trialDays > 0 {
                return String(format: L10n.t("paywall.plan.yearly.trial"), trialDays, product.displayPrice)
            }
            if let savings = premiumManager.yearlySavingsPercent, savings > 0 {
                return String(format: L10n.t("paywall.plan.yearly.savings"), savings)
            }
            return L10n.t("paywall.plan.yearly.subtitle")
        case .lifetime: return L10n.t("paywall.plan.lifetime.subtitle")
        case .none: return ""
        }
    }
    
    private func refreshTrialEligibility() async {
        var result: [PremiumPlan: Int] = [:]
        for plan in [PremiumPlan.monthly, .yearly] {
            if let days = await premiumManager.freeTrialDays(for: plan) {
                result[plan] = days
            }
        }
        trialDaysByPlan = result
    }
    
    /// CTA copy switches to "Start Free Trial" when the selected plan offers
    /// one and the user is eligible. Falls back to the generic "Continue".
    private var purchaseButtonTitle: String {
        if let trialDays = trialDaysByPlan[selectedPlan], trialDays > 0 {
            return String(format: L10n.t("paywall.startTrial"), trialDays)
        }
        return L10n.t("paywall.subscribe")
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
                    Text(purchaseButtonTitle)
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
            
            // Legal links (Guideline 3.1.2): functional EULA + Privacy Policy.
            // URLs come from the single-source `Legal` enum; labels are localized.
            HStack(spacing: 16) {
                Link(destination: Legal.eula) {
                    Text(L10n.t("settings.termsOfService"))
                        .applyAppFont(size: 12)
                        .foregroundStyle(.secondary)
                }
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Link(destination: Legal.privacyPolicy) {
                    Text(L10n.t("settings.privacyPolicy"))
                        .applyAppFont(size: 12)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Flexible Chips Layout
//
// SwiftUI'in built-in `FlowLayout` iOS 17 öncesi yok. 6+ chip'i zarif
// şekilde yerleştirmek için minimal bir wrap'lı layout. Her chip kendi
// genişliği kadar yer kaplar, satır sığmazsa alta taşar.
private struct FlexibleChipsView: View {
    let items: [(icon: String, textKey: String)]
    
    var body: some View {
        WrapHStack(spacing: 8, lineSpacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                HStack(spacing: 6) {
                    Image(systemName: item.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.orange)
                    Text(L10n.t(item.textKey))
                        .applyAppFont(size: 12, weight: .medium)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                )
            }
        }
    }
}

private struct WrapHStack: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += lineHeight + lineSpacing
                x = 0
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalWidth = max(totalWidth, min(x, maxWidth))
            totalHeight = y + lineHeight
        }
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += lineHeight + lineSpacing
                x = bounds.minX
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    PaywallView()
}
