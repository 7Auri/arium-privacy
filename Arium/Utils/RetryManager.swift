//
//  RetryManager.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import Foundation

/// Manages retry logic for async operations
struct RetryManager {
    /// Retries an async operation with exponential backoff
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts (default: 3)
    ///   - initialDelay: Initial delay in seconds (default: 1.0)
    ///   - maxDelay: Maximum delay in seconds (default: 10.0)
    ///   - operation: The async operation to retry
    /// - Returns: The result of the operation
    /// - Throws: The last error if all retries fail
    static func retry<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 10.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        var delay = initialDelay
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Don't retry on last attempt
                if attempt < maxAttempts {
                    // Exponential backoff with jitter
                    let jitter = Double.random(in: 0.0...0.3) * delay
                    let backoffDelay = min(delay + jitter, maxDelay)
                    
                    #if DEBUG
                    print("⚠️ Retry attempt \(attempt)/\(maxAttempts) after \(backoffDelay)s: \(error.localizedDescription)")
                    #endif
                    
                    try await Task.sleep(nanoseconds: UInt64(backoffDelay * 1_000_000_000))
                    delay *= 2.0 // Exponential backoff
                }
            }
        }
        
        // All retries failed
        throw lastError ?? NSError(domain: "RetryManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation failed after \(maxAttempts) attempts"])
    }
    
    /// Retries an async operation with custom retry condition
    static func retryIf<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        shouldRetry: @escaping (Error) -> Bool,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        var delay = initialDelay
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Check if we should retry
                guard shouldRetry(error), attempt < maxAttempts else {
                    throw error
                }
                
                let backoffDelay = min(delay, 10.0)
                try await Task.sleep(nanoseconds: UInt64(backoffDelay * 1_000_000_000))
                delay *= 2.0
            }
        }
        
        throw lastError ?? NSError(domain: "RetryManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation failed after \(maxAttempts) attempts"])
    }
}
