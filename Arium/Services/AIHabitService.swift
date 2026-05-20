//
//  AIHabitService.swift
//  Arium
//
//  Talks to the Cloudflare Worker that proxies Google Gemini for habit
//  suggestions. The Worker holds the real Gemini API key; this client only
//  knows a shared secret that proves the request came from a legitimate
//  Arium build.
//
//  Premium-only feature — gated at the call site, not here. The service
//  itself has no concept of premium so it remains testable in isolation.
//

import Foundation
import OSLog

// MARK: - Public Types

/// What the Worker hands back. Sanitized server-side, but we still defend
/// against missing fields here so a bad deploy can't crash the app.
struct AIHabitSuggestion: Equatable, Decodable {
    let title: String
    let category: HabitCategory
    let iconSymbol: String
    let goalDays: Int
    let reminderHour: Int
    let dailyRepetitions: Int
    let encouragement: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case category
        case iconSymbol = "icon"
        case goalDays
        case reminderHour
        case dailyRepetitions
        case encouragement
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = try c.decode(String.self, forKey: .title)
        let categoryRaw = try c.decode(String.self, forKey: .category)
        category = HabitCategory(rawValue: categoryRaw) ?? .personal
        iconSymbol = try c.decodeIfPresent(String.self, forKey: .iconSymbol) ?? "star.fill"
        goalDays = try c.decode(Int.self, forKey: .goalDays)
        reminderHour = try c.decode(Int.self, forKey: .reminderHour)
        // Older worker versions don't return dailyRepetitions; default to 1
        // so the app keeps working through any deploy lag.
        dailyRepetitions = try c.decodeIfPresent(Int.self, forKey: .dailyRepetitions) ?? 1
        encouragement = try c.decodeIfPresent(String.self, forKey: .encouragement) ?? ""
    }
    
    init(title: String, category: HabitCategory, iconSymbol: String, goalDays: Int, reminderHour: Int, dailyRepetitions: Int = 1, encouragement: String) {
        self.title = title
        self.category = category
        self.iconSymbol = iconSymbol
        self.goalDays = goalDays
        self.reminderHour = reminderHour
        self.dailyRepetitions = dailyRepetitions
        self.encouragement = encouragement
    }
}

enum AIHabitError: Error, LocalizedError {
    case notConfigured
    case rateLimited(retryAfter: Int)
    case inputTooShort
    case inputTooLong
    case unauthorized
    case unavailable
    case decoding
    case network
    
    var errorDescription: String? {
        switch self {
        case .notConfigured: return L10n.t("ai.error.notConfigured")
        case .rateLimited:   return L10n.t("ai.error.rateLimited")
        case .inputTooShort: return L10n.t("ai.error.inputTooShort")
        case .inputTooLong:  return L10n.t("ai.error.inputTooLong")
        case .unauthorized:  return L10n.t("ai.error.unauthorized")
        case .unavailable:   return L10n.t("ai.error.unavailable")
        case .decoding:      return L10n.t("ai.error.unavailable")
        case .network:       return L10n.t("ai.error.network")
        }
    }
}

// MARK: - Service

@MainActor
final class AIHabitService: ObservableObject {
    static let shared = AIHabitService()
    
    @Published var isLoading = false
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Arium", category: "AIHabit")
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// True when the build has the worker URL and shared secret configured.
    /// We prefer to gate UI on this so a misconfigured TestFlight build hides
    /// the AI button instead of showing a broken one.
    var isConfigured: Bool {
        guard let url = AIConfig.workerURL, !url.isEmpty,
              let secret = AIConfig.sharedSecret, !secret.isEmpty else {
            return false
        }
        return true
    }
    
    func suggestHabit(from input: String, language: String) async throws -> AIHabitSuggestion {
        guard isConfigured,
              let urlString = AIConfig.workerURL,
              let url = URL(string: "\(urlString)/v1/habit/suggest"),
              let secret = AIConfig.sharedSecret else {
            throw AIHabitError.notConfigured
        }
        
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { throw AIHabitError.inputTooShort }
        guard trimmed.count <= 200 else { throw AIHabitError.inputTooLong }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(secret, forHTTPHeaderField: "X-Arium-Secret")
        request.timeoutInterval = 15
        
        let body: [String: Any] = ["input": trimmed, "language": language]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        isLoading = true
        defer { isLoading = false }
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger.error("AI suggest network error: \(error.localizedDescription)")
            throw AIHabitError.network
        }
        
        guard let http = response as? HTTPURLResponse else {
            throw AIHabitError.unavailable
        }
        
        switch http.statusCode {
        case 200:
            break
        case 401:
            throw AIHabitError.unauthorized
        case 429:
            let retryAfter = (try? JSONDecoder().decode(RateLimitedBody.self, from: data).retryAfterSeconds) ?? 60
            throw AIHabitError.rateLimited(retryAfter: retryAfter)
        case 400, 502, 500:
            // Server-side validation or upstream Gemini failure. The detail
            // in `data` is for us, not the user — surface a generic message.
            logger.warning("AI suggest server error \(http.statusCode): \(String(data: data, encoding: .utf8) ?? "")")
            throw AIHabitError.unavailable
        default:
            throw AIHabitError.unavailable
        }
        
        struct Envelope: Decodable { let habit: AIHabitSuggestion }
        do {
            return try JSONDecoder().decode(Envelope.self, from: data).habit
        } catch {
            logger.error("AI suggest decode failed: \(error.localizedDescription)")
            throw AIHabitError.decoding
        }
    }
}

private struct RateLimitedBody: Decodable {
    let retryAfterSeconds: Int
}

// MARK: - Configuration
//
// The Worker URL and shared secret are populated from Info.plist (set via
// xcconfig in production, or hardcoded in DEBUG for local testing). Keeping
// them out of the source tree avoids leaking secrets into version control.
//
// Add to Info.plist:
//   AIWorkerURL = $(AI_WORKER_URL)
//   AISharedSecret = $(AI_SHARED_SECRET)
//
// In a Config.xcconfig (gitignored):
//   AI_WORKER_URL = https://arium-ai.your-subdomain.workers.dev
//   AI_SHARED_SECRET = <random 32-byte base64 string>

enum AIConfig {
    static var workerURL: String? {
        Bundle.main.object(forInfoDictionaryKey: "AIWorkerURL") as? String
    }
    
    static var sharedSecret: String? {
        Bundle.main.object(forInfoDictionaryKey: "AISharedSecret") as? String
    }
}
