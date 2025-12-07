//
//  CelebrationView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct CelebrationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Celebration Icon
            Image(systemName: "party.popper.fill")
                .font(.system(size: 80))
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
            
            Text(L10n.t("insight.action.celebrate"))
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(L10n.t("celebration.encouragement"))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                HapticManager.success()
                dismiss()
            } label: {
                Text(L10n.t("button.done"))
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
