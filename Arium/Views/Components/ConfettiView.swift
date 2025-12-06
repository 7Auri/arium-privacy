//
//  ConfettiView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    var pContext = context
                    let angle = Angle(degrees: particle.rotation)
                    pContext.rotate(by: angle)
                    pContext.opacity = particle.opacity
                    
                    let shape = particle.shape
                    let rect = CGRect(x: particle.x, y: particle.y, width: particle.size, height: particle.size)
                    
                    pContext.fill(shape.path(in: rect), with: .color(particle.color))
                }
            }
            .onChange(of: timeline.date) { old, new in
                updateParticles()
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        for _ in 0..<50 {
            particles.append(Particle.random())
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].vy += 0.5 // Gravity
            particles[i].rotation += particles[i].spin
            particles[i].opacity -= 0.005
        }
        
        particles.removeAll { $0.y > 1000 || $0.opacity <= 0 }
    }
}

struct Particle {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var size: Double
    var color: Color
    var rotation: Double
    var spin: Double
    var shape: ParticleShape
    var opacity: Double = 1.0
    
    static func random() -> Particle {
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
        return Particle(
            x: Double.random(in: 0...400),
            y: -50,
            vx: Double.random(in: -2...2),
            vy: Double.random(in: 2...8),
            size: Double.random(in: 5...12),
            color: colors.randomElement()!,
            rotation: Double.random(in: 0...360),
            spin: Double.random(in: -5...5),
            shape: ParticleShape.allCases.randomElement()!
        )
    }
}

enum ParticleShape: CaseIterable {
    case circle
    case rectangle
    
    func path(in rect: CGRect) -> Path {
        switch self {
        case .circle:
            return Path(ellipseIn: rect)
        case .rectangle:
            return Path(rect)
        }
    }
}
