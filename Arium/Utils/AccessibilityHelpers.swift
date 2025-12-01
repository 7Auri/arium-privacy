//
//  AccessibilityHelpers.swift
//  Arium
//
//  Created by Zorbey on 22.11.2025.
//

import SwiftUI
import CoreText

extension View {
    /// Adds accessibility label for VoiceOver (convenience method)
    func ariumAccessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(Text(label))
    }
    
    /// Adds accessibility hint for VoiceOver (convenience method)
    func ariumAccessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(Text(hint))
    }
}

// MARK: - Dynamic Type Support

extension Font {
    static func ariumTitle() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static func ariumHeadline() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static func ariumBody() -> Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    
    static func ariumCaption() -> Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
    
    // Dancing Script font for app name
    static func dancingScript(size: CGFloat) -> Font {
        // Check if font file is in bundle
        if let fontPath = Bundle.main.path(forResource: "DancingScript-VariableFont_wght", ofType: "ttf") {
            print("✅ Font file found in bundle: \(fontPath)")
            
            // Try to load font using CoreText
            if let fontData = NSData(contentsOfFile: fontPath) as Data?,
               let dataProvider = CGDataProvider(data: fontData as CFData),
               let font = CGFont(dataProvider) {
                var error: Unmanaged<CFError>?
                if CTFontManagerRegisterGraphicsFont(font, &error) {
                    print("✅ Font registered successfully via CoreText")
                    // Get the font name from the CGFont
                    if let fontName = font.postScriptName as String? {
                        print("✅ Font PostScript name: \(fontName)")
                        if let uiFont = UIFont(name: fontName, size: size) {
                            return .custom(fontName, size: size)
                        }
                    }
                } else {
                    if let error = error?.takeRetainedValue() {
                        print("❌ Failed to register font: \(error)")
                    }
                }
            }
        } else {
            print("❌ Font file NOT found in bundle!")
            print("   Expected: DancingScript-VariableFont_wght.ttf")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            if let resourcePath = Bundle.main.resourcePath {
                print("   Resource path: \(resourcePath)")
                let fileManager = FileManager.default
                if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                    print("   Bundle contents (first 20):")
                    contents.prefix(20).forEach { print("      - \($0)") }
                }
            }
        }
        
        // Print ALL font families to find Dancing Script
        print("🔍 Searching for Dancing Script font...")
        print("📋 All font families containing 'Dancing' or 'Script':")
        var foundDancing = false
        UIFont.familyNames.sorted().forEach { family in
            if family.lowercased().contains("dancing") || family.lowercased().contains("script") {
                foundDancing = true
                print("   ✅ Family: \(family)")
                UIFont.fontNames(forFamilyName: family).forEach { name in
                    print("      - \(name)")
                }
            }
        }
        
        if !foundDancing {
            print("⚠️ No font family found with 'Dancing' or 'Script' in name")
        }
        
        // Try different possible font names for Dancing Script
        // Variable fonts use different naming conventions
        let fontNames = [
            "DancingScript-VariableFont_wght",  // Variable font name
            "DancingScript-Regular",
            "DancingScript",
            "Dancing Script",
            "DancingScript-Regular-VariableFont_wght",
            "DancingScriptVariableFont_wght"
        ]
        
        for fontName in fontNames {
            if let font = UIFont(name: fontName, size: size) {
                print("✅ Found Dancing Script font: \(fontName)")
                return .custom(fontName, size: size)
            }
        }
        
        // Try to find any font with "Dancing" in the name
        for family in UIFont.familyNames {
            if family.lowercased().contains("dancing") {
                let fontNames = UIFont.fontNames(forFamilyName: family)
                if let firstFont = fontNames.first {
                    print("✅ Found Dancing Script font family: \(family), using: \(firstFont)")
                    return .custom(firstFont, size: size)
                }
            }
        }
        
        // Fallback to system serif italic if font not loaded
        print("⚠️ Using fallback font: system serif italic")
        return .system(size: size, weight: .ultraLight, design: .serif).italic()
    }
}

