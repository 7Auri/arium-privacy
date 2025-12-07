//
//  ConfettiView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct ConfettiView: View {
    let celebrationType: ConfettiManager.CelebrationType
    let customMessage: String?
    let customColors: [Color]?
    
    @State private var particles: [Particle] = []
    @State private var showMessage = false
    @State private var messageScale: CGFloat = 0.5
    @State private var canvasSize: CGSize = .zero
    
    @StateObject private var confettiManager = ConfettiManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    
    // Accessibility: Check for reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(
        celebrationType: ConfettiManager.CelebrationType = .allHabitsCompleted,
        customMessage: String? = nil,
        customColors: [Color]? = nil
    ) {
        self.celebrationType = celebrationType
        self.customMessage = customMessage
        self.customColors = customColors
    }
    
    var body: some View {
        ZStack {
            // Confetti Particles - Only show if motion is not reduced
            if !reduceMotion {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        // Store canvas size for particle generation (only once)
                        if canvasSize.width == 0 || canvasSize.height == 0 {
                            canvasSize = size
                        }
                        
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
            }
            
            // Celebration Message
            if showMessage {
                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(messageScale)
                        .rotationEffect(.degrees(messageScale == 1.0 ? 360 : 0))
                    
                    Text(L10n.t("celebration.title"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .scaleEffect(messageScale)
                    
                    Text(customMessage ?? celebrationType.message)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .scaleEffect(messageScale)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .scaleEffect(messageScale)
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel(L10n.t("celebration.title"))
                .accessibilityHint(L10n.t("celebration.message"))
            }
        }
        .onAppear {
            if !reduceMotion {
                createParticles()
            }
            
            // Show message with animation (respect reduced motion)
            let animation = reduceMotion ? 
                Animation.linear(duration: 0.1) : 
                Animation.spring(response: 0.6, dampingFraction: 0.6)
            
            withAnimation(animation) {
                showMessage = true
                messageScale = 1.0
            }
            
            // Play sound if enabled
            if confettiManager.soundEnabled {
                SoundManager.shared.playCelebrationSound(for: celebrationType)
            }
            
            // Hide message after duration
            let messageDuration = min(celebrationType.duration - 1.0, 3.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + messageDuration) {
                let hideAnimation = reduceMotion ?
                    Animation.linear(duration: 0.1) :
                    Animation.easeOut(duration: 0.3)
                
                withAnimation(hideAnimation) {
                    messageScale = 0.8
                    showMessage = false
                }
            }
        }
    }
    
    private func createParticles() {
        let screenWidth = canvasSize.width > 0 ? canvasSize.width : UIScreen.main.bounds.width
        var particleCount = celebrationType.particleCount(intensity: confettiManager.intensity)
        
        // Performance optimization: Limit particle count based on device capabilities
        // Older devices may struggle with too many particles
        let maxParticles = 500 // Hard limit for performance
        particleCount = min(particleCount, maxParticles)
        
        // Get colors: use custom colors if provided, otherwise use theme colors if enabled, else default colors
        let colors = customColors ?? confettiManager.getColors(for: confettiManager.useCustomColors ? appThemeManager.accentColor.color : nil)
        
        // Pre-allocate array capacity for better performance
        particles.reserveCapacity(particleCount)
        
        for _ in 0..<particleCount {
            var particle = Particle.random(screenWidth: screenWidth)
            particle.color = colors.randomElement() ?? .blue
            particles.append(particle)
        }
    }
    
    private func updateParticles() {
        let screenWidth = canvasSize.width > 0 ? canvasSize.width : UIScreen.main.bounds.width
        
        for i in particles.indices {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].vy += 0.3 // Slower gravity for more visible fall
            particles[i].rotation += particles[i].spin
            // Slower opacity fade for longer visibility
            particles[i].opacity -= 0.002
        }
        
        // Keep particles longer (check for y > screen height + 200)
        let screenHeight = canvasSize.height > 0 ? canvasSize.height : UIScreen.main.bounds.height
        particles.removeAll { $0.y > screenHeight + 200 || $0.opacity <= 0 }
        
        // Add new particles at the top to maintain density
        let minParticles = celebrationType.particleCount(intensity: confettiManager.intensity) / 2
        if particles.count < minParticles {
            let colors = customColors ?? confettiManager.getColors(for: confettiManager.useCustomColors ? appThemeManager.accentColor.color : nil)
            for _ in 0..<10 {
                var particle = Particle.random(screenWidth: screenWidth)
                particle.color = colors.randomElement() ?? .blue
                particles.append(particle)
            }
        }
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
    
    static func random(screenWidth: CGFloat = UIScreen.main.bounds.width) -> Particle {
        // More vibrant colors
        let colors: [Color] = [
            .red, .blue, .green, .yellow, .pink, .purple, .orange,
            .cyan, .mint, .indigo
        ]
        
        return Particle(
            x: Double.random(in: 0...Double(screenWidth)),
            y: -50,
            vx: Double.random(in: -3...3), // Wider horizontal spread
            vy: Double.random(in: 3...10), // Faster initial velocity
            size: Double.random(in: 8...18), // Bigger particles for visibility
            color: colors.randomElement()!,
            rotation: Double.random(in: 0...360),
            spin: Double.random(in: -8...8), // More rotation
            shape: ParticleShape.allCases.randomElement()!
        )
    }
}

enum ParticleShape: CaseIterable {
    case circle
    case rectangle
    case star
    case diamond
    
    func path(in rect: CGRect) -> Path {
        switch self {
        case .circle:
            return Path(ellipseIn: rect)
        case .rectangle:
            return Path(rect)
        case .star:
            return createStarPath(in: rect)
        case .diamond:
            return createDiamondPath(in: rect)
        }
    }
    
    private func createStarPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * 0.4
        
        for i in 0..<5 {
            let angle = Double(i) * 4 * .pi / 5 - .pi / 2
            let outerX = center.x + CGFloat(cos(angle)) * radius
            let outerY = center.y + CGFloat(sin(angle)) * radius
            let innerAngle = angle + 2 * .pi / 5
            let innerX = center.x + CGFloat(cos(innerAngle)) * innerRadius
            let innerY = center.y + CGFloat(sin(innerAngle)) * innerRadius
            
            if i == 0 {
                path.move(to: CGPoint(x: outerX, y: outerY))
            } else {
                path.addLine(to: CGPoint(x: outerX, y: outerY))
            }
            path.addLine(to: CGPoint(x: innerX, y: innerY))
        }
        path.closeSubpath()
        return path
    }
    
    private func createDiamondPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width / 2
        let height = rect.height / 2
        
        path.move(to: CGPoint(x: center.x, y: center.y - height))
        path.addLine(to: CGPoint(x: center.x + width, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + height))
        path.addLine(to: CGPoint(x: center.x - width, y: center.y))
        path.closeSubpath()
        return path
    }
}
