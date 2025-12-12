//
//  CelebrationView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct CelebrationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var appThemeManager = AppThemeManager.shared
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Celebration Icon - Cat theme shows Lottie animation
            if appThemeManager.accentColor == .cat {
                LottieAnimationView(animationName: "cat-celebration", loopMode: .loop)
                    .frame(width: 80, height: 80)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            scale = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showConfetti = true
                        }
                    }
            } else {
                Image(systemName: "party.popper.fill")
                    .applyAppFont(size: 80)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            scale = 1.0
                            rotation = 360
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showConfetti = true
                        }
                    }
            }
            
            Text(appThemeManager.accentColor == .cat ? L10n.t("celebration.cat.title") : L10n.t("insight.action.celebrate"))
                .applyAppFont(size: 28, weight: .bold)
                .multilineTextAlignment(.center)
            
            Text(appThemeManager.accentColor == .cat ? L10n.t("celebration.cat.encouragement") : L10n.t("celebration.encouragement"))
                .applyAppFont(size: 17)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                HapticManager.success()
                dismiss()
            } label: {
                Text(L10n.t("button.done"))
                    .applyAppFont(size: 17, weight: .semibold)
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .overlay {
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showConfetti = false
                        }
                    }
            }
        }
    }
}

#Preview {
    CelebrationView()
}
