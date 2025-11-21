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
            // Background
            AriumTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    
                    if viewModel.canSkip {
                        Button {
                            viewModel.skipToEnd()
                        } label: {
                            Text(L10n.t("onboarding.skip"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AriumTheme.textSecondary)
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
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Bottom Section
                bottomSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 16) {
            // Page Indicators (custom)
            HStack(spacing: 8) {
                ForEach(viewModel.pages) { page in
                    Capsule()
                        .fill(viewModel.currentPage == page.id ? AriumTheme.accent : AriumTheme.textTertiary)
                        .frame(width: viewModel.currentPage == page.id ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentPage)
                }
            }
            .padding(.bottom, 8)
            
            // Action Button
            Button {
                if viewModel.isLastPage {
                    viewModel.completeOnboarding(hasSeenOnboarding: $hasSeenOnboarding)
                } else {
                    viewModel.nextPage()
                }
            } label: {
                HStack {
                    Text(viewModel.isLastPage ? 
                         L10n.t("onboarding.start") : 
                         L10n.t("onboarding.continue"))
                        .font(.system(size: 18, weight: .semibold))
                    
                    if !viewModel.isLastPage {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AriumTheme.accent)
                .cornerRadius(16)
                .shadow(color: AriumTheme.accent.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(HabitStore())
}

