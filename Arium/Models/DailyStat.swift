//
//  DailyStat.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let completed: Bool
    let completionCount: Int // For multiple completions per day
    
    init(date: Date, completed: Bool, completionCount: Int = 0) {
        self.date = date
        self.completed = completed
        self.completionCount = completionCount
    }
}

