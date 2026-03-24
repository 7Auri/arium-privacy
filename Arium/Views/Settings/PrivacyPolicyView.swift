//
//  PrivacyPolicyView.swift
//  Arium
//
//  Created by Zorbey on 24.12.2024.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appThemeManager: AppThemeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .applyAppFont(size: 28, weight: .bold)
                            .foregroundStyle(.primary)
                        
                        Text("Last Updated: December 2024")
                            .applyAppFont(size: 14, weight: .medium)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Content
                    Group {
                        sectionView(
                            title: "Introduction",
                            content: "Arium (\"we,\" \"our,\" or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application."
                        )
                        
                        sectionView(
                            title: "Information We Collect",
                            content: """
                            **Information You Provide:**
                            • Habit Data: Titles, notes, completion dates, and streaks
                            • User Preferences: Theme selections, language preferences
                            • Premium Status: Purchase confirmation (handled by Apple)
                            
                            **Automatically Collected:**
                            • Device Information: Device type, iOS version
                            • Usage Data: App launch times, feature usage (anonymous)
                            """
                        )
                        
                        sectionView(
                            title: "How We Use Your Information",
                            content: """
                            We use your information to:
                            • Provide and maintain the Arium app functionality
                            • Sync your data across devices (if you enable iCloud)
                            • Send notifications and reminders (if enabled)
                            • Improve app performance and user experience
                            • Process premium purchases through Apple
                            """
                        )
                        
                        sectionView(
                            title: "Data Storage and Security",
                            content: """
                            **Local Storage:**
                            All your habit data is stored locally on your device using iOS secure storage with built-in encryption.
                            
                            **iCloud Storage (Optional):**
                            If you enable iCloud sync, your data is stored in your personal iCloud account using Apple's CloudKit with end-to-end encryption. Only you can access your iCloud data.
                            
                            **We Do NOT:**
                            • Store your data on our servers
                            • Share your data with third parties
                            • Sell your personal information
                            • Track your location
                            • Access your contacts or photos
                            """
                        )
                        
                        sectionView(
                            title: "Third-Party Services",
                            content: """
                            **Apple Services:**
                            • StoreKit: For processing premium purchases
                            • CloudKit: For optional iCloud sync
                            • HealthKit: For optional health data integration
                            
                            Apple's privacy policy applies to these services.
                            
                            **No Other Third Parties:**
                            We do not use any third-party analytics, advertising, or tracking services.
                            """
                        )
                        
                        sectionView(
                            title: "Your Rights",
                            content: """
                            You have the right to:
                            • **Access**: View all your data within the app
                            • **Export**: Export your data in JSON or CSV format
                            • **Delete**: Delete all your data (Settings → Clear All Habits)
                            • **Opt-Out**: Disable iCloud sync at any time
                            """
                        )
                        
                        sectionView(
                            title: "Children's Privacy",
                            content: "Arium is suitable for users of all ages. We do not knowingly collect personal information from children under 13."
                        )
                        
                        sectionView(
                            title: "GDPR Compliance (EU Users)",
                            content: """
                            If you are located in the European Economic Area (EEA), you have additional rights:
                            
                            • Right to access your personal data
                            • Right to rectification of inaccurate data
                            • Right to erasure ("right to be forgotten")
                            • Right to data portability
                            • Right to object to processing
                            
                            Contact: hello.ariumapp@gmail.com
                            """
                        )
                        
                        sectionView(
                            title: "Contact Us",
                            content: """
                            If you have questions about this Privacy Policy:
                            
                            Email: hello.ariumapp@gmail.com
                            Website: https://7Auri.github.io/arium-privacy
                            """
                        )
                    }
                    
                    // Summary Box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .applyAppFont(size: 18, weight: .bold)
                            .foregroundStyle(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            summaryItem(icon: "doc.text", text: "What we collect: Habit data, preferences, device info")
                            summaryItem(icon: "externaldrive", text: "Where it's stored: Your device + your iCloud (optional)")
                            summaryItem(icon: "lock.shield", text: "Who can access it: Only you")
                            summaryItem(icon: "hand.raised", text: "Do we share it: No")
                            summaryItem(icon: "trash", text: "Can you delete it: Yes, anytime")
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(appThemeManager.accentColor.color.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(appThemeManager.accentColor.color.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if let url = URL(string: "https://7Auri.github.io/arium-privacy/privacy.html") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "safari")
                            .foregroundStyle(appThemeManager.accentColor.color)
                    }
                }
            }
        }
    }
    
    private func sectionView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .applyAppFont(size: 20, weight: .bold)
                .foregroundStyle(.primary)
            
            Text(content)
                .applyAppFont(size: 15, weight: .regular)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
    
    private func summaryItem(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .applyAppFont(size: 14, weight: .semibold)
                .foregroundStyle(appThemeManager.accentColor.color)
                .frame(width: 20)
            
            Text(text)
                .applyAppFont(size: 14, weight: .medium)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    PrivacyPolicyView()
        .environmentObject(AppThemeManager.shared)
}
