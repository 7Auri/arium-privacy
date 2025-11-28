//
//  CodingCache.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import Foundation

/// Singleton cache for JSONEncoder and JSONDecoder to improve performance
/// by reusing instances instead of creating new ones for each encoding/decoding operation
enum CodingCache {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Support both ISO8601 and timestamp for backward compatibility
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            
            // Try ISO8601 String first
            if let dateString = try? container.decode(String.self),
               let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            
            // Try timestamp (Double or Int)
            if let timestamp = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: timestamp)
            }
            
            // Fallback: current date
            print("⚠️ Could not decode date, using current date")
            return Date()
        }
        return decoder
    }()
    
    static let compactEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        // No pretty printing for better performance
        return encoder
    }()
}

