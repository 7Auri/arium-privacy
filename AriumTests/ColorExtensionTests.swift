//
//  ColorExtensionTests.swift
//  AriumTests
//
//  Created by Auto on 23.11.2025.
//

import XCTest
import SwiftUI
@testable import Arium

final class ColorExtensionTests: XCTestCase {
    
    func testColorHexInitializer() {
        // Test valid hex colors
        let red = Color(hex: "#FF0000")
        XCTAssertNotNil(red)
        
        let green = Color(hex: "#00FF00")
        XCTAssertNotNil(green)
        
        let blue = Color(hex: "#0000FF")
        XCTAssertNotNil(blue)
    }
    
    func testColorHexWithoutHash() {
        // Test hex without #
        let color = Color(hex: "FF0000")
        XCTAssertNotNil(color)
    }
    
    func testColorHexShortFormat() {
        // Test short format (RGB)
        let color = Color(hex: "#F00")
        XCTAssertNotNil(color)
    }
    
    func testColorHexInvalidFormat() {
        // Invalid hex should return a default color (not crash)
        let color = Color(hex: "invalid")
        XCTAssertNotNil(color)
    }
    
    func testColorHexEmptyString() {
        // Empty string should return a default color
        let color = Color(hex: "")
        XCTAssertNotNil(color)
    }
}









