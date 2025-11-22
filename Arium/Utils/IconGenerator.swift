//
//  IconGenerator.swift
//  Arium
//
//  Temporary icon generator for placeholder logo
//

import SwiftUI

struct IconGenerator: View {
    let isDarkMode: Bool
    let isTinted: Bool
    
    init(isDarkMode: Bool = false, isTinted: Bool = false) {
        self.isDarkMode = isDarkMode
        self.isTinted = isTinted
    }
    
    var body: some View {
        ZStack {
            if isTinted {
                // Tinted: Şeffaf arka plan
                Color.clear
            } else {
                // Gradient background
                LinearGradient(
                    colors: isDarkMode ? [
                        Color(red: 0.4, green: 0.2, blue: 0.7), // Dark purple
                        Color(red: 0.3, green: 0.1, blue: 0.6)  // Darker purple
                    ] : [
                        Color(red: 0.6, green: 0.4, blue: 0.9), // Purple
                        Color(red: 0.5, green: 0.3, blue: 0.8)  // Darker purple
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // "A" letter
            Text("A")
                .font(.system(size: 400, weight: .bold, design: .rounded))
                .foregroundColor(isTinted ? Color(red: 0.6, green: 0.4, blue: 0.9) : .white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 220))
    }
}

// Preview için 3 versiyon
struct IconGenerator_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                IconGenerator(isDarkMode: false, isTinted: false)
                    .frame(width: 200, height: 200)
                    .previewDisplayName("Normal")
                
                IconGenerator(isDarkMode: true, isTinted: false)
                    .frame(width: 200, height: 200)
                    .previewDisplayName("Dark")
                
                IconGenerator(isDarkMode: false, isTinted: true)
                    .frame(width: 200, height: 200)
                    .previewDisplayName("Tinted")
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
