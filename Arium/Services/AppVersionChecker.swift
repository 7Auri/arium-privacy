//
//  AppVersionChecker.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import Foundation
import UIKit

@MainActor
class AppVersionChecker: ObservableObject {
    static let shared = AppVersionChecker()
    
    @Published var hasUpdateAvailable = false
    @Published var latestVersion: String?
    @Published var updateURL: URL?
    
    private let appStoreID: String = "YOUR_APP_STORE_ID" // App Store Connect'ten alınacak
    private let appStoreURL: String = "https://apps.apple.com/app/id"
    
    private init() {}
    
    func checkForUpdates() async {
        guard let appStoreID = Bundle.main.infoDictionary?["APP_STORE_ID"] as? String,
              !appStoreID.isEmpty,
              appStoreID != "YOUR_APP_STORE_ID" else {
            // App Store ID henüz ayarlanmamış, kontrol yapma
            return
        }
        
        let urlString = "https://itunes.apple.com/lookup?id=\(appStoreID)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let firstResult = results.first,
                  let latestVersion = firstResult["version"] as? String,
                  let trackViewUrl = firstResult["trackViewUrl"] as? String,
                  let updateURL = URL(string: trackViewUrl) else {
                return
            }
            
            let currentVersion = Bundle.main.appVersion
            
            // Version karşılaştırması
            if compareVersions(currentVersion, latestVersion) < 0 {
                self.latestVersion = latestVersion
                self.updateURL = updateURL
                self.hasUpdateAvailable = true
            }
        } catch {
            #if DEBUG
            print("❌ Version check failed: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func compareVersions(_ version1: String, _ version2: String) -> Int {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(v1Components.count, v2Components.count)
        
        for i in 0..<maxLength {
            let v1Value = i < v1Components.count ? v1Components[i] : 0
            let v2Value = i < v2Components.count ? v2Components[i] : 0
            
            if v1Value < v2Value {
                return -1
            } else if v1Value > v2Value {
                return 1
            }
        }
        
        return 0
    }
    
    func openAppStore() {
        guard let updateURL = updateURL else {
            // Fallback: App Store sayfasını aç
            if let appStoreID = Bundle.main.infoDictionary?["APP_STORE_ID"] as? String,
               !appStoreID.isEmpty,
               appStoreID != "YOUR_APP_STORE_ID",
               let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)") {
                UIApplication.shared.open(url)
            }
            return
        }
        
        UIApplication.shared.open(updateURL)
    }
}

