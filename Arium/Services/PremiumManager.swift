//
//  PremiumManager.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingPurchaseSuccess: Bool = false
    
    // Product bilgileri (App Store Connect'ten otomatik alınır)
    @Published var product: Product?
    
    // StoreKit 2 Product ID
    // NOT: App Store Connect'te bu product ID'yi oluşturmanız gerekiyor
    private let premiumProductID = "com.zorbeyteam.arium.premium"
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Load saved premium status
        loadPremiumStatus()
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Check current subscription status and load product
        Task {
            await checkPremiumStatus()
            await loadProduct()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Premium Status
    
    private func loadPremiumStatus() {
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
    
    private func savePremiumStatus(_ status: Bool) {
        isPremium = status
        UserDefaults.standard.set(status, forKey: "isPremium")
    }
    
    // MARK: - Test Helper (TestFlight için - Canlıya geçerken kaldırılacak)
    
    /// TestFlight'ta premium test etmek için kullanılır
    /// Canlıya geçerken bu fonksiyon kaldırılmalı
    func setPremiumStatus(_ status: Bool) {
        savePremiumStatus(status)
    }
    
    // MARK: - StoreKit 2
    
    /// App Store Connect'ten ürün bilgilerini otomatik olarak yükler
    /// Fiyat, isim, açıklama gibi bilgileri Product objesinden alır
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [premiumProductID])
            
            await MainActor.run {
                self.product = products.first
                
                #if DEBUG
                if let product = self.product {
                    print("✅ Premium product loaded from App Store Connect:")
                    print("   📋 Display Name: \(product.displayName)")
                    print("   💰 Price: \(product.displayPrice)")
                    print("   📝 Description: \(product.description)")
                } else {
                    print("⚠️ Premium product not found in App Store Connect")
                }
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Failed to load product: \(error)")
            #endif
        }
    }
    
    func checkPremiumStatus() async {
        // Check if user has active subscription
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == premiumProductID {
                    await MainActor.run {
                        savePremiumStatus(true)
                    }
                    return
                }
            }
        }
        
        // No active subscription found
        await MainActor.run {
            savePremiumStatus(false)
        }
    }
    
    func purchasePremium() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // Load product (eğer yüklenmemişse)
            if product == nil {
                await loadProduct()
            }
            
            guard let product = product else {
                #if DEBUG
                print("❌ Premium product not found!")
                print("📋 Product ID being searched: \(premiumProductID)")
                print("📋 Product loaded: \(self.product != nil ? "Yes" : "No")")
                print("")
                print("🔍 CHECKLIST:")
                print("   1. App Store Connect → In-App Purchases")
                print("      → Product ID: \(premiumProductID) (tam olarak bu olmalı!)")
                print("   2. Product Status: 'Ready to Submit' veya 'Approved' olmalı")
                print("   3. Availability: 'All Countries' veya Türkiye seçili olmalı")
                print("   4. Display Name ve Description doldurulmuş olmalı")
                print("   5. TestFlight: 15-30 dakika bekle (sync için)")
                print("   6. Sandbox account ile giriş yapıldı mı?")
                print("")
                print("💡 Hızlı Test: Xcode → Edit Scheme → StoreKit Configuration → AriumStoreKit.storekit")
                #endif
                // Ürün bulunamazsa her zaman hata fırlat (debug olsun ya da olmasın)
                throw PremiumError.productNotFound
            }
            
            // Purchase product
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Update premium status
                await MainActor.run {
                    savePremiumStatus(true)
                    showingPurchaseSuccess = true
                }
                
                // Finish transaction
                await transaction.finish()
                
                HapticManager.success()
                
            case .userCancelled:
                throw PremiumError.userCancelled
                
            case .pending:
                throw PremiumError.pending
                
            @unknown default:
                throw PremiumError.unknown
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        try await AppStore.sync()
        await checkPremiumStatus()
        
        if !isPremium {
            throw PremiumError.noActiveSubscription
        }
        
        HapticManager.success()
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Update premium status if transaction is for premium product
                    if transaction.productID == self.premiumProductID {
                        await MainActor.run {
                            self.savePremiumStatus(true)
                        }
                    }
                    
                    // Finish transaction
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PremiumError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Premium Errors

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

