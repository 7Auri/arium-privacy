//
//  TermsOfServiceView.swift
//  Arium
//
//  Created by Zorbey on 24.12.2024.
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appThemeManager: AppThemeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms of Service")
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
                            title: "1. Acceptance of Terms",
                            content: "By downloading, installing, or using Arium (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these Terms, do not use the App."
                        )
                        
                        sectionView(
                            title: "2. Description of Service",
                            content: """
                            Arium is a habit tracking application that helps users:
                            • Track daily habits and build streaks
                            • Visualize progress with charts and statistics
                            • Sync data across devices via iCloud (optional)
                            • Access premium features through in-app purchase
                            """
                        )
                        
                        sectionView(
                            title: "3. User Accounts",
                            content: """
                            **No Account Required:**
                            Arium does not require user registration or account creation. All data is stored locally on your device.
                            
                            **Your Responsibilities:**
                            • Maintaining the security of your device
                            • Keeping your iOS and app updated
                            • Backing up your data (via iCloud or export)
                            """
                        )
                        
                        sectionView(
                            title: "4. Premium Subscription",
                            content: """
                            **Free Tier:**
                            • Up to 3 habits
                            • Basic features and themes
                            • 7-day statistics
                            
                            **Premium Tier:**
                            • Unlimited habits
                            • Advanced features (daily repetitions, custom goals)
                            • 30-day statistics and insights
                            • Premium templates and themes
                            
                            **Payment:**
                            Premium is a one-time purchase (non-consumable) charged to your Apple ID account. Refund requests are handled by Apple.
                            """
                        )
                        
                        sectionView(
                            title: "5. Your Data",
                            content: """
                            • You retain all rights to your habit data and notes
                            • You can export your data at any time (JSON, CSV, PDF)
                            • You can delete your data at any time
                            • We do not claim ownership of your data
                            • Your data remains private and is not shared
                            """
                        )
                        
                        sectionView(
                            title: "6. Acceptable Use",
                            content: """
                            You agree NOT to:
                            • Use the App for any illegal purpose
                            • Attempt to hack, reverse engineer, or modify the App
                            • Share your premium purchase with others
                            • Use automated systems to interact with the App
                            • Interfere with the App's functionality or security
                            """
                        )
                        
                        sectionView(
                            title: "7. Intellectual Property",
                            content: """
                            Arium app, design, logo, and content are owned by us and protected by copyright, trademark, and other intellectual property laws.
                            
                            We grant you a limited, non-exclusive, non-transferable license to use the App for personal, non-commercial purposes.
                            """
                        )
                        
                        sectionView(
                            title: "8. Third-Party Services",
                            content: """
                            The App integrates with Apple Services:
                            • App Store
                            • iCloud
                            • HealthKit
                            • CloudKit
                            
                            You must comply with Apple's terms for these services. We are not responsible for third-party services or their availability.
                            """
                        )
                        
                        sectionView(
                            title: "9. Disclaimers",
                            content: """
                            The App is provided "as is" without warranties of any kind.
                            
                            We do not guarantee that:
                            • The App will be error-free or uninterrupted
                            • Defects will be corrected
                            • The App will meet your specific requirements
                            
                            **Health Disclaimer:**
                            Arium is a productivity tool, not a medical or health app. Do not use it as a substitute for professional medical advice.
                            """
                        )
                        
                        sectionView(
                            title: "10. Limitation of Liability",
                            content: """
                            To the maximum extent permitted by law:
                            • We are not liable for any indirect, incidental, or consequential damages
                            • Our total liability shall not exceed the amount you paid for premium (if any)
                            • We are not liable for data loss (please backup your data)
                            """
                        )
                        
                        sectionView(
                            title: "11. Changes to Terms",
                            content: "We may update these Terms from time to time. Changes will be effective immediately upon posting. Continued use of the App after changes constitutes acceptance of the new Terms."
                        )
                        
                        sectionView(
                            title: "12. Contact Information",
                            content: """
                            For questions about these Terms:
                            
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
                            summaryItem(icon: "checkmark.circle", text: "What you can do: Use Arium for personal habit tracking")
                            summaryItem(icon: "xmark.circle", text: "What you can't do: Hack, share premium, or misuse the App")
                            summaryItem(icon: "app.badge", text: "What we provide: The App \"as is\" with regular updates")
                            summaryItem(icon: "lock.shield", text: "What we don't do: Access your data or guarantee 100% uptime")
                            summaryItem(icon: "dollarsign.circle", text: "Refunds: Handled by Apple")
                            summaryItem(icon: "envelope", text: "Questions: hello.ariumapp@gmail.com")
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
                        if let url = URL(string: "https://7Auri.github.io/arium-privacy/terms.html") {
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
                .applyAppFont(size: 18, weight: .bold)
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
    TermsOfServiceView()
        .environmentObject(AppThemeManager.shared)
}
