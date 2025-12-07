//
//  DataExportManager.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation
import UIKit
import PDFKit
import OSLog

enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case json = "JSON"
    case pdf = "PDF"
    
    var fileExtension: String {
        rawValue.lowercased()
    }
    
    var icon: String {
        switch self {
        case .csv: return "tablecells"
        case .json: return "doc.text"
        case .pdf: return "doc.richtext"
        }
    }
}

enum DataExportError: Error, LocalizedError {
    case noData
    case exportFailed
    case pdfGenerationFailed
    case invalidCSVFormat
    case csvImportFailed
    case importFailed
    
    var errorDescription: String? {
        switch self {
        case .noData: return L10n.t("export.error.noData")
        case .exportFailed: return L10n.t("export.error.failed")
        case .pdfGenerationFailed: return L10n.t("export.error.pdfFailed")
        case .invalidCSVFormat: return L10n.t("import.error.invalidCSV")
        case .csvImportFailed: return L10n.t("import.error.csvFailed")
        case .importFailed: return L10n.t("import.error.failed")
        }
    }
}

@MainActor
class DataExportManager {
    static let shared = DataExportManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Arium", category: "DataExport")
    
    private init() {}
    
    // MARK: - CSV Export
    
    func exportToCSV(habits: [Habit]) throws -> URL {
        guard !habits.isEmpty else {
            throw DataExportError.noData
        }
        
        var csvString = "ID,Title,Category,Created,Streak,Total Completions,Goal Days,Daily Repetitions,Notes\n"
        
        for habit in habits {
            let row = [
                habit.id.uuidString,
                escapeCsvField(habit.title),
                habit.category.rawValue, // Use rawValue for stable export
                dateFormatter.string(from: habit.createdAt),
                "\(habit.streak)",
                "\(habit.completionDates.count)",
                "\(habit.goalDays)",
                "\(habit.dailyRepetitions)",
                escapeCsvField(habit.notes)
            ].joined(separator: ",")
            
            csvString.append(row + "\n")
        }
        
        // Add completion history
        csvString.append("\n\nCompletion History\n")
        csvString.append("Habit ID,Habit Title,Completion Date,Has Note\n")
        
        for habit in habits {
            for date in habit.completionDates.sorted() {
                let hasNote = habit.noteForDate(date) != nil
                let row = [
                    habit.id.uuidString,
                    escapeCsvField(habit.title),
                    dateFormatter.string(from: date),
                    hasNote ? "Yes" : "No"
                ].joined(separator: ",")
                
                csvString.append(row + "\n")
            }
        }
        
        return try saveToTemporaryFile(csvString, filename: "Arium_Export_\(timestamp).csv")
    }
    
    // MARK: - JSON Export
    
    func exportToJSON(habits: [Habit]) throws -> URL {
        guard !habits.isEmpty else {
            throw DataExportError.noData
        }
        
        let exportData = ExportData(
            exportDate: Date(),
            version: "1.0",
            habits: habits
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw DataExportError.exportFailed
        }
        
        return try saveToTemporaryFile(jsonString, filename: "Arium_Export_\(timestamp).json")
    }
    
    // MARK: - JSON Import
    
