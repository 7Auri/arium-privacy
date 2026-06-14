//
//  LegalLinks.swift
//  Arium
//
//  Single source of truth for legal document URLs (EULA, Privacy Policy).
//  Apple App Store Guideline 3.1.2 requires functional links to the EULA
//  and Privacy Policy inside the purchase/paywall flow. Keep these here so
//  views never embed raw URL literals.
//

import Foundation

enum Legal {
    /// Apple's standard EULA (Licensed Application End User License Agreement).
    /// Required by Guideline 3.1.2 when no custom EULA is supplied.
    static let eula = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    /// Hosted Privacy Policy.
    static let privacyPolicy = URL(string: "https://7Auri.github.io/arium-privacy")!
}
