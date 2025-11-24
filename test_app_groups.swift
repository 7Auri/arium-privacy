#!/usr/bin/env swift

import Foundation

// Test App Groups access
if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
    print("✅ App Groups erişimi başarılı")
    
    if let data = sharedDefaults.data(forKey: "SavedHabits") {
        print("✅ Veri bulundu: \(data.count) bytes")
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            print("✅ JSON decode başarılı: \(json.count) alışkanlık")
            for (index, habit) in json.enumerated() {
                if let title = habit["title"] as? String {
                    print("  \(index + 1). \(title)")
                }
            }
        } else {
            print("❌ JSON decode başarısız")
        }
    } else {
        print("⚠️ 'SavedHabits' key'inde veri yok")
    }
} else {
    print("❌ App Groups erişimi başarısız")
}
