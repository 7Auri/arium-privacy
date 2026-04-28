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
    var product: Product? { get }
    var productLoadFailed: Bool { get }
    
    func loadProduct() async
    func purchasePremium() async
    func restorePurchases() async
    func checkPremiumStatus() async
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
    
    // Ürün bilgileri (App Store Connect'ten otomatik alınır)
    @Published var product: Product?
    
    // StoreKit 2 Product ID
    private let premiumProductID = "com.zorbeyteam.arium.premium"
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Kayıtlı premium durumunu yükle
        loadPremiumStatus()
        
        // Transaction güncellemelerini dinlemeye başla (Apple zorunlu)
        updateListenerTask = listenForTransactions()
        
        // Mevcut entitlement'ları kontrol et ve ürünü yükle
        Task {
            await checkPremiumStatus()
            await loadProduct()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Premium Durumu
    
    private func loadPremiumStatus() {
        let isTestPremium = UserDefaults.standard.bool(forKey: "isTestPremium")
        let isPromoPremium = UserDefaults.standard.bool(forKey: "isPromoPremium")
        let savedPremium = UserDefaults.standard.bool(forKey: "isPremium")
        
        if (isTestPremium || isPromoPremium) && savedPremium {
            isPremium = true
        } else {
            isPremium = savedPremium
        }
    }
    
    private func savePremiumStatus(_ status: Bool) {
        isPremium = status
        UserDefaults.standard.set(status, forKey: "isPremium")
    }
    
    // MARK: - Test Helper (TestFlight için)
    
    func setPremiumStatus(_ status: Bool) {
        UserDefaults.standard.set(true, forKey: "isTestPremium")
        savePremiumStatus(status)
    }

    // MARK: - Promo Code

    /// Valid promo codes that grant premium access.
    /// Add codes here — they are case-insensitive.
    private static let validPromoCodes: Set<String> = [
        "ARIUM2026",
        "ARIUMVIP",
        "ARIUMPREMIUM",
        "ZORBEYTEAM"
    ]

    /// Validates and redeems a promo code. Returns true if the code was valid.
    @discardableResult
    func redeemPromoCode(_ code: String) -> Bool {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !normalized.isEmpty else { return false }

        // Check if already redeemed
        let redeemedCodes = UserDefaults.standard.stringArray(forKey: "redeemedPromoCodes") ?? []
        if redeemedCodes.contains(normalized) {
            // Already redeemed but still grant premium (idempotent)
            savePremiumStatus(true)
            UserDefaults.standard.set(true, forKey: "isPromoPremium")
            return true
        }

        guard Self.validPromoCodes.contains(normalized) else { return false }

        // Redeem the code
        var codes = redeemedCodes
        codes.append(normalized)
        UserDefaults.standard.set(codes, forKey: "redeemedPromoCodes")
        UserDefaults.standard.set(true, forKey: "isPromoPremium")
        savePremiumStatus(true)
        HapticManager.success()
        return true
    }
    
    // MARK: - Ürün Yükleme
    
    func loadProduct() async {
        isProductLoading = true
        productLoadFailed = false
        
        defer { isProductLoading = false }
        
        do {
            let products = try await Product.products(for: [premiumProductID])
            
            if let loadedProduct = products.first {
                self.product = loadedProduct
                
                #if DEBUG
                print("✅ Premium ürün App Store Connect'ten yüklendi:")
                print("   📋 Görünen Ad: \(loadedProduct.displayName)")
                print("   💰 Fiyat: \(loadedProduct.displayPrice)")
                print("   📝 Açıklama: \(loadedProduct.description)")
                #endif
            } else {
                // Ürün bulunamadı — UI'da hata göster
                productLoadFailed = true
                #if DEBUG
                print("⚠️ Premium ürün App Store Connect'te bulunamadı")
                #endif
            }
        } catch {
            productLoadFailed = true
            #if DEBUG
            print("❌ Ürün yüklenemedi: \(error)")
            #endif
        }
    }
    
    // MARK: - Entitlement Kontrolü (Uygulama Açılışında — Apple Zorunlu)
    
    func checkPremiumStatus() async {
        // Test premium veya promo premium aktifse StoreKit kontrolünü atla
        let isTestPremium = UserDefaults.standard.bool(forKey: "isTestPremium")
        let isPromoPremium = UserDefaults.standard.bool(forKey: "isPromoPremium")
        if (isTestPremium || isPromoPremium) && UserDefaults.standard.bool(forKey: "isPremium") {
            isPremium = true
            return
        }
        
        // Transaction.currentEntitlements ile aktif satın alımları kontrol et
        var foundEntitlement = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == premiumProductID {
                    savePremiumStatus(true)
                    foundEntitlement = true
                    break
                }
            }
        }
        
        // Aktif entitlement bulunamadıysa (ve test/promo premium değilse)
        if !foundEntitlement && !isTestPremium && !isPromoPremium {
            savePremiumStatus(false)
        }
    }
    
    // MARK: - Satın Alma
    
    func purchasePremium() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Ürün yüklenmemişse, 3 denemeye kadar yükle
            if product == nil {
                for attempt in 1...3 {
                    await loadProduct()
                    if product != nil { break }
                    if attempt < 3 {
                        try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                    }
                }
            }
            
            guard let product = product else {
                errorMessage = L10n.t("premium.error.productNotFound")
                return
            }
            
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Premium durumunu güncelle
                savePremiumStatus(true)
                showingPurchaseSuccess = true
                
                // Transaction'ı bitir (Apple zorunlu)
                await transaction.finish()
                
                HapticManager.success()
                
            case .userCancelled:
                // Kullanıcı iptal etti — sessizce kapat, hata gösterme
                break
                
            case .pending:
                // Aile onayı bekliyor — kullanıcıya bilgi ver
                showingPendingMessage = true
                
            @unknown default:
                errorMessage = L10n.t("premium.error.unknown")
            }
        } catch let error as StoreKitError {
            // StoreKit hatalarını kullanıcıya anlamlı mesajlarla göster
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
    
    // MARK: - Satın Alımları Geri Yükle
    
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
    
    // MARK: - Transaction Listener (Apple Zorunlu)
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    
                    if transaction.productID == self.premiumProductID {
                        await MainActor.run {
                            self.savePremiumStatus(true)
                        }
                    }
                    
                    // Transaction'ı bitir (Apple zorunlu — bu olmadan sandbox'ta
                    // satın alımlar yeniden başlatmada "kaybolur")
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
    
    /// StoreKit hatalarını kullanıcı dostu mesajlara çevirir
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
