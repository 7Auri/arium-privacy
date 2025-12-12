//
//  ErrorView.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import SwiftUI

struct ErrorView: View {
    let error: AppError
    let onRetry: (() -> Void)?
    
    @State private var isAnimating = false
    
    init(error: AppError, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AriumTheme.warning.opacity(0.15),
                                AriumTheme.warning.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)
                
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AriumTheme.warning.opacity(0.2),
                                AriumTheme.warning.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AriumTheme.warning, AriumTheme.warning.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.5)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isAnimating = true
                }
            }
            
            VStack(spacing: 12) {
                Text(error.errorTitle)
                    .applyAppFont(size: 24, weight: .bold)
                    .foregroundStyle(AriumTheme.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
                
                Text(error.errorMessage)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AriumTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                    isAnimating = true
                }
            }
            
            if let onRetry = onRetry {
                Button {
                    HapticManager.medium()
                    onRetry()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        Text(L10n.t("error.retry"))
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [
                                AriumTheme.accent,
                                AriumTheme.accent.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: AriumTheme.accent.opacity(0.35),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 10)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .accessibilityLabel(L10n.t("error.retry"))
                .accessibilityHint(L10n.t("error.retry.hint"))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var iconName: String {
        // Error tipine göre farklı ikonlar
        if error is NetworkError {
            return "wifi.slash"
        } else if error is ExportError {
            return "doc.badge.ellipsis"
        } else {
            return "exclamationmark.triangle.fill"
        }
    }
}

struct ErrorAlert: ViewModifier {
    @Binding var error: AppError?
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var errorId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: error?.errorTitle ?? "") { oldValue, newValue in
                if let newError = error {
                    alertTitle = newError.errorTitle
                    alertMessage = newError.errorMessage.isEmpty ? " " : newError.errorMessage
                    showingAlert = true
                    errorId = UUID()
                } else {
                    showingAlert = false
                }
            }
            .onChange(of: error?.errorMessage ?? "") { oldValue, newValue in
                if let newError = error {
                    alertTitle = newError.errorTitle
                    alertMessage = newError.errorMessage.isEmpty ? " " : newError.errorMessage
                    showingAlert = true
                } else {
                    showingAlert = false
                }
            }
            .alert(
                alertTitle.isEmpty ? L10n.t("error.title") : alertTitle,
                isPresented: $showingAlert
            ) {
                Button(L10n.t("button.ok")) {
                    error = nil
                }
                // Retry butonu ekle (eğer network error ise)
                if let networkError = error as? NetworkError,
                   networkError == .noConnection || networkError == .timeout {
                    Button(L10n.t("error.retry")) {
                        // Retry action burada handle edilebilir
                        error = nil
                    }
                }
            } message: {
                Text(alertMessage)
            }
    }
}

extension View {
    func errorAlert(error: Binding<AppError?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}

