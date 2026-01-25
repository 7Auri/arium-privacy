//
//  ParticleEffects.swift
//  Arium
//
//  Created by Arium AI.
//

import SwiftUI

// MARK: - Water Drop Effect

struct WaterDrop: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var speed: Double
    var opacity: Double = 1.0
}

struct WaterDropEffectView: View {
    @State private var drops: [WaterDrop] = []
    let isActive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(drops) { drop in
                    Image(systemName: "drop.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue.opacity(0.8))
                        .position(x: drop.x, y: drop.y)
                        .scaleEffect(drop.scale)
                        .opacity(drop.opacity)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    emitDrops(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false) // Don't block interactions
    }
    
    private func emitDrops(in size: CGSize) {
        // Create 15-20 random drops
        for _ in 0..<20 {
            let startX = CGFloat.random(in: 0...size.width)
            let startY = CGFloat.random(in: -100 ... -20)
            let speed = Double.random(in: 1.5...2.5)
            let scale = CGFloat.random(in: 0.5...1.2)
            
            let drop = WaterDrop(x: startX, y: startY, scale: scale, speed: speed)
            drops.append(drop)
            
            // Animate each drop falling
            withAnimation(.linear(duration: speed)) {
                if let index = drops.firstIndex(where: { $0.id == drop.id }) {
                    drops[index].y = size.height + 50
                    drops[index].opacity = 0
                }
            }
        }
        
        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            drops.removeAll()
        }
    }
}

// MARK: - Confetti Effect

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var rotation: Double
    var scale: CGFloat
}

struct ConfettiEffectView: View {
    @State private var particles: [ConfettiParticle] = []
    let isActive: Bool
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    emitConfetti(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func emitConfetti(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        for _ in 0..<50 {
            let color = colors.randomElement() ?? .white
            let angle = Double.random(in: 0...360)
            let distance = Double.random(in: 50...300)
            let scale = CGFloat.random(in: 0.5...1.5)
            
            // Initial state: center
            let particle = ConfettiParticle(
                x: center.x,
                y: center.y,
                color: color,
                rotation: 0,
                scale: 0
            )
            
            particles.append(particle)
            
            // Target position based on angle and distance
            let radians = angle * .pi / 180
            let targetX = center.x + CGFloat(cos(radians) * distance)
            let targetY = center.y + CGFloat(sin(radians) * distance)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].x = targetX
                    particles[index].y = targetY
                    particles[index].rotation = Double.random(in: 180...720)
                    particles[index].scale = scale
                }
            }
            
            // Fade out
            withAnimation(.easeOut(duration: 1).delay(1)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].scale = 0
                    particles[index].y += 50 // Gravity effect
                }
            }
        }
        
        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            particles.removeAll()
        }
    }
}
