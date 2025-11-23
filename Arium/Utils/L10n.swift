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
            "home.slots.title": "Remaining Slots",
            "home.slots.message": "You have %d free habit slots remaining. Upgrade to Premium for unlimited habits!",
            "home.search.placeholder": "Search habits...",
            
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
            "habit.notFound": "Habit not found",
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
            "habit.templates.description": "Choose from pre-made habit templates",
            
            // Categories
            "category.work": "Work",
            "category.health": "Health",
            "category.learning": "Learning",
            "category.personal": "Personal",
            "category.finance": "Finance",
            "category.social": "Social",
            
            // Buttons
            "button.ok": "OK",
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
            "premium.templates.message": "Habit templates are available for Premium members only. Upgrade to unlock 10+ ready-to-use habit templates!",
            
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
            "settings.privacyPolicy": "Privacy Policy",
            "settings.termsOfService": "Terms of Service",
            "settings.resetOnboarding": "Reset Onboarding",
            "settings.clearAllHabits": "Clear All Habits",
            "settings.debug": "Debug",
            "settings.debug.togglePremium": "Toggle Premium (Debug)",
            "settings.appTheme": "App Theme",
            "settings.appearance": "Appearance",
            
            // Onboarding
            "onboarding.skip": "Skip",
            "onboarding.continue": "Continue",
            "onboarding.start": "Start Your Journey",
            "onboarding.selectTheme": "Choose Your Theme",
            "onboarding.selectTheme.subtitle": "Select a color that matches your style",
            "onboarding.page1.title": "Welcome to Arium",
            "onboarding.page1.subtitle": "Your calm space for growth, balance, and daily habits.",
            "onboarding.page2.title": "Build Momentum",
            "onboarding.page2.subtitle": "Track your habits and keep your streaks alive.",
            "onboarding.page3.title": "Make It Yours",
            "onboarding.page3.subtitle": "Customize themes and create your own routine.",
            
            // Widget
            "widget.todaysHabits": "Today's Habits",
            "widget.pending": "Pending",
            "widget.error.title": "Unable to Load",
            "widget.error.message": "Please open the app to sync your habits",
            "widget.empty.title": "No Habits Yet",
            "widget.empty.message": "Add your first habit in the app",
            
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
            "statistics.period.week": "Week",
            "statistics.period.month": "Month",
            "statistics.period.all": "All Time",
            "statistics.averageStreak": "Average Streak",
            "statistics.weeklyCompletions": "This Week",
            "statistics.monthlyCompletions": "This Month",
            
            // Share
            "share.daysTracking": "%d days tracking",
            
            // Themes
            "theme.purple": "Purple Dream",
            "theme.blue": "Ocean Blue",
            "theme.green": "Forest Green",
            "theme.pink": "Soft Pink",
            "theme.orange": "Sunset Orange",
            
            // App Themes
            "appTheme.purple": "Purple",
            "appTheme.blue": "Blue",
            "appTheme.green": "Green",
            "appTheme.pink": "Pink",
            "appTheme.orange": "Orange",
            "appTheme.teal": "Teal",
            "appTheme.indigo": "Indigo",
            "appTheme.red": "Red",
            
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
            "export.title": "Export Habits",
            "export.selectHabits": "Select Habits to Export",
            "export.habits": "Habits",
            "export.selectAll": "Select All",
            "export.deselectAll": "Deselect All",
            "export.selectedCount": "%d habit(s) selected",
            "export.button": "Export",
            "export.success.title": "Export Successful",
            "export.success.message": "Successfully exported %d habit(s).",
            "import.success.title": "Import Successful",
            "import.success.message": "Successfully imported %d habit(s).",
            
            // Watch
            "watch.empty.title": "No Habits",
            "watch.empty.subtitle": "Add habits on your iPhone",
            "watch.app.title": "Arium",
            
            // Errors
            "error.title": "Error",
            "error.retry": "Retry",
            "error.habit.emptyTitle": "Habit title cannot be empty",
            "error.habit.notesTooLong": "Notes cannot exceed %d characters",
            "error.habit.invalidStartDate": "Start date cannot be in the future",
            "error.habit.saveFailed": "Failed to save habit. Please try again.",
            "error.habit.loadFailed": "Failed to load habits. Please restart the app.",
            "error.habit.deleteFailed": "Failed to delete habit. Please try again.",
            "error.habit.updateFailed": "Failed to update habit. Please try again.",
            "error.validation.title": "Validation Error",
            "error.validation.emptyField": "%@ cannot be empty",
            "error.validation.invalidFormat": "Invalid format for %@",
            "error.validation.outOfRange": "%@ must be between %d and %d",
            "error.network.title": "Network Error",
            "error.network.noConnection": "No internet connection. Please check your network.",
            "error.network.timeout": "Request timed out. Please try again.",
            "error.network.serverError": "Server error. Please try again later.",
            "error.network.unknown": "An unknown network error occurred.",
            "error.export.failed": "Failed to export habits. Please try again.",
            "error.export.fileNotFound": "Export file not found.",
            "error.import.failed": "Failed to import habits. Please check the file format.",
            "error.import.invalidFormat": "Invalid file format. Please select a valid JSON file.",
            "premium.error.productNotFound": "Premium product not found. Please contact support.",
            "premium.error.userCancelled": "Purchase was cancelled.",
            "premium.error.pending": "Purchase is pending approval.",
            "premium.error.unknown": "An unknown error occurred during purchase.",
            "premium.error.unverified": "Transaction could not be verified.",
            "premium.error.noSubscription": "No active subscription found.",
            "premium.restore.success": "Purchases restored successfully!",
            "premium.restore.failed": "Failed to restore purchases. Please try again.",
            "premium.purchasing": "Processing purchase...",
            "premium.purchase.success.title": "Welcome to Premium!",
            "premium.purchase.success.message": "Thank you for upgrading! You now have access to all premium features.",
            
            // Templates
            "template.meditate.title": "Meditate",
            "template.meditate.description": "Daily meditation practice",
            "template.exercise.title": "Exercise",
            "template.exercise.description": "Physical activity or workout",
            "template.read.title": "Read Books",
            "template.read.description": "Read for at least 20 minutes",
            "template.water.title": "Drink Water",
            "template.water.description": "Drink 8 glasses of water",
            "template.journal.title": "Journal",
            "template.journal.description": "Write in your journal",
            "template.language.title": "Learn Language",
            "template.language.description": "Practice a new language",
            "template.money.title": "Save Money",
            "template.money.description": "Save a fixed amount daily",
            "template.family.title": "Call Family",
            "template.family.description": "Call a family member",
            "template.nosocial.title": "No Social Media",
            "template.nosocial.description": "Avoid social media before bed",
            "template.gratitude.title": "Gratitude",
            "template.gratitude.description": "Write 3 things you're grateful for",
        ],
        "tr": [
            // Home
            "home.title": "Arium",
            "home.empty.title": "Henüz alışkanlık yok",
            "home.empty.subtitle": "Bugün daha iyi alışkanlıklar oluşturmaya başla",
            "home.stats.total": "Toplam",
            "home.stats.streak": "Seri",
            "home.stats.rate": "Oran",
            "home.slots.title": "Kalan Slot",
            "home.slots.message": "%d ücretsiz alışkanlık slotunuz kaldı. Sınırsız alışkanlık için Premium'a yükseltin!",
            "home.search.placeholder": "Alışkanlıklarda ara...",
            
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
            "habit.notFound": "Alışkanlık bulunamadı",
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
            "habit.templates.description": "Hazır alışkanlık şablonlarından seç",
            
            // Categories
            "category.work": "İş",
            "category.health": "Sağlık",
            "category.learning": "Öğrenme",
            "category.personal": "Kişisel",
            "category.finance": "Finans",
            "category.social": "Sosyal",
            
            // Buttons
            "button.ok": "Tamam",
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
            "premium.templates.message": "Alışkanlık şablonları sadece Premium üyeler için kullanılabilir. 10+ hazır alışkanlık şablonunu açmak için yükseltin!",
            
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
            "settings.privacyPolicy": "Gizlilik Politikası",
            "settings.termsOfService": "Kullanım Şartları",
            "settings.resetOnboarding": "Onboarding'i Sıfırla",
            "settings.clearAllHabits": "Tüm Alışkanlıkları Temizle",
            "settings.debug": "Hata Ayıklama",
            "settings.debug.togglePremium": "Premium Aç/Kapat (Debug)",
            "settings.appTheme": "Uygulama Teması",
            "settings.appearance": "Görünüm",
            
            // Onboarding
            "onboarding.skip": "Geç",
            "onboarding.continue": "Devam",
            "onboarding.start": "Yolculuğa Başla",
            "onboarding.selectTheme": "Temanı Seç",
            "onboarding.selectTheme.subtitle": "Stilini yansıtan bir renk seç",
            "onboarding.page1.title": "Arium'a Hoş Geldin",
            "onboarding.page1.subtitle": "Büyüme, denge ve günlük alışkanlıklar için huzurlu alanın.",
            "onboarding.page2.title": "Momentum Oluştur",
            "onboarding.page2.subtitle": "Alışkanlıklarını takip et ve serilerini devam ettir.",
            "onboarding.page3.title": "Kendine Göre Yap",
            "onboarding.page3.subtitle": "Temaları özelleştir ve kendi rutinini oluştur.",
            
            // Widget
            "widget.todaysHabits": "Bugünün Alışkanlıkları",
            "widget.pending": "Bekleyen",
            "widget.error.title": "Yüklenemedi",
            "widget.error.message": "Lütfen alışkanlıklarınızı senkronize etmek için uygulamayı açın",
            "widget.empty.title": "Henüz Alışkanlık Yok",
            "widget.empty.message": "İlk alışkanlığınızı uygulamada ekleyin",
            
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
            "statistics.period.week": "Hafta",
            "statistics.period.month": "Ay",
            "statistics.period.all": "Tüm Zaman",
            "statistics.averageStreak": "Ortalama Seri",
            "statistics.weeklyCompletions": "Bu Hafta",
            "statistics.monthlyCompletions": "Bu Ay",
            
            // Share
            "share.daysTracking": "%d günlük alışkanlık",
            
            // Themes
            "theme.purple": "Mor Rüya",
            "theme.blue": "Okyanus Mavisi",
            "theme.green": "Orman Yeşili",
            "theme.pink": "Yumuşak Pembe",
            "theme.orange": "Gün Batımı",
            
            // App Themes
            "appTheme.purple": "Mor",
            "appTheme.blue": "Mavi",
            "appTheme.green": "Yeşil",
            "appTheme.pink": "Pembe",
            "appTheme.orange": "Turuncu",
            "appTheme.teal": "Turkuaz",
            "appTheme.indigo": "İndigo",
            "appTheme.red": "Kırmızı",
            
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
            "export.title": "Alışkanlıkları Dışa Aktar",
            "export.selectHabits": "Dışa Aktarılacak Alışkanlıkları Seç",
            "export.habits": "Alışkanlıklar",
            "export.selectAll": "Tümünü Seç",
            "export.deselectAll": "Tümünü Kaldır",
            "export.selectedCount": "%d alışkanlık seçildi",
            "export.button": "Dışa Aktar",
            "export.success.title": "Dışa Aktarma Başarılı",
            "export.success.message": "%d alışkanlık başarıyla dışa aktarıldı.",
            "import.success.title": "İçe Aktarma Başarılı",
            "import.success.message": "%d alışkanlık başarıyla içe aktarıldı.",
            
            // Watch
            "watch.empty.title": "Alışkanlık Yok",
            "watch.empty.subtitle": "iPhone'unuzdan alışkanlık ekleyin",
            "watch.app.title": "Arium",
            
            // Errors
            "error.title": "Hata",
            "error.retry": "Tekrar Dene",
            "error.habit.emptyTitle": "Alışkanlık başlığı boş olamaz",
            "error.habit.notesTooLong": "Notlar %d karakteri geçemez",
            "error.habit.invalidStartDate": "Başlangıç tarihi gelecekte olamaz",
            "error.habit.saveFailed": "Alışkanlık kaydedilemedi. Lütfen tekrar deneyin.",
            "error.habit.loadFailed": "Alışkanlıklar yüklenemedi. Lütfen uygulamayı yeniden başlatın.",
            "error.habit.deleteFailed": "Alışkanlık silinemedi. Lütfen tekrar deneyin.",
            "error.habit.updateFailed": "Alışkanlık güncellenemedi. Lütfen tekrar deneyin.",
            "error.validation.title": "Doğrulama Hatası",
            "error.validation.emptyField": "%@ boş olamaz",
            "error.validation.invalidFormat": "%@ için geçersiz format",
            "error.validation.outOfRange": "%@ %d ile %d arasında olmalı",
            "error.network.title": "Ağ Hatası",
            "error.network.noConnection": "İnternet bağlantısı yok. Lütfen ağınızı kontrol edin.",
            "error.network.timeout": "İstek zaman aşımına uğradı. Lütfen tekrar deneyin.",
            "error.network.serverError": "Sunucu hatası. Lütfen daha sonra tekrar deneyin.",
            "error.network.unknown": "Bilinmeyen bir ağ hatası oluştu.",
            "error.export.failed": "Alışkanlıklar dışa aktarılamadı. Lütfen tekrar deneyin.",
            "error.export.fileNotFound": "Dışa aktarma dosyası bulunamadı.",
            "error.import.failed": "Alışkanlıklar içe aktarılamadı. Lütfen dosya formatını kontrol edin.",
            "error.import.invalidFormat": "Geçersiz dosya formatı. Lütfen geçerli bir JSON dosyası seçin.",
            "premium.error.productNotFound": "Premium ürün bulunamadı. Lütfen destek ile iletişime geçin.",
            "premium.error.userCancelled": "Satın alma iptal edildi.",
            "premium.error.pending": "Satın alma onay bekliyor.",
            "premium.error.unknown": "Satın alma sırasında bilinmeyen bir hata oluştu.",
            "premium.error.unverified": "İşlem doğrulanamadı.",
            "premium.error.noSubscription": "Aktif abonelik bulunamadı.",
            "premium.restore.success": "Satın alımlar başarıyla geri yüklendi!",
            "premium.restore.failed": "Satın alımlar geri yüklenemedi. Lütfen tekrar deneyin.",
            "premium.purchasing": "Satın alma işleniyor...",
            "premium.purchase.success.title": "Premium'a Hoş Geldiniz!",
            "premium.purchase.success.message": "Yükseltme için teşekkürler! Artık tüm premium özelliklere erişiminiz var.",
            
            // Templates
            "template.meditate.title": "Meditasyon",
            "template.meditate.description": "Günlük meditasyon pratiği",
            "template.exercise.title": "Egzersiz",
            "template.exercise.description": "Fiziksel aktivite veya antrenman",
            "template.read.title": "Kitap Oku",
            "template.read.description": "En az 20 dakika kitap oku",
            "template.water.title": "Su İç",
            "template.water.description": "8 bardak su iç",
            "template.journal.title": "Günlük Tut",
            "template.journal.description": "Günlüğüne yaz",
            "template.language.title": "Dil Öğren",
            "template.language.description": "Yeni bir dil pratiği yap",
            "template.money.title": "Para Biriktir",
            "template.money.description": "Günlük sabit miktar biriktir",
            "template.family.title": "Aile Ara",
            "template.family.description": "Bir aile üyesini ara",
            "template.nosocial.title": "Sosyal Medya Yok",
            "template.nosocial.description": "Yatmadan önce sosyal medyadan kaçın",
            "template.gratitude.title": "Şükür",
            "template.gratitude.description": "Şükrettiğin 3 şeyi yaz",
        ]
    ]
}

