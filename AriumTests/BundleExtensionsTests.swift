//
//  BundleExtensionsTests.swift
//  AriumTests
//
//  Created by Auto on 23.11.2025.
//

import XCTest
import Foundation
@testable import Arium

final class BundleExtensionsTests: XCTestCase {
    
    func testAppVersion() {
        let version = Bundle.main.appVersion
        XCTAssertFalse(version.isEmpty)
        // Should be in format like "1.1" or "1.0"
        XCTAssertTrue(version.contains("."))
    }
    
    func testBuildNumber() {
        let buildNumber = Bundle.main.buildNumber
        XCTAssertFalse(buildNumber.isEmpty)
        // Should be numeric
        XCTAssertNotNil(Int(buildNumber))
    }
    
    func testFullVersion() {
        let fullVersion = Bundle.main.fullVersion
        XCTAssertFalse(fullVersion.isEmpty)
        // Should contain version and build number
        XCTAssertTrue(fullVersion.contains("("))
        XCTAssertTrue(fullVersion.contains(")"))
    }
    
    func testDisplayVersion() {
        let displayVersion = Bundle.main.displayVersion
        XCTAssertFalse(displayVersion.isEmpty)
        // Should be same as appVersion
        XCTAssertEqual(displayVersion, Bundle.main.appVersion)
    }
    
    func testVersionFormat() {
        let version = Bundle.main.appVersion
        let components = version.split(separator: ".")
        XCTAssertGreaterThanOrEqual(components.count, 2)
        // Each component should be numeric
        for component in components {
            XCTAssertNotNil(Int(component))
        }
    }
}







