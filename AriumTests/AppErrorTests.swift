//
//  AppErrorTests.swift
//  AriumTests
//
//  Created by Auto on 23.11.2025.
//

import XCTest
@testable import Arium

final class AppErrorTests: XCTestCase {
    
    // MARK: - HabitError Tests
    
    func testHabitErrorEmptyTitle() {
        let error = HabitError.emptyTitle
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testHabitErrorNotesTooLong() {
        let error = HabitError.notesTooLong(maxLength: 100)
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertTrue(error.errorMessage.contains("100"))
    }
    
    func testHabitErrorInvalidStartDate() {
        let error = HabitError.invalidStartDate
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testHabitErrorEquatable() {
        let error1 = HabitError.emptyTitle
        let error2 = HabitError.emptyTitle
        let error3 = HabitError.invalidStartDate
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    // MARK: - ValidationError Tests
    
    func testValidationErrorEmptyField() {
        let error = ValidationError.emptyField(fieldName: "Title")
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertTrue(error.errorMessage.contains("Title"))
    }
    
    func testValidationErrorInvalidFormat() {
        let error = ValidationError.invalidFormat(fieldName: "Date")
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertTrue(error.errorMessage.contains("Date"))
    }
    
    func testValidationErrorOutOfRange() {
        let error = ValidationError.outOfRange(fieldName: "Days", min: 1, max: 100)
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertTrue(error.errorMessage.contains("Days"))
        XCTAssertTrue(error.errorMessage.contains("1"))
        XCTAssertTrue(error.errorMessage.contains("100"))
    }
    
    func testValidationErrorEquatable() {
        let error1 = ValidationError.emptyField(fieldName: "Title")
        let error2 = ValidationError.emptyField(fieldName: "Title")
        let error3 = ValidationError.emptyField(fieldName: "Name")
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    // MARK: - ExportError Tests
    
    func testExportErrorExportFailed() {
        let error = ExportError.exportFailed
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testExportErrorImportFailed() {
        let error = ExportError.importFailed
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testExportErrorFileNotFound() {
        let error = ExportError.fileNotFound
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testExportErrorInvalidFormat() {
        let error = ExportError.invalidFormat
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testExportErrorEquatable() {
        let error1 = ExportError.exportFailed
        let error2 = ExportError.exportFailed
        let error3 = ExportError.importFailed
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    // MARK: - NetworkError Tests
    
    func testNetworkErrorNoConnection() {
        let error = NetworkError.noConnection
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testNetworkErrorTimeout() {
        let error = NetworkError.timeout
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testNetworkErrorServerError() {
        let error = NetworkError.serverError
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testNetworkErrorUnknown() {
        let error = NetworkError.unknown
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testNetworkErrorEquatable() {
        let error1 = NetworkError.noConnection
        let error2 = NetworkError.noConnection
        let error3 = NetworkError.timeout
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    // MARK: - PremiumError Tests
    
    func testPremiumErrorProductNotFound() {
        let error = PremiumError.productNotFound
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testPremiumErrorUserCancelled() {
        let error = PremiumError.userCancelled
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testPremiumErrorPending() {
        let error = PremiumError.pending
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testPremiumErrorUnknown() {
        let error = PremiumError.unknown
        XCTAssertFalse(error.errorTitle.isEmpty)
        XCTAssertFalse(error.errorMessage.isEmpty)
    }
    
    func testPremiumErrorEquatable() {
        let error1 = PremiumError.productNotFound
        let error2 = PremiumError.productNotFound
        let error3 = PremiumError.userCancelled
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
}









