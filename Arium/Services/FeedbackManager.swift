//
//  FeedbackManager.swift
//  Arium
//
//  Created by Zorbey on 25.11.2025.
//

import Foundation
import MessageUI
import SwiftUI
import StoreKit

@MainActor
class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()
    
    @Published var showingMailComposer = false
    @Published var mailComposeResult: Result<MFMailComposeResult, Error>?
    
    // Strong reference to retain the mail compose delegate while the composer is presented
    private var mailComposeDelegate: MailComposeDelegate?
    
    private let supportEmail = "hello.ariumapp@gmail.com"
    private static let appName = "Arium"
    private static var appVersion: String {
        Bundle.main.displayVersion
    }
    
    private init() {}
    
    // MARK: - Feedback Types
    
    enum FeedbackType {
        case bug
        case feature
        case support
        case coffee
        
        @MainActor
        var subject: String {
            switch self {
            case .bug:
                return L10n.t("settings.feedback.subject.bug")
            case .feature:
                return L10n.t("settings.feedback.subject.feature")
            case .support:
                return L10n.t("settings.feedback.subject.support")
            case .coffee:
                return L10n.t("settings.feedback.subject.coffee")
            }
        }
        
        @MainActor
        var bodyPrefix: String {
            switch self {
            case .bug:
                return String(format: L10n.t("settings.feedback.email.bug"), FeedbackManager.appVersion, UIDevice.current.model, UIDevice.current.systemVersion)
            case .feature:
                return L10n.t("settings.feedback.email.feature")
            case .support:
                return String(format: L10n.t("settings.feedback.email.support"), FeedbackManager.appVersion, UIDevice.current.model, UIDevice.current.systemVersion)
            case .coffee:
                return L10n.t("settings.feedback.email.coffee")
            }
        }
    }
    
    // MARK: - Mail Composer
    
    func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    func composeMail(type: FeedbackType) {
        if canSendMail() {
            showingMailComposer = true
        } else {
            // Mail gönderilemiyorsa, mailto URL'i aç
            openMailtoURL(type: type)
        }
    }
    
    private func openMailtoURL(type: FeedbackType) {
        let subject = type.subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = type.bodyPrefix.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailtoURL = "mailto:\(supportEmail)?subject=\(subject)&body=\(body)"
        
        if let url = URL(string: mailtoURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func getMailComposeViewController(type: FeedbackType) -> MFMailComposeViewController? {
        guard canSendMail() else { return nil }
        
        let composer = MFMailComposeViewController()
        // Create and retain a strong reference to the delegate to avoid deallocation warnings
        let delegate = MailComposeDelegate(manager: self)
        self.mailComposeDelegate = delegate
        composer.mailComposeDelegate = delegate
        composer.setToRecipients([supportEmail])
        composer.setSubject(type.subject)
        composer.setMessageBody(type.bodyPrefix, isHTML: false)
        
        return composer
    }
    
    // Expose a safe way to clear the retained delegate without breaking access control
    func clearMailComposeDelegate() {
        mailComposeDelegate = nil
    }
    
    // MARK: - App Store Review
    
    func requestAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

// MARK: - Mail Compose Delegate

private class MailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate {
    weak var manager: FeedbackManager?
    
    init(manager: FeedbackManager) {
        self.manager = manager
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        Task { @MainActor in
            // Dismiss UI on the main actor
            controller.dismiss(animated: true)

            // Clear retained delegate after dismissal to avoid retaining it longer than needed
            manager?.clearMailComposeDelegate()

            if let error = error {
                manager?.mailComposeResult = .failure(error)
            } else {
                manager?.mailComposeResult = .success(result)
            }
        }
    }
}

