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
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static let compactEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        // No pretty printing for better performance
        return encoder
    }()
}

