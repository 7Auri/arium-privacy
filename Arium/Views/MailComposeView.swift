//
//  MailComposeView.swift
//  Arium
//
//  Created by Zorbey on 25.11.2025.
//

import SwiftUI
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
    let mailComposer: MFMailComposeViewController
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
}


