//
//  OnboardingView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    AriumTheme.background,
                    AriumTheme.background.opacity(0.95),
                    AriumTheme.accent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    
                    if viewModel.canSkip {
                        Button {
                            HapticManager.selection()
                            viewModel.skipToEnd()
                        } label: {
                            Text(L10n.t("onboarding.skip"))
                                .applyAppFont(size: 16, weight: .medium)
                                .foregroundColor(AriumTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemBackground).opacity(0.8))
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                }
                
                // Pages
                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageView(
                            page: page,
                            selectedTheme: $viewModel.selectedTheme
                        )
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentPage)
                
                // Bottom Section
                bottomSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 24) {
            // Page Indicators (custom)
            HStack(spacing: 8) {
                ForEach(viewModel.pages) { page in
                    Capsule()
                        .fill(viewModel.currentPage == page.id ? 
                              (viewModel.isLastPage ? viewModel.selectedTheme.accent : AriumTheme.accent) :
                              AriumTheme.textTertiary.opacity(0.3))
                        .frame(width: viewModel.currentPage == page.id ? 32 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.currentPage)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedTheme)
                }
            }
            .padding(.bottom, 4)
            
            // Action Button
            Button {
                HapticManager.medium()
                if viewModel.isLastPage {
                    HapticManager.success()
                    viewModel.completeOnboarding(hasSeenOnboarding: $hasSeenOnboarding)
                } else {
                    viewModel.nextPage()
                }
            } label: {
                HStack(spacing: 12) {
                    Text(viewModel.isLastPage ? 
                         L10n.t("onboarding.start") : 
                         L10n.t("onboarding.continue"))
                        .applyAppFont(size: 18, weight: .semibold)
                    
                    if !viewModel.isLastPage {
                        Image(systemName: "arrow.right")
                            .applyAppFont(size: 16, weight: .semibold)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        Image(systemName: "sparkles")
                            .applyAppFont(size: 16, weight: .semibold)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            viewModel.isLastPage ? viewModel.selectedTheme.accent : AriumTheme.accent,
                            (viewModel.isLastPage ? viewModel.selectedTheme.accent : AriumTheme.accent).opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: (viewModel.isLastPage ? viewModel.selectedTheme.accent : AriumTheme.accent).opacity(0.35),
                    radius: 12,
                    x: 0,
                    y: 6
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedTheme)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(HabitStore())
}

