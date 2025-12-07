//
//  ShareCelebrationView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI
import UIKit

struct ShareCelebrationView: View {
    let celebrationType: ConfettiManager.CelebrationType
    let habitsCount: Int
    let maxStreak: Int
    let date: Date
    
    @Environment(\.dismiss) var dismiss
    @State private var shareItem: Any?
    
    var body: some View {
        VStack(spacing: 20) {
            // Celebration Content
            VStack(spacing: 16) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(L10n.t("celebration.title"))
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(celebrationType.message)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Stats
                HStack(spacing: 20) {
                    VStack {
                        Text("\(habitsCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(L10n.t("home.stats.total"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if maxStreak > 0 {
                        VStack {
                            Text("\(maxStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(L10n.t("home.stats.streak"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .id("celebrationCard")
            
            // Share Button
            Button {
                Task { @MainActor in
                    await generateShareItem()
                    // Present share sheet directly using UIActivityViewController
                    if let shareItem = shareItem {
                        presentShareSheet(with: shareItem)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text(L10n.t("button.share"))
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .onAppear {
                // Pre-generate share item asynchronously
                Task {
                    await generateShareItem()
                }
            }
            
            Button {
                dismiss()
            } label: {
                Text(L10n.t("button.done"))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func presentShareSheet(with item: Any) {
        let items: [Any] = [item]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Track share event
        AnalyticsManager.shared.trackEvent("celebration_shared", parameters: [
            "type": String(describing: celebrationType),
            "habits_count": habitsCount,
            "max_streak": maxStreak
        ])
        
        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // Find the topmost presented view controller
            var topController = rootViewController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            // Configure for iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topController.view
                popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topController.present(activityVC, animated: true)
        }
    }
    
    private func generateShareText() -> String {
        let emoji = "🎉"
        let title = L10n.t("celebration.title")
        let message = celebrationType.message
        let stats = "\(L10n.t("home.stats.total")): \(habitsCount) | \(L10n.t("home.stats.streak")): \(maxStreak)"
        
        return "\(emoji) \(title)\n\n\(message)\n\n\(stats)"
    }
    
    @MainActor
    private func generateShareItem() async {
        // Try to generate image first, fallback to text
        let renderer = ImageRenderer(content: celebrationCardView)
        renderer.scale = 3.0 // High resolution
        
        if let uiImage = renderer.uiImage {
            shareItem = uiImage
        } else {
            shareItem = generateShareText()
        }
    }
    
    private var celebrationCardView: some View {
        VStack(spacing: 16) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange, .pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(L10n.t("celebration.title"))
                .font(.title)
                .fontWeight(.bold)
            
            Text(celebrationType.message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(habitsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(L10n.t("home.stats.total"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if maxStreak > 0 {
                    VStack {
                        Text("\(maxStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(L10n.t("home.stats.streak"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(30)
        .frame(width: 400, height: 500)
        .background(Color.white)
    }
}
