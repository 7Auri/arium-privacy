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
    
    init(error: AppError, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(AriumTheme.warning)
            
            Text(error.errorTitle)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(error.errorMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let onRetry = onRetry {
                Button {
                    onRetry()
                } label: {
                    Text(L10n.t("error.retry"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AriumTheme.accent)
                        .cornerRadius(12)
                }
                .accessibilityLabel(L10n.t("error.retry"))
                .accessibilityHint(L10n.t("error.retry.hint"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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

