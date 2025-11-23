//
//  L10n.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

class L10nManager: ObservableObject {
    static let shared = L10nManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
        }
    }
    
    private init() {
        // Önce UserDefaults'tan oku
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") {
            self.currentLanguage = savedLanguage
        } else {
            // Eğer kayıtlı dil yoksa, telefonun dilini algıla
            // Desteklenmiyorsa varsayılan olarak İngilizce kullan
            self.currentLanguage = Self.detectSystemLanguageWithFallback()
            UserDefaults.standard.set(self.currentLanguage, forKey: "appLanguage")
        }
    }
    
    /// Telefonun dilini algılar ve desteklenen dillere göre app dilini döndürür
    /// Eğer telefonun dili desteklenmiyorsa (tr veya en değilse), nil döndürür
    static func detectSystemLanguage() -> String? {
        // Önce preferred languages'ı kontrol et
        let preferredLanguages = Locale.preferredLanguages
        
        for languageCode in preferredLanguages {
            // "tr" veya "tr-TR" gibi formatları kontrol et
            if languageCode.hasPrefix("tr") {
                return "tr"
            }
            // "en" veya "en-US" gibi formatları kontrol et
            if languageCode.hasPrefix("en") {
                return "en"
            }
        }
        
        // Eğer preferred languages'da bulunamazsa, current locale'i kontrol et
        if let languageCode = Locale.current.language.languageCode?.identifier {
            if languageCode == "tr" {
                return "tr"
            }
            if languageCode == "en" {
                return "en"
            }
        }
        
        // Telefonun dili desteklenmiyor
        return nil
    }
    
    /// Telefonun dilini algılar, desteklenmiyorsa varsayılan olarak İngilizce döndürür
    static func detectSystemLanguageWithFallback() -> String {
        return detectSystemLanguage() ?? "en"
    }
}

enum L10n {
    private static var manager = L10nManager.shared
    
    static var currentLanguage: String {
        manager.currentLanguage
    }
    
    static func t(_ key: String) -> String {
        return translations[manager.currentLanguage]?[key] ?? translations["en"]?[key] ?? key
    }
    
    static func setLanguage(_ code: String) {
        manager.currentLanguage = code
    }
    
