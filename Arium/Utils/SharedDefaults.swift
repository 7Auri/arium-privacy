//
//  SharedDefaults.swift
//  Arium
//
//  Created by Auto on 06.12.2025.
//

import Foundation

struct SharedDefaults {
    static let suiteName = "group.zorbey.Arium"
    
    static let store: UserDefaults = {
        UserDefaults(suiteName: suiteName) ?? .standard
    }()
}
