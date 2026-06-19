//
//  PremiumManager.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import Foundation
import StoreKit
import SwiftUI

// MARK: - Purchase Service Protocol (Testability)

@MainActor
protocol PurchaseServiceProtocol: ObservableObject {
    var isPremium: Bool { get }
    var isLoading: Bool { get }
    var isProductLoading: Bool { get }
    var errorMessage: String? { get }
    var showingPurchaseSuccess: Bool { get set }
    var showingPendingMessage: Bool { get set }
    var showingRestoreSuccess: Bool { get set }
    var products: [Product] { get }
    var productLoadFailed: Bool { get }
    var subscriptionStatus: SubscriptionDisplayStatus { get }
    
    func loadProducts() async
    func purchase(_ product: Product) async
    func restorePurchases() async
    func checkPremiumStatus() async
}

// MARK: - Subscription Display Status

enum SubscriptionDisplayStatus: Equatable {
    case none
    case lifetime
    case subscribed(expiresDate: Date?, productID: String)
    case expired
}

// MARK: - Premium Plan

enum PremiumPlan: String, CaseIterable, Identifiable {
    case monthly = "com.zorbeyteam.arium.premium.monthly"
    case yearly = "com.zorbeyteam.arium.premium.yearly"
    case lifetime = "com.zorbeyteam.arium.premium"
    
    var id: String { rawValue }
    
    var sortOrder: Int {
        switch self {
        case .monthly: return 0
        case .yearly: return 1
        case .lifetime: return 2
        }
    }
}

// MARK: - Premium Manager

@MainActor
class PremiumManager: ObservableObject, PurchaseServiceProtocol {
    static let shared = PremiumManager()
    
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var isProductLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingPurchaseSuccess: Bool = false
    @Published var showingPendingMessage: Bool = false
    @Published var showingRestoreSuccess: Bool = false
    @Published var productLoadFailed: Bool = false
    @Published var showingPaywall: Bool = false
    @Published var subscriptionStatus: SubscriptionDisplayStatus = .none
    
    // Tüm ürünler (monthly, yearly, lifetime)
    @Published var products: [Product] = []
    
    // Backward compatibility — ilk ürünü döndür
    var product: Product? { products.first }
    
