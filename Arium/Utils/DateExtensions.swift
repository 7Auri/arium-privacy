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
    
    func localizedDateString(format: String? = nil) -> String {
        let formatter = DateFormatter()
        if let format = format {
            formatter.dateFormat = format
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        }
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
        switch lang {
        case "tr":
            return "tr_TR"
        case "de":
            return "de_DE"
        case "fr":
            return "fr_FR"
        case "es":
            return "es_ES"
        case "it":
            return "it_IT"
        default:
            return "en_US"
        }
    }
    
    func localizedRelativeTimeString() -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        
        if timeInterval < 60 {
            // Saniyeler
            let seconds = Int(timeInterval)
            switch lang {
            case "tr":
                return seconds == 1 ? "1 saniye önce" : "\(seconds) saniye önce"
            case "de":
                return seconds == 1 ? "vor 1 Sekunde" : "vor \(seconds) Sekunden"
            case "fr":
                return seconds == 1 ? "il y a 1 seconde" : "il y a \(seconds) secondes"
            case "es":
                return seconds == 1 ? "hace 1 segundo" : "hace \(seconds) segundos"
            case "it":
                return seconds == 1 ? "1 secondo fa" : "\(seconds) secondi fa"
            default:
                return seconds == 1 ? "1 second ago" : "\(seconds) seconds ago"
            }
        } else if timeInterval < 3600 {
            // Dakikalar
            let minutes = Int(timeInterval / 60)
            switch lang {
            case "tr":
                return minutes == 1 ? "1 dakika önce" : "\(minutes) dakika önce"
            case "de":
                return minutes == 1 ? "vor 1 Minute" : "vor \(minutes) Minuten"
            case "fr":
                return minutes == 1 ? "il y a 1 minute" : "il y a \(minutes) minutes"
            case "es":
                return minutes == 1 ? "hace 1 minuto" : "hace \(minutes) minutos"
            case "it":
                return minutes == 1 ? "1 minuto fa" : "\(minutes) minuti fa"
            default:
                return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
            }
        } else if timeInterval < 86400 {
            // Saatler
            let hours = Int(timeInterval / 3600)
            switch lang {
            case "tr":
                return hours == 1 ? "1 saat önce" : "\(hours) saat önce"
            case "de":
                return hours == 1 ? "vor 1 Stunde" : "vor \(hours) Stunden"
            case "fr":
                return hours == 1 ? "il y a 1 heure" : "il y a \(hours) heures"
            case "es":
                return hours == 1 ? "hace 1 hora" : "hace \(hours) horas"
            case "it":
                return hours == 1 ? "1 ora fa" : "\(hours) ore fa"
            default:
                return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
            }
        } else {
            // Günler veya tarih
            let days = Int(timeInterval / 86400)
            if days < 7 {
                switch lang {
                case "tr":
                    return days == 1 ? "1 gün önce" : "\(days) gün önce"
                case "de":
                    return days == 1 ? "vor 1 Tag" : "vor \(days) Tagen"
                case "fr":
                    return days == 1 ? "il y a 1 jour" : "il y a \(days) jours"
                case "es":
                    return days == 1 ? "hace 1 día" : "hace \(days) días"
                case "it":
                    return days == 1 ? "1 giorno fa" : "\(days) giorni fa"
                default:
                    return days == 1 ? "1 day ago" : "\(days) days ago"
                }
            } else {
                // Tarih formatı
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                formatter.locale = Locale(identifier: currentLanguageCode())
                return formatter.string(from: self)
            }
        }
    }
}

// MARK: - String Extension for Date Conversion

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

