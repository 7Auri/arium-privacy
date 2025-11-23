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
    
    // StoreKit 2 Product ID
    // NOT: App Store Connect'te bu product ID'yi oluşturmanız gerekiyor
    private let premiumProductID = "com.zorbeyteam.arium.premium"
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Load saved premium status
        loadPremiumStatus()
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Check current subscription status
        Task {
            await checkPremiumStatus()
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
    
    // MARK: - Debug (Development Only)
    
    #if DEBUG
    func setPremiumStatus(_ status: Bool) {
        savePremiumStatus(status)
    }
    #endif
    
    // MARK: - StoreKit 2
    
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
            // Load product
            let products = try await Product.products(for: [premiumProductID])
            
            guard let product = products.first else {
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

