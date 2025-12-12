//
//  ToastView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

enum ToastType {
    case success
    case error
    case info
    case warning
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return AriumTheme.success
        case .error: return AriumTheme.danger
        case .info: return AriumTheme.accent
        case .warning: return AriumTheme.warning
        }
    }
}

struct ToastView: View {
    let message: String
    let type: ToastType
    @Binding var isPresented: Bool
    
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(type.color)
            
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AriumTheme.textPrimary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                offset = 0
                opacity = 1
            }
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismiss()
            }
        }
        .onTapGesture {
            dismiss()
        }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = -100
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastItem?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toast {
                VStack {
                    ToastView(
                        message: toast.message,
                        type: toast.type,
                        isPresented: Binding(
                            get: { self.toast != nil },
                            set: { if !$0 { self.toast = nil } }
                        )
                    )
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1000)
            }
        }
    }
}

struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
}

extension View {
    func toast(_ toast: Binding<ToastItem?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

#Preview {
    VStack {
        Button("Show Success Toast") {
            // Preview için
        }
    }
    .toast(.constant(ToastItem(message: "Habit saved successfully!", type: .success)))
}
