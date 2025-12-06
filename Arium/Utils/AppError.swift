//
//  AppError.swift
//  Arium
//
//  Created by Zorbey on 23.11.2025.
//

import Foundation

// MARK: - App Error Protocol

protocol AppError: LocalizedError {
    var errorTitle: String { get }
    var errorMessage: String { get }
}

// MARK: - Habit Errors

enum HabitError: AppError, Equatable {
    case emptyTitle
    case notesTooLong(maxLength: Int)
    case invalidStartDate
    case saveFailed
    case loadFailed
    case deleteFailed
    case updateFailed
    
    var errorTitle: String {
        return L10n.t("error.title")
    }
    
    var errorMessage: String {
        switch self {
        case .emptyTitle:
            return L10n.t("error.habit.emptyTitle")
        case .notesTooLong(let maxLength):
            return String(format: L10n.t("error.habit.notesTooLong"), maxLength)
        case .invalidStartDate:
            return L10n.t("error.habit.invalidStartDate")
        case .saveFailed:
            return L10n.t("error.habit.saveFailed")
        case .loadFailed:
            return L10n.t("error.habit.loadFailed")
        case .deleteFailed:
            return L10n.t("error.habit.deleteFailed")
        case .updateFailed:
            return L10n.t("error.habit.updateFailed")
        }
    }
    
    var errorDescription: String? {
        return errorMessage
    }
}

// MARK: - Validation Errors

enum ValidationError: AppError, Equatable {
    case emptyField(fieldName: String)
    case invalidFormat(fieldName: String)
    case outOfRange(fieldName: String, min: Int, max: Int)
    
    var errorTitle: String {
        return L10n.t("error.validation.title")
    }
    
    var errorMessage: String {
        switch self {
        case .emptyField(let fieldName):
            return String(format: L10n.t("error.validation.emptyField"), fieldName)
        case .invalidFormat(let fieldName):
            return String(format: L10n.t("error.validation.invalidFormat"), fieldName)
        case .outOfRange(let fieldName, let min, let max):
            return String(format: L10n.t("error.validation.outOfRange"), fieldName, min, max)
        }
    }
    
    var errorDescription: String? {
        return errorMessage
    }
}

// MARK: - Export/Import Errors

enum ExportError: AppError, Equatable {
    case exportFailed
    case importFailed
    case fileNotFound
    case invalidFormat
    
    var errorTitle: String {
        return L10n.t("error.title")
    }
    
    var errorMessage: String {
        switch self {
        case .exportFailed:
            return L10n.t("error.export.failed")
        case .importFailed:
            return L10n.t("error.import.failed")
        case .fileNotFound:
            return L10n.t("error.export.fileNotFound")
        case .invalidFormat:
            return L10n.t("error.import.invalidFormat")
        }
    }
    
    var errorDescription: String? {
        return errorMessage
    }
}

// MARK: - Network Errors

enum NetworkError: AppError, Equatable {
    case noConnection
    case timeout
    case serverError
    case unknown
    
    var errorTitle: String {
        return L10n.t("error.network.title")
    }
    
    var errorMessage: String {
        switch self {
        case .noConnection:
            return L10n.t("error.network.noConnection")
        case .timeout:
            return L10n.t("error.network.timeout")
        case .serverError:
            return L10n.t("error.network.serverError")
        case .unknown:
            return L10n.t("error.network.unknown")
        }
    }
    
    var errorDescription: String? {
        return errorMessage
    }
}

