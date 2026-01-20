//
//  CategoryPredictor.swift
//  Arium
//
//  Created for ML Features.
//

import Foundation
import NaturalLanguage

/// Predicts habit category from title using Natural Language Processing (Embeddings & Keywords)
class CategoryPredictor {
    static let shared = CategoryPredictor()
    
    private init() {}
    
    // Keywords for each category (Multilingual: EN, TR, ES)
    private let categoryKeywords: [HabitCategory: [String]] = [
        .work: [
            "work", "job", "career", "project", "meeting", "email", "coding", "presentation",
            "iş", "çalışma", "toplantı", "sunum", "proje", "kodlama", "ofis", "kariyer",
            "trabajo", "empleo", "carrera", "proyecto", "reunión", "oficina"
        ],
        .health: [
            "gym", "run", "walk", "water", "meditate", "yoga", "sleep", "medicine", "vitamin", "workout", "exercise", "diet",
            "spor", "koşu", "yürüyüş", "su", "meditasyon", "uyku", "ilaç", "vitamin", "egzersiz", "diyet", "sağlık",
            "gimnasio", "correr", "agua", "meditar", "dormir", "medicina", "ejercicio", "dieta", "salud"
        ],
        .learning: [
            "read", "study", "learn", "course", "book", "language", "class", "homework", "exam", "coding",
            "oku", "çalış", "öğren", "kurs", "kitap", "dil", "ders", "ödev", "sınav", "okuma",
            "leer", "estudiar", "aprender", "curso", "libro", "idioma", "clase", "tarea", "examen"
        ],
        .finance: [
            "save", "budget", "money", "invest", "bill", "expense", "bank", "crypto", "stock",
            "tasarruf", "bütçe", "para", "yatırım", "fatura", "harcama", "banka", "birikim",
            "ahorrar", "presupuesto", "dinero", "invertir", "factura", "gasto", "banco"
        ],
        .social: [
            "friend", "party", "date", "family", "call", "meet", "gift", "birthday", "event",
            "arkadaş", "parti", "buluşma", "aile", "arama", "hediye", "doğum günü", "etkinlik", "dost",
            "amigo", "fiesta", "cita", "familia", "llamar", "regalo", "cumpleaños", "evento"
        ],
        .personal: [
            "journal", "diary", "hobby", "relax", "cook", "clean", "home", "shopping",
            "günlük", "hobi", "dinlen", "yemek", "temizlik", "ev", "alışveriş",
            "diario", "hobby", "relajarse", "cocinar", "limpiar", "casa", "compras"
        ]
    ]
    
    /// Predicts the most likely category for a given text
    func predict(for text: String) -> HabitCategory? {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return nil }
        
        var bestCategory: HabitCategory?
        var maxScore: Double = 0.0
        
        // 1. Direct Keyword Matching (Exact & Contains)
        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if cleanText.contains(keyword) {
                    // Exact match bonus
                    let score = cleanText == keyword ? 1.0 : 0.8
                    if score > maxScore {
                        maxScore = score
                        bestCategory = category
                    }
                }
            }
        }
        
        if maxScore >= 0.9 { return bestCategory }
        
        // 2. NLEmbedding Semantic Search (If available for current language)
        // Note: NLEmbedding mainly supports major languages (EN, ES, FR, etc.). Turkish support might be limited or rely on English keywords if text is mixed.
        // We will check English embedding for the input text against English keywords.
        
        if let embedding = NLEmbedding.wordEmbedding(for: .english) {
            for (category, keywords) in categoryKeywords {
                // Check only English keywords for embedding comparison to save time
                // (Assuming the input might be English-ish or embedding handles basic cross-lingual if widely used words)
                let englishKeywords = keywords.prefix(10) // Take top 10 (which are usually EN in our definition)
                
                for keyword in englishKeywords {
                    let distance = embedding.distance(between: cleanText, and: keyword)
                    let similarity = 1.0 - distance
                    if similarity > maxScore && similarity > 0.7 { // Threshold 0.7
                        maxScore = similarity
                        bestCategory = category
                    }
                }
            }
        }
        
        return bestCategory
    }
}
