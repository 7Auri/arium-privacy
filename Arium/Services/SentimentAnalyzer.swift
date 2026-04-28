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
    /// Simple unweighted average — use `ewmaSentiment` for time-aware weighting.
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
    
    // MARK: - EWMA Sentiment
    
    /// Computes Exponential Weighted Moving Average sentiment over dated notes.
    ///
    /// **Why EWMA instead of a hard 7-day window?**
    /// A hard cutoff (e.g. 70% weight on last 7 days) means a single bad day can
    /// skew the entire score by 2.3x. EWMA applies gradual exponential decay:
    /// recent notes still matter more, but each individual note has bounded influence.
    /// The smoothing factor α = 0.15 gives a half-life of ~4.3 days, meaning a note
    /// from a week ago still carries ~35% of today's weight — enough to matter,
    /// but not enough to dominate.
    ///
    /// Formula: weight(i) = α * (1 - α)^i, where i = days ago
    /// Result:  Σ(score_i * weight_i) / Σ(weight_i)
    ///
    /// - Parameters:
    ///   - datedNotes: Array of (daysAgo, noteText) tuples, where daysAgo = 0 means today.
    ///                 Notes are expected to be pre-sorted (most recent first) but order doesn't affect result.
    ///   - alpha: Smoothing factor (0 < α ≤ 1). Default 0.15. Higher = more weight on recent notes.
    /// - Returns: Weighted sentiment score in range -1.0 to +1.0, or 0.0 if no valid notes.
    static func ewmaSentiment(
        for datedNotes: [(daysAgo: Int, text: String)],
        alpha: Double = 0.15
    ) -> Double {
        guard !datedNotes.isEmpty else { return 0.0 }
        
        var weightedSum = 0.0
        var totalWeight = 0.0
        
        for note in datedNotes {
            let score = analyzeSentiment(for: note.text)
            // Skip neutral/zero scores to avoid diluting the signal
            guard score != 0 else { continue }
            
            // weight = α * (1 - α)^daysAgo
            let weight = alpha * pow(1.0 - alpha, Double(max(0, note.daysAgo)))
            weightedSum += score * weight
            totalWeight += weight
        }
        
        guard totalWeight > 0 else { return 0.0 }
        return weightedSum / totalWeight
    }
}
