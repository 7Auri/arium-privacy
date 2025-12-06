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
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        // Explicitly asking NLTagger to detect language first increases reliability
        // Arium supports: EN, TR, DE, FR, ES, IT
        // NLTagger supports sentiment for many languages, but falling back to English model 
        // for unsupported ones might yield neutral results.
        // For now, we rely on automatic detection.
        
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let score = sentiment?.rawValue, let doubleScore = Double(score) {
            return doubleScore
        }
        
        return 0.0
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
