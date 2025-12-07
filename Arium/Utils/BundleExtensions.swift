//
//  BundleExtensions.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import Foundation

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var fullVersion: String {
        return "\(appVersion) (\(buildNumber))"
    }
    
    var displayVersion: String {
        return appVersion
    }
}







