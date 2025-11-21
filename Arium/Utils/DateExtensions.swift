//
//  DateExtensions.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation

extension Date {
    var greetingKey: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 0...4:
            return "greeting.night"
        case 5...11:
            return "greeting.morning"
        case 12...17:
            return "greeting.afternoon"
        default:
            return "greeting.evening"
        }
    }
    
    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func localizedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: currentLanguageCode())
        return formatter.string(from: self)
    }
    
    func localizedTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: currentLanguageCode())
        return formatter.string(from: self)
    }
    
    private func currentLanguageCode() -> String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        return lang == "tr" ? "tr_TR" : "en_US"
    }
}

