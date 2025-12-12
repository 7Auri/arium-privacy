//
//  SentimentAnalyzer.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import Foundation
import NaturalLanguage

/// Analyzes the emotional tone of text using on-device Machine Learning.
class SentimentAnalyzer {
    
    /// Returns a score between -1.0 (Very Negative) and 1.0 (Very Positive).
    static func analyzeSentiment(for text: String) -> Double {
        guard !text.isEmpty else { return 0.0 }
        
        // ÖNEMLİ: Emoji'leri ve kısa negatif ifadeleri özel olarak kontrol et
        let lowercasedText = text.lowercased()
        
        // Negatif emoji'ler ve ifadeler için manuel kontrol
        let negativeEmojis = ["😠", "😡", "😔", "😭", "😩", "😢", "😞", "😟", "😤", "😰", "😨", "😱"]
        let negativeKeywords = ["bad", "kötü", "sad", "üzücü", "zor", "difficult", "hard", "terrible", "awful", "horrible", "worst", "en kötü"]
        
        var hasNegativeEmoji = false
        var hasNegativeKeyword = false
        
        // Emoji kontrolü
        for emoji in negativeEmojis {
            if text.contains(emoji) {
                hasNegativeEmoji = true
                break
            }
        }
        
        // Negatif kelime kontrolü
        for keyword in negativeKeywords {
            if lowercasedText.contains(keyword) {
                hasNegativeKeyword = true
                break
            }
        }
        
        // Eğer negatif emoji veya kelime varsa, NLTagger sonucunu daha negatif yap
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        var baseScore: Double = 0.0
        if let score = sentiment?.rawValue, let doubleScore = Double(score) {
            baseScore = doubleScore
        }
        
        // Negatif emoji veya kelime varsa, skoru daha negatif yap
        if hasNegativeEmoji || hasNegativeKeyword {
            // Base score'u daha negatif yap (minimum -0.5, maksimum -0.8)
            let adjustedScore = min(-0.5, baseScore - 0.3)
            #if DEBUG
            print("🔍 Sentiment: '\(text)' -> Base: \(baseScore), Adjusted: \(adjustedScore) (Negative emoji/keyword detected)")
            #endif
            return adjustedScore
        }
        
        #if DEBUG
        if baseScore < -0.2 || baseScore > 0.2 {
            print("🔍 Sentiment: '\(text)' -> Score: \(baseScore)")
        }
        #endif
        
        return baseScore
    }
    
    /// Analyzes an array of notes and returns the average sentiment score.
    static func averageSentiment(for notes: [String]) -> Double {
        guard !notes.isEmpty else { return 0.0 }
        
        var totalScore = 0.0
        var validNotes = 0
        
        for note in notes {
            let score = analyzeSentiment(for: note)
            if score != 0 {
                totalScore += score
                validNotes += 1
            }
        }
        
        guard validNotes > 0 else { return 0.0 }
        return totalScore / Double(validNotes)
    }
}
