//
//  HapticManager.swift
//  Arium
//
//  Created by Zorbey on 22.11.2025.
//

import UIKit

struct HapticManager {
    // Shared generators for better performance
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    
    // Prepare generators (call once for better performance)
    static func prepare() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Success Feedback
    
    static func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    // MARK: - Warning Feedback
    
    static func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    // MARK: - Error Feedback
    
    static func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Light Impact
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Medium Impact
    
    static func medium() {
        impactGenerator.impactOccurred()
    }
    
    // MARK: - Heavy Impact
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Soft Impact (iOS 13+)
    
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Rigid Impact (iOS 13+)
    
    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Selection Feedback
    
    static func selection() {
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - Custom Pattern
    
    static func pattern(_ pattern: [Double], delay: Double = 0.1) {
        // Pattern: [0.0, 0.1, 0.2] = 3 taps with 0.1s delay
        for (index, delayTime) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                if index == 0 {
                    medium()
                } else {
                    light()
                }
            }
        }
    }
}

