//
//  DecimalInput.swift
//  Arium
//
//  Locale-aware parsing/formatting for free-text decimal entry fields.
//
//  Why this exists: `.decimalPad` renders the *device region's* decimal
//  separator. On Turkish (and most non-US) devices that is a comma, so the
//  user types "103,7". Swift's `Double("103,7")` returns nil because the
//  `Double(_:)` initializer only accepts a period. The result is that the
//  value silently fails to parse — to the user it looks like "the keyboard
//  has no period". This helper accepts either separator and formats values
//  back using the same separator the keyboard produces.
//

import Foundation

enum DecimalInput {
    /// Parses user-entered decimal text, accepting both the device-locale
    /// separator (e.g. ",") and a plain ".". Returns nil for empty/invalid input.
    /// Single-value entry fields have no thousands grouping, so normalizing the
    /// separator to "." is sufficient and unambiguous.
    static func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    /// Formats a value for display in an entry field using the device-locale
    /// decimal separator, so the prefilled text matches what the keyboard types.
    static func format(_ value: Double, fractionDigits: Int = 1) -> String {
        let formatted = String(format: "%.\(fractionDigits)f", value)
        let separator = Locale.current.decimalSeparator ?? "."
        return separator == "." ? formatted : formatted.replacingOccurrences(of: ".", with: separator)
    }
}