    private static let translations: [String: [String: String]] = [
        "en": [
            // Home
            "home.title": "Arium",
            "home.empty.title": "No habits yet",
            "home.empty.subtitle": "Start building better habits today",
            "home.stats.total": "Total",
            "home.stats.streak": "Streak",
            "home.stats.rate": "Rate",
            
            // Greetings
            "greeting.night": "Good Night",
            "greeting.morning": "Good Morning",
            "greeting.afternoon": "Good Afternoon",
            "greeting.evening": "Good Evening",
            
            // Habit
            "habit.new": "New Habit",
            "habit.title": "Title",
            "habit.notes": "Notes",
            "habit.streak": "Day Streak",
            "habit.theme": "Theme",
            "habit.detail": "Habit Details",
            "habit.completed": "Completed",
            "habit.notCompleted": "Not Completed",
            "habit.history": "History",
            "habit.stats": "Statistics",
            "habit.delete": "Delete Habit",
            "habit.delete.confirm": "Are you sure?",
            "habit.delete.message": "This action cannot be undone.",
            "habit.note.add": "Add Daily Note",
            "habit.note.title": "How did it go today?",
            "habit.note.placeholder": "Write a short note about today's progress... (optional)",
            "habit.complete": "Complete",
            "habit.skipNote": "Skip Note",
            "habit.startDate": "Start Date",
            "habit.goalDays": "Goal Challenge",
            "habit.days": "days",
            "habit.history.empty": "No completions yet",
            "habit.stats.7days": "7 Days",
            "habit.stats.30days": "30 Days",
            "habit.stats.total": "Total",
            "habit.category": "Category",
            "habit.filterByCategory": "Filter by Category",
            "habit.allCategories": "All Categories",
            "habit.templates.title": "Habit Templates",
            "habit.templates.use": "Use Template",
            
            // Categories
            "category.work": "Work",
            "category.health": "Health",
            "category.learning": "Learning",
            "category.personal": "Personal",
            "category.finance": "Finance",
            "category.social": "Social",
            
            // Buttons
            "button.save": "Save",
            "button.cancel": "Cancel",
            "button.delete": "Delete",
            "button.edit": "Edit",
            "button.done": "Done",
            "button.add": "Add",
            
            // Premium
            "premium.title": "Go Premium",
            "premium.message": "Free tier allows up to 3 habits. Upgrade to Premium for unlimited habits, custom themes, and more!",
            "premium.button": "Upgrade Now",
            "premium.limit": "slots remaining",
            "premium.featureMessage": "This feature is only available for Premium members. Upgrade to unlock!",
            "premium.goalDaysLocked": "Goal customization is available for Premium members only",
            "premium.categoryLocked": "Category selection is available for Premium members only",
            
            // Settings
            "settings.title": "Settings",
            "settings.language": "Language",
            "settings.language.system": "System",
            "settings.premium": "Premium",
            "settings.about": "About",
            "settings.active": "Active",
            "settings.freePlan": "Free Plan",
            "settings.version": "Version",
            "settings.totalHabits": "Total Habits",
            "settings.totalCompletions": "Total Completions",
            "settings.resetOnboarding": "Reset Onboarding",
            "settings.clearAllHabits": "Clear All Habits",
            "settings.debug": "Debug",
            "settings.debug.togglePremium": "Toggle Premium (Debug)",
            
            // Onboarding
            "onboarding.skip": "Skip",
            "onboarding.continue": "Continue",
            "onboarding.start": "Start Your Journey",
            "onboarding.selectTheme": "Choose Your Theme",
            "onboarding.page1.title": "Welcome to Arium",
            "onboarding.page1.subtitle": "Your calm space for growth, balance, and daily habits.",
            "onboarding.page2.title": "Build Momentum",
            "onboarding.page2.subtitle": "Track your habits and keep your streaks alive.",
            "onboarding.page3.title": "Make It Yours",
            "onboarding.page3.subtitle": "Customize themes and create your own routine.",
            
            // Widget
            "widget.todaysHabits": "Today's Habits",
            "widget.pending": "Pending",
            
            // Statistics
            "statistics.title": "Statistics",
            "statistics.allHabits": "All Habits",
            "statistics.viewStats": "View Statistics",
            "statistics.currentStreak": "Current Streak",
            "statistics.bestStreak": "Best Streak",
            "statistics.totalCompletions": "Total Completions",
            "statistics.completionHistory": "Completion History",
            "statistics.completionRate": "Completion Rate",
            "statistics.daysTracked": "Days Tracked",
            "statistics.consistency": "Consistency",
            "statistics.insights": "Insights",
            "statistics.details": "Details",
            "statistics.completed": "Completed",
            "statistics.notCompleted": "Not Completed",
            "statistics.last7Days": "Last 7 Days",
            "statistics.last30Days": "Last 30 Days",
            "statistics.premiumTitle": "Unlock Full Statistics",
            "statistics.premiumMessage": "Upgrade to Premium to see 30-day history and advanced insights",
            "statistics.excellent": "Excellent",
            "statistics.good": "Good",
            "statistics.fair": "Fair",
            "statistics.needsWork": "Needs Work",
            
            // Themes
            "theme.purple": "Purple Dream",
            "theme.blue": "Ocean Blue",
            "theme.green": "Forest Green",
            "theme.pink": "Soft Pink",
            "theme.orange": "Sunset Orange",
            
            // Notifications
            "notification.reminder.title": "⏰ Habit Reminder",
            "notification.reminder.body": "Time to complete: %@",
            "notification.streak.warning.title": "🔥 Don't Break Your Streak!",
            "notification.streak.warning.body": "You have a %d-day streak for '%@'. Complete it today!",
            "notification.milestone.title": "🎉 Milestone Achieved!",
            "notification.milestone.body": "%d days completed for '%@'! Keep going!",
            "notification.motivation.title": "✨ Daily Motivation",
            "notification.motivation.quote1": "Small steps lead to big changes.",
            "notification.motivation.quote2": "Today is a great day to build better habits!",
            "notification.motivation.quote3": "Consistency is the key to success.",
            "notification.motivation.quote4": "You're doing amazing! Keep it up!",
            "notification.motivation.quote5": "Every day is a new opportunity.",
            "settings.notifications": "Notifications",
            "settings.notifications.enable": "Enable Notifications",
            "settings.notifications.daily": "Daily Motivation",
            "settings.notifications.streaks": "Streak Warnings",
            
            // iCloud
            "settings.icloud.title": "iCloud Sync",
            "settings.icloud.sync": "Sync with iCloud",
            "settings.icloud.sync.description": "Keep your habits in sync across all your devices",
            "settings.icloud.syncNow": "Sync Now",
            "settings.icloud.lastSync": "Last synced",
            "settings.data": "Data Management",
            "settings.export": "Export Habits",
            "settings.import": "Import Habits",
        ],
        "tr": [
            // Home
            "home.title": "Arium",
            "home.empty.title": "Henüz alışkanlık yok",
            "home.empty.subtitle": "Bugün daha iyi alışkanlıklar oluşturmaya başla",
            "home.stats.total": "Toplam",
            "home.stats.streak": "Seri",
            "home.stats.rate": "Oran",
            
            // Greetings
            "greeting.night": "İyi Geceler",
            "greeting.morning": "Günaydın",
            "greeting.afternoon": "İyi Günler",
            "greeting.evening": "İyi Akşamlar",
            
            // Habit
            "habit.new": "Yeni Alışkanlık",
            "habit.title": "Başlık",
            "habit.notes": "Notlar",
            "habit.streak": "Günlük Seri",
            "habit.theme": "Tema",
            "habit.detail": "Alışkanlık Detayları",
            "habit.completed": "Tamamlandı",
            "habit.notCompleted": "Tamamlanmadı",
            "habit.history": "Geçmiş",
            "habit.stats": "İstatistikler",
            "habit.delete": "Alışkanlığı Sil",
            "habit.delete.confirm": "Emin misiniz?",
            "habit.delete.message": "Bu işlem geri alınamaz.",
            "habit.note.add": "Günlük Not Ekle",
            "habit.note.title": "Bugün nasıl geçti?",
            "habit.note.placeholder": "Bugünkü ilerleme hakkında kısa bir not yaz... (opsiyonel)",
            "habit.complete": "Tamamla",
            "habit.skipNote": "Notu Atla",
            "habit.startDate": "Başlangıç Tarihi",
            "habit.goalDays": "Hedef Challenge",
            "habit.days": "gün",
            "habit.history.empty": "Henüz tamamlama yok",
            "habit.stats.7days": "7 Gün",
            "habit.stats.30days": "30 Gün",
            "habit.stats.total": "Toplam",
            "habit.category": "Kategori",
            "habit.filterByCategory": "Kategoriye Göre Filtrele",
            "habit.allCategories": "Tüm Kategoriler",
            "habit.templates.title": "Alışkanlık Şablonları",
            "habit.templates.use": "Şablon Kullan",
            
            // Categories
            "category.work": "İş",
            "category.health": "Sağlık",
            "category.learning": "Öğrenme",
            "category.personal": "Kişisel",
            "category.finance": "Finans",
            "category.social": "Sosyal",
            
            // Buttons
            "button.save": "Kaydet",
            "button.cancel": "İptal",
            "button.delete": "Sil",
            "button.edit": "Düzenle",
            "button.done": "Tamam",
            "button.add": "Ekle",
            
            // Premium
            "premium.title": "Premium'a Geç",
            "premium.message": "Ücretsiz sürümde 3 alışkanlığa kadar izin verilir. Sınırsız alışkanlık, özel temalar ve daha fazlası için Premium'a yükseltin!",
            "premium.button": "Şimdi Yükselt",
            "premium.limit": "slot kaldı",
            "premium.featureMessage": "Bu özellik sadece Premium üyeler için kullanılabilir. Kilidi açmak için yükseltin!",
            "premium.goalDaysLocked": "Hedef özelleştirme sadece Premium üyeler için kullanılabilir",
            "premium.categoryLocked": "Kategori seçimi sadece Premium üyeler için kullanılabilir",
            
            // Settings
            "settings.title": "Ayarlar",
            "settings.language": "Dil",
            "settings.language.system": "Sistem",
            "settings.premium": "Premium",
            "settings.about": "Hakkında",
            "settings.active": "Aktif",
            "settings.freePlan": "Ücretsiz Plan",
            "settings.version": "Sürüm",
            "settings.totalHabits": "Toplam Alışkanlık",
            "settings.totalCompletions": "Toplam Tamamlama",
            "settings.resetOnboarding": "Onboarding'i Sıfırla",
            "settings.clearAllHabits": "Tüm Alışkanlıkları Temizle",
            "settings.debug": "Hata Ayıklama",
            "settings.debug.togglePremium": "Premium Aç/Kapat (Debug)",
            
            // Onboarding
            "onboarding.skip": "Geç",
            "onboarding.continue": "Devam",
            "onboarding.start": "Yolculuğa Başla",
            "onboarding.selectTheme": "Temanı Seç",
            "onboarding.page1.title": "Arium'a Hoş Geldin",
            "onboarding.page1.subtitle": "Büyüme, denge ve günlük alışkanlıklar için huzurlu alanın.",
            "onboarding.page2.title": "Momentum Oluştur",
            "onboarding.page2.subtitle": "Alışkanlıklarını takip et ve serilerini devam ettir.",
            "onboarding.page3.title": "Kendine Göre Yap",
            "onboarding.page3.subtitle": "Temaları özelleştir ve kendi rutinini oluştur.",
            
            // Widget
            "widget.todaysHabits": "Bugünün Alışkanlıkları",
            "widget.pending": "Bekleyen",
            
            // Statistics
            "statistics.title": "İstatistikler",
            "statistics.allHabits": "Tüm Alışkanlıklar",
            "statistics.viewStats": "İstatistikleri Gör",
            "statistics.currentStreak": "Güncel Seri",
            "statistics.bestStreak": "En İyi Seri",
            "statistics.totalCompletions": "Toplam Tamamlama",
            "statistics.completionHistory": "Tamamlama Geçmişi",
            "statistics.completionRate": "Tamamlama Oranı",
            "statistics.daysTracked": "Takip Edilen Gün",
            "statistics.consistency": "Tutarlılık",
            "statistics.insights": "İçgörüler",
            "statistics.details": "Detaylar",
            "statistics.completed": "Tamamlandı",
            "statistics.notCompleted": "Tamamlanmadı",
            "statistics.last7Days": "Son 7 Gün",
            "statistics.last30Days": "Son 30 Gün",
            "statistics.premiumTitle": "Tam İstatistikleri Aç",
            "statistics.premiumMessage": "30 günlük geçmiş ve gelişmiş içgörüler için Premium'a geç",
            "statistics.excellent": "Mükemmel",
            "statistics.good": "İyi",
            "statistics.fair": "Orta",
            "statistics.needsWork": "Gelişmeli",
            
            // Themes
            "theme.purple": "Mor Rüya",
            "theme.blue": "Okyanus Mavisi",
            "theme.green": "Orman Yeşili",
            "theme.pink": "Yumuşak Pembe",
            "theme.orange": "Gün Batımı",
            
            // Notifications
            "notification.reminder.title": "⏰ Alışkanlık Hatırlatıcısı",
            "notification.reminder.body": "Tamamlama zamanı: %@",
            "notification.streak.warning.title": "🔥 Serini Kaybetme!",
            "notification.streak.warning.body": "'%2$@' için %1$d günlük serin var. Bugün tamamla!",
            "notification.milestone.title": "🎉 Kilometre Taşına Ulaştın!",
            "notification.milestone.body": "'%2$@' için %1$d gün tamamlandı! Devam et!",
            "notification.motivation.title": "✨ Günlük Motivasyon",
            "notification.motivation.quote1": "Küçük adımlar büyük değişimlere yol açar.",
            "notification.motivation.quote2": "Bugün daha iyi alışkanlıklar oluşturmak için harika bir gün!",
            "notification.motivation.quote3": "Tutarlılık başarının anahtarıdır.",
            "notification.motivation.quote4": "Harikasın! Böyle devam et!",
            "notification.motivation.quote5": "Her gün yeni bir fırsattır.",
            "settings.notifications": "Bildirimler",
            "settings.notifications.enable": "Bildirimleri Aç",
            "settings.notifications.daily": "Günlük Motivasyon",
            "settings.notifications.streaks": "Seri Uyarıları",
            
            // iCloud
            "settings.icloud.title": "iCloud Senkronizasyonu",
            "settings.icloud.sync": "iCloud ile Senkronize Et",
            "settings.icloud.sync.description": "Alışkanlıklarınızı tüm cihazlarınızda senkronize edin",
            "settings.icloud.syncNow": "Şimdi Senkronize Et",
            "settings.icloud.lastSync": "Son senkronizasyon",
            "settings.data": "Veri Yönetimi",
            "settings.export": "Alışkanlıkları Dışa Aktar",
            "settings.import": "Alışkanlıkları İçe Aktar",
        ]
    ]
}

