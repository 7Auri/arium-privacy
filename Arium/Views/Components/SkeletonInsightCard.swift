//
//  SkeletonInsightCard.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct SkeletonInsightCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon skeleton
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Spacer()
            }
            
            // Title skeleton
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 16)
            
            // Message skeleton (2 lines)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 100, height: 12)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(width: 280, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .opacity(isAnimating ? 0.6 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    HStack {
        SkeletonInsightCard()
        SkeletonInsightCard()
    }
    .padding()
}
