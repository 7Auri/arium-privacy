//
//  HapticManager.swift
//  Arium
//
//  Created by Zorbey on 22.11.2025.
//

import UIKit

struct HapticManager {
    
    // MARK: - Success Feedback
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Warning Feedback
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // MARK: - Error Feedback
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Light Impact
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - Medium Impact
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Heavy Impact
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // MARK: - Soft Impact (iOS 13+)
    
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    // MARK: - Rigid Impact (iOS 13+)
    
    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
    
    // MARK: - Selection Feedback
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
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