    // Product ID'ler
    private let allProductIDs: Set<String> = [
        PremiumPlan.monthly.rawValue,
        PremiumPlan.yearly.rawValue,
        PremiumPlan.lifetime.rawValue
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        loadPremiumStatus()
        updateListenerTask = listenForTransactions()
        
        Task {
            await checkPremiumStatus()
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Ürün Erişimi
    
    /// Belirli bir plan için ürünü döndürür
    func product(for plan: PremiumPlan) -> Product? {
        products.first { $0.id == plan.rawValue }
    }
    
    /// Ürünleri sıralı döndürür (monthly, yearly, lifetime)
    var sortedProducts: [Product] {
        products.sorted { p1, p2 in
            let order1 = PremiumPlan(rawValue: p1.id)?.sortOrder ?? 99
            let order2 = PremiumPlan(rawValue: p2.id)?.sortOrder ?? 99
            return order1 < order2
        }
    }
    
    // MARK: - Premium Durumu
    
    private func loadPremiumStatus() {
        // Cached entitlement state for instant UI before the async StoreKit
        // reconciliation in `checkPremiumStatus()` runs. The cache is written
        // only from verified transactions (or, in DEBUG, the test toggle).
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
    
    private func savePremiumStatus(_ status: Bool) {
        isPremium = status
        UserDefaults.standard.set(status, forKey: "isPremium")
    }
    
    // MARK: - Test Helper

    #if DEBUG
    /// DEBUG-only entitlement override used by the in-app debug toggle and
    /// unit tests. Compiled out of Release builds entirely so there is no way
    /// to unlock Premium without a verified StoreKit transaction in the
    /// shipping app (App Store Guideline 3.1.2).
    func setPremiumStatus(_ status: Bool) {
        UserDefaults.standard.set(true, forKey: "isTestPremium")
        savePremiumStatus(status)
    }
    #endif
    
    // MARK: - Ürün Yükleme
    
    func loadProducts() async {
        isProductLoading = true
        productLoadFailed = false
        
        defer { isProductLoading = false }
        
        do {
            let loadedProducts = try await Product.products(for: allProductIDs)
            
            if !loadedProducts.isEmpty {
                self.products = loadedProducts
                
                #if DEBUG
                print("✅ \(loadedProducts.count) ürün yüklendi:")
                for p in loadedProducts {
                    print("   📋 \(p.id): \(p.displayName) — \(p.displayPrice)")
                }
                #endif
            } else {
                productLoadFailed = true
                #if DEBUG
                print("⚠️ Hiçbir ürün bulunamadı")
                #endif
            }
        } catch {
            productLoadFailed = true
            #if DEBUG
            print("❌ Ürün yüklenemedi: \(error)")
            #endif
        }
    }
    
    // Backward compatibility
    func loadProduct() async {
        await loadProducts()
    }
    
    // MARK: - Entitlement Kontrolü
    
    func checkPremiumStatus() async {
        #if DEBUG
        // DEBUG-only override (see `setPremiumStatus`). Compiled out of Release.
        if UserDefaults.standard.bool(forKey: "isTestPremium") &&
           UserDefaults.standard.bool(forKey: "isPremium") {
            isPremium = true
            return
        }
        #endif
        
        var foundEntitlement = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if allProductIDs.contains(transaction.productID) {
                    // Refund edilmiş transaction'ları atla
                    if transaction.revocationDate != nil { continue }
                    
                    savePremiumStatus(true)
                    foundEntitlement = true
                    
                    // Subscription durumunu belirle
                    if transaction.productID == PremiumPlan.lifetime.rawValue {
                        subscriptionStatus = .lifetime
                    } else {
                        subscriptionStatus = .subscribed(
                            expiresDate: transaction.expirationDate,
                            productID: transaction.productID
                        )
                    }
                    break
                }
            }
        }
        
        if !foundEntitlement {
            savePremiumStatus(false)
            subscriptionStatus = .none
        }
    }
    
    // MARK: - Satın Alma
    
    /// Belirli bir ürünü satın al
    func purchase(_ product: Product) async {
        // Lifetime guard: zaten lifetime varsa subscription satın almayı engelle
        if hasLifetime && product.id != PremiumPlan.lifetime.rawValue {
            errorMessage = L10n.t("paywall.alreadyLifetime")
            return
        }
        
        let plan = PremiumPlan(rawValue: product.id)
        if let plan = plan { analyticsPurchaseStarted(plan: plan) }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                savePremiumStatus(true)
                showingPurchaseSuccess = true
                
                // Subscription durumunu güncelle
                if transaction.productID == PremiumPlan.lifetime.rawValue {
                    subscriptionStatus = .lifetime
                } else {
                    subscriptionStatus = .subscribed(
                        expiresDate: transaction.expirationDate,
                        productID: transaction.productID
                    )
                }
                
                await transaction.finish()
                HapticManager.success()
                if let plan = plan { analyticsPurchaseCompleted(plan: plan) }
                
            case .userCancelled:
                break
                
            case .pending:
                showingPendingMessage = true
                
            @unknown default:
                errorMessage = L10n.t("premium.error.unknown")
            }
        } catch let error as StoreKitError {
            errorMessage = storeKitErrorMessage(for: error)
        } catch let error as PremiumError {
            errorMessage = error.errorMessage
        } catch {
            errorMessage = L10n.t("premium.error.unknown")
            #if DEBUG
            print("❌ Satın alma hatası: \(error)")
            #endif
        }
    }
    
    /// Backward compatibility — ilk ürünü satın al
    func purchasePremium() async {
        if products.isEmpty {
            for attempt in 1...3 {
                await loadProducts()
                if !products.isEmpty { break }
                if attempt < 3 {
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                }
            }
        }
        
        guard let product = products.first else {
            errorMessage = L10n.t("premium.error.productNotFound")
            return
        }
        
        await purchase(product)
    }
    
    // MARK: - Dinamik Savings Hesaplama
    
    /// Yıllık planın aylığa göre tasarruf yüzdesi
    var yearlySavingsPercent: Int? {
        guard let monthly = product(for: .monthly),
              let yearly = product(for: .yearly) else { return nil }
        let monthlyAnnual = monthly.price * 12
        guard monthlyAnnual > 0 else { return nil }
        let savings = (monthlyAnnual - yearly.price) / monthlyAnnual * 100
        return max(0, Int(truncating: savings as NSDecimalNumber))
    }
    
    // MARK: - Introductory Offer Detection
    
    /// Returns the introductory offer for a product if the user is eligible.
    /// This drives the "7-day free trial" copy on the paywall — but only when
    /// StoreKit confirms the user actually qualifies (Apple gates trials per
    /// subscription group, not per product, so a user who already trialled
    /// monthly cannot trial yearly again).
    func eligibleIntroductoryOffer(for plan: PremiumPlan) async -> Product.SubscriptionOffer? {
        guard let product = product(for: plan),
              let subscription = product.subscription,
              let offer = subscription.introductoryOffer else {
            return nil
        }
        
        let isEligible = await subscription.isEligibleForIntroOffer
        return isEligible ? offer : nil
    }
    
    /// Convenience: number of free-trial days for a plan if the user is
    /// eligible. Nil otherwise. Used by the paywall to render localized copy.
    func freeTrialDays(for plan: PremiumPlan) async -> Int? {
        guard let offer = await eligibleIntroductoryOffer(for: plan),
              offer.paymentMode == .freeTrial else {
            return nil
        }
        return daysInPeriod(offer.period)
    }
    
    private func daysInPeriod(_ period: Product.SubscriptionPeriod) -> Int {
        switch period.unit {
        case .day: return period.value
        case .week: return period.value * 7
        case .month: return period.value * 30
        case .year: return period.value * 365
        @unknown default: return period.value
        }
    }
    
    // MARK: - Subscription Management
    
    /// Opens Apple's native subscription management
    func showManageSubscriptions() async {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        do {
            try await AppStore.showManageSubscriptions(in: windowScene)
        } catch {
            #if DEBUG
            print("❌ Manage subscriptions failed: \(error)")
            #endif
        }
    }
    
    /// Formatted subscription status for display in Settings
    var subscriptionStatusText: String {
        switch subscriptionStatus {
        case .none:
            return L10n.t("settings.freePlan")
        case .lifetime:
            return L10n.t("paywall.status.lifetime")
        case .subscribed(let expiresDate, let productID):
            let planName = PremiumPlan(rawValue: productID) == .yearly
                ? L10n.t("paywall.plan.yearly")
                : L10n.t("paywall.plan.monthly")
            if let date = expiresDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.locale = Locale(identifier: L10n.currentLanguage)
                return String(format: L10n.t("paywall.status.active"), planName, formatter.string(from: date))
            }
            return planName
        case .expired:
            return L10n.t("paywall.status.expired")
        }
    }
    
    // MARK: - Edge Case: Lifetime + Subscription Guard
    
    /// Returns true if user already has lifetime — prevents double purchase
    var hasLifetime: Bool {
        subscriptionStatus == .lifetime
    }
    
    // MARK: - Analytics Stubs
    
    func analyticsPaywallShown(trigger: String) {
        // TODO: Wire to analytics provider
    }
    
    func analyticsPlanSelected(plan: PremiumPlan) {
        // TODO: Wire to analytics provider
    }
    
    func analyticsPurchaseStarted(plan: PremiumPlan) {
        // TODO: Wire to analytics provider
    }
    
    func analyticsPurchaseCompleted(plan: PremiumPlan) {
        // TODO: Wire to analytics provider
    }
    
    func analyticsPurchaseFailed(plan: PremiumPlan, error: Error) {
        // TODO: Wire to analytics provider
    }
    
    func analyticsPaywallDismissed(action: String) {
        // TODO: Wire to analytics provider
    }
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await checkPremiumStatus()
            
            if isPremium {
                showingRestoreSuccess = true
                HapticManager.success()
            } else {
                errorMessage = L10n.t("premium.error.noSubscription")
            }
        } catch {
            errorMessage = L10n.t("premium.restore.failed")
            #if DEBUG
            print("❌ Geri yükleme hatası: \(error)")
            #endif
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    
                    if self.allProductIDs.contains(transaction.productID) {
                        if transaction.revocationDate != nil {
                            // Refund edilmiş — premium'u kapat
                            await MainActor.run {
                                self.savePremiumStatus(false)
                                self.subscriptionStatus = .none
                            }
                        } else {
                            await MainActor.run {
                                self.savePremiumStatus(true)
                            }
                        }
                    }
                    
                    await transaction.finish()
                } catch {
                    #if DEBUG
                    print("❌ Transaction doğrulama hatası: \(error)")
                    #endif
                }
            }
        }
    }
    
    // MARK: - Yardımcılar
    
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PremiumError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
    
    private func storeKitErrorMessage(for error: StoreKitError) -> String {
        switch error {
        case .networkError:
            return L10n.t("premium.error.network")
        case .systemError:
            return L10n.t("premium.error.system")
        case .notAvailableInStorefront:
            return L10n.t("premium.error.notAvailable")
        case .notEntitled:
            return L10n.t("premium.error.notEntitled")
        default:
            return L10n.t("premium.error.unknown")
        }
    }
}

// MARK: - Premium Hataları

enum PremiumError: AppError {
    case productNotFound
    case userCancelled
    case pending
    case unknown
    case unverifiedTransaction
    case noActiveSubscription
    
    var errorTitle: String {
        return L10n.t("premium.title")
    }
    
    var errorMessage: String {
        switch self {
        case .productNotFound:
            return L10n.t("premium.error.productNotFound")
        case .userCancelled:
            return L10n.t("premium.error.userCancelled")
        case .pending:
            return L10n.t("premium.error.pending")
        case .unknown:
            return L10n.t("premium.error.unknown")
        case .unverifiedTransaction:
            return L10n.t("premium.error.unverified")
        case .noActiveSubscription:
            return L10n.t("premium.error.noSubscription")
        }
    }
    
    var errorDescription: String? {
        return errorMessage
    }
}
