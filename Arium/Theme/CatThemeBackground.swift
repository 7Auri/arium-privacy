//
//  CatThemeBackground.swift
//  Arium
//
//  Created by Zorbey on 21.01.2026.
//

import SwiftUI

struct CatThemeBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Determine how many paws fit
                let spacing: CGFloat = 80
                let cols = Int(geometry.size.width / spacing) + 1
                let rows = Int(geometry.size.height / spacing) + 1
                
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(hex: "#FF8C69").opacity(0.15))
                            .position(
                                x: CGFloat(col) * spacing + (row % 2 == 0 ? 0 : spacing/2),
                                y: CGFloat(row) * spacing
                            )
                            .rotationEffect(.degrees(Double.random(in: -20...20)))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false) // Don't block interactions
    }
}

#Preview {
    CatThemeBackground()
        .background(Color.white)
}
