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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ErrorAlert: ViewModifier {
    @Binding var error: AppError?
    
    func body(content: Content) -> some View {
        content
            .alert(
                error?.errorTitle ?? L10n.t("error.title"),
                isPresented: Binding(
                    get: { error != nil },
                    set: { if !$0 { error = nil } }
                )
            ) {
                Button(L10n.t("button.ok")) {
                    error = nil
                }
            } message: {
                if let error = error {
                    Text(error.errorMessage)
                }
            }
    }
}

extension View {
    func errorAlert(error: Binding<AppError?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}