    func importFromJSON(url: URL) throws -> [Habit] {
        // Start accessing security scoped resource if needed
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let exportData = try decoder.decode(ExportData.self, from: data)
            return exportData.habits
        } catch {
            logger.error("❌ JSON Import Failed: \(error.localizedDescription)")
            throw DataExportError.importFailed
        }
    }
    
    // MARK: - PDF Export
    
    func exportToPDF(habits: [Habit]) throws -> URL {
        guard !habits.isEmpty else {
            throw DataExportError.noData
        }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Arium",
            kCGPDFContextAuthor: "Arium Habit Tracker",
            kCGPDFContextTitle: "Habit Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let title = "Arium - Habit Report"
            title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Date
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let dateText = "Generated: \(Date().formatted())"
            dateText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // Summary Stats
            let totalHabits = habits.count
            let totalCompletions = habits.reduce(0) { $0 + $1.completionDates.count }
            let maxStreak = habits.map { $0.streak }.max() ?? 0
            
            let statsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            let summaryText = """
            Summary Statistics
            Total Habits: \(totalHabits)
            Total Completions: \(totalCompletions)
            Longest Streak: \(maxStreak) days
            """
            
            summaryText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: statsAttributes)
            yPosition += 80
            
            // Habits List
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]
            "Habits".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            yPosition += 30
            
            let habitAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            for (index, habit) in habits.enumerated() {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
                
                let habitText = """
                \(index + 1). \(habit.title)
                   Category: \(habit.category.localizedName) | Streak: \(habit.streak) days
                   Completions: \(habit.completionDates.count) | Goal: \(habit.goalDays) days
                """
                
                habitText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: habitAttributes)
                yPosition += 50
            }
        }
        
        let filename = "Arium_Report_\(timestamp).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        try data.write(to: url)
        return url
    }
    
    // MARK: - CSV Import
    
    func importFromCSV(data: Data) throws -> [Habit] {
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw DataExportError.csvImportFailed
        }
        
        let lines = csvString.components(separatedBy: .newlines)
        guard !lines.isEmpty else {
            throw DataExportError.invalidCSVFormat
        }
        
        // Find where completion history starts
        var habitLines: [String] = []
        var completionHistoryLines: [String] = []
        var inCompletionHistory = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                continue
            }
            
            if trimmed == "Completion History" {
                inCompletionHistory = true
                continue
            }
            
            if inCompletionHistory {
                if trimmed.hasPrefix("Habit ID") {
                    continue // Skip header
                }
                completionHistoryLines.append(trimmed)
            } else {
                if trimmed.hasPrefix("ID,") {
                    continue // Skip header
                }
                habitLines.append(trimmed)
            }
        }
        
        // Parse habits
        var habits: [Habit] = []
        var completionHistory: [String: [(date: Date, hasNote: Bool)]] = [:]
        
        // Parse completion history first
        for line in completionHistoryLines {
            let fields = parseCSVLine(line)
            guard fields.count >= 4,
                  let habitId = UUID(uuidString: fields[0]),
                  let date = dateFormatter.date(from: fields[2]) else {
                continue
            }
            let hasNote = fields[3].lowercased() == "yes"
            
            if completionHistory[habitId.uuidString] == nil {
                completionHistory[habitId.uuidString] = []
            }
            completionHistory[habitId.uuidString]?.append((date: date, hasNote: hasNote))
        }
        
        // Parse habits
        for line in habitLines {
            let fields = parseCSVLine(line)
            guard fields.count >= 9 else {
                continue
            }
            
            guard let id = UUID(uuidString: fields[0]),
                  let createdAt = dateFormatter.date(from: fields[3]),
                  let streak = Int(fields[4]),
                  let goalDays = Int(fields[6]),
                  let dailyRepetitions = Int(fields[7]) else {
                continue
            }
            
            // Find category by safe rawValue first, then fallback to testing logic for old imports
            let categoryString = fields[2]
            var category: HabitCategory
            
            if let cat = HabitCategory(rawValue: categoryString) {
                category = cat
            } else {
                // Backward compatibility lookup
                category = HabitCategory.allCases.first { category in
                    category.localizedName == categoryString
                } ?? .personal // Default to personal if not found
            }
            
            let title = unescapeCsvField(fields[1])
            let notes = unescapeCsvField(fields[8])
            
            // Get completion dates for this habit
            let completions = completionHistory[id.uuidString] ?? []
            let completionDates = completions.map { $0.date }
            
            // Convert completion notes to string format (Date string: note)
            var completionNotes: [String: String] = [:]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            for comp in completions where comp.hasNote {
                let dateString = dateFormatter.string(from: comp.date)
                completionNotes[dateString] = "" // Note content not in CSV, just mark as having note
            }
            
            // Create habit
            let habit = Habit(
                id: id,
                title: title,
                notes: notes,
                createdAt: createdAt,
                streak: streak,
                themeId: "purple", // Default theme
                isCompletedToday: false,
                completionDates: completionDates,
                completionNotes: completionNotes,
                startDate: createdAt,
                goalDays: goalDays,
                reminderTime: nil,
                isReminderEnabled: false,
                category: category,
                dailyRepetitions: dailyRepetitions
            )
            
            habits.append(habit)
        }
        
        guard !habits.isEmpty else {
            throw DataExportError.invalidCSVFormat
        }
        
        return habits
    }
    
    // MARK: - Share
    
    func shareExport(url: URL, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Helpers
    
    private func escapeCsvField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
    
    private func unescapeCsvField(_ field: String) -> String {
        var result = field
        if result.hasPrefix("\"") && result.hasSuffix("\"") {
            result = String(result.dropFirst().dropLast())
        }
        return result.replacingOccurrences(of: "\"\"", with: "\"")
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                if inQuotes && currentField.hasSuffix("\"") {
                    // Escaped quote
                    currentField = String(currentField.dropLast()) + "\""
                } else {
                    inQuotes.toggle()
                }
            } else if char == "," && !inQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        fields.append(currentField)
        
        return fields.map { unescapeCsvField($0) }
    }
    
    private func saveToTemporaryFile(_ content: String, filename: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        guard let data = content.data(using: .utf8) else {
            throw DataExportError.exportFailed
        }
        
        try data.write(to: url)
        return url
    }
    
    private var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}

// MARK: - Export Data Model

struct ExportData: Codable {
    let exportDate: Date
    let version: String
    let habits: [Habit]
}

