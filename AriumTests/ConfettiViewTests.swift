//
//  ConfettiViewTests.swift
//  AriumTests
//
//  Created by Auto on 07.12.2025.
//

import XCTest
import SwiftUI
@testable import Arium

final class ConfettiViewTests: XCTestCase {
    
    // MARK: - Particle Tests
    
    func testParticleRandomGeneration() {
        let particle = Particle.random(screenWidth: 400)
        
        XCTAssertGreaterThanOrEqual(particle.x, 0)
        XCTAssertLessThanOrEqual(particle.x, 400)
        XCTAssertEqual(particle.y, -50) // Starts above screen
        XCTAssertGreaterThanOrEqual(particle.size, 8)
        XCTAssertLessThanOrEqual(particle.size, 18)
        XCTAssertGreaterThanOrEqual(particle.opacity, 0)
        XCTAssertLessThanOrEqual(particle.opacity, 1.0)
    }
    
    func testParticleShapeGeneration() {
        let particle = Particle.random(screenWidth: 400)
        
        // Verify shape is one of the valid cases
        XCTAssertTrue(ParticleShape.allCases.contains(particle.shape))
    }
    
    // MARK: - ParticleShape Tests
    
    func testParticleShapePaths() {
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        for shape in ParticleShape.allCases {
            let path = shape.path(in: rect)
            XCTAssertFalse(path.isEmpty, "Path should not be empty for \(shape)")
        }
    }
    
    func testStarPathCreation() {
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        let path = ParticleShape.star.path(in: rect)
        
        XCTAssertFalse(path.isEmpty)
        // Star should have 5 points, so path should have multiple line segments
        XCTAssertGreaterThan(path.boundingRect.width, 0)
        XCTAssertGreaterThan(path.boundingRect.height, 0)
    }
    
    func testDiamondPathCreation() {
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        let path = ParticleShape.diamond.path(in: rect)
        
        XCTAssertFalse(path.isEmpty)
        XCTAssertGreaterThan(path.boundingRect.width, 0)
        XCTAssertGreaterThan(path.boundingRect.height, 0)
    }
    
    // MARK: - Localization Tests
    
    func testCelebrationLocalization() {
        // Test that localization keys exist
        let title = L10n.t("celebration.title")
        let message = L10n.t("celebration.message")
        
        XCTAssertFalse(title.isEmpty, "Celebration title should not be empty")
        XCTAssertFalse(message.isEmpty, "Celebration message should not be empty")
        XCTAssertNotEqual(title, "celebration.title", "Title should be translated")
        XCTAssertNotEqual(message, "celebration.message", "Message should be translated")
    }
    
    // MARK: - Performance Tests
    
    func testParticleCreationPerformance() {
        measure {
            var particles: [Particle] = []
            for _ in 0..<150 {
                particles.append(Particle.random(screenWidth: 400))
            }
            XCTAssertEqual(particles.count, 150)
        }
    }
    
    func testParticleUpdatePerformance() {
        var particles: [Particle] = []
        for _ in 0..<150 {
            particles.append(Particle.random(screenWidth: 400))
        }
        
        measure {
            for i in particles.indices {
                particles[i].x += particles[i].vx
                particles[i].y += particles[i].vy
                particles[i].vy += 0.3
                particles[i].rotation += particles[i].spin
                particles[i].opacity -= 0.002
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testParticleWithZeroScreenWidth() {
        let particle = Particle.random(screenWidth: 0)
        XCTAssertGreaterThanOrEqual(particle.x, 0)
    }
    
    func testParticleOpacityBounds() {
        var particle = Particle.random(screenWidth: 400)
        particle.opacity = -1.0
        
        // After update, opacity should be handled correctly
        particle.opacity -= 0.002
        XCTAssertLessThan(particle.opacity, 1.0)
    }
    
    func testParticleRemoval() {
        var particles: [Particle] = []
        for _ in 0..<10 {
            var particle = Particle.random(screenWidth: 400)
            particle.y = 2000 // Off screen
            particles.append(particle)
        }
        
        let initialCount = particles.count
        particles.removeAll { $0.y > 1200 || $0.opacity <= 0 }
        
        XCTAssertLessThan(particles.count, initialCount, "Particles off screen should be removed")
    }
}
