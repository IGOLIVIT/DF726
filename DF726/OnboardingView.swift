//
//  OnboardingView.swift
//

import SwiftUI

struct OnboardingView: View {
    @State private var showText = false
    @State private var showButton = false
    @State private var particles: [MovingParticle] = []
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            // Moving particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Visualization
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Theme.primaryAccent, Theme.secondaryAccent]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 120 - CGFloat(index * 20), height: 120 - CGFloat(index * 20))
                            .rotationEffect(.degrees(showText ? 360 : 0))
                            .animation(
                                Animation.linear(duration: Double(10 + index * 2))
                                    .repeatForever(autoreverses: false),
                                value: showText
                            )
                    }
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Theme.primaryAccent.opacity(0.8),
                                    Theme.secondaryAccent.opacity(0.6),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 60, height: 60)
                        .blur(radius: 10)
                }
                .opacity(showText ? 1 : 0)
                .scaleEffect(showText ? 1 : 0.5)
                
                // Main text
                VStack(spacing: 16) {
                    Text("Train your focus.")
                        .font(Theme.titleFont)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Expand your universe.")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.secondaryAccent)
                        .multilineTextAlignment(.center)
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 20)
                
                Spacer()
                
                // Start button
                if showButton {
                    GlowingButton(title: "Begin") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .padding(.horizontal, Theme.padding)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .onAppear {
            startAnimations()
            generateMovingParticles()
        }
    }
    
    func startAnimations() {
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            showText = true
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(1.5)) {
            showButton = true
        }
    }
    
    func generateMovingParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        particles = (0..<30).map { _ in
            MovingParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: 0...screenHeight)
                ),
                size: CGFloat.random(in: 3...8),
                color: [Theme.primaryAccent, Theme.secondaryAccent, .white].randomElement() ?? .white,
                opacity: Double.random(in: 0.4...0.9)
            )
        }
        
        animateParticles()
    }
    
    func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            for index in particles.indices {
                var particle = particles[index]
                
                // Move particles
                particle.position.x += CGFloat.random(in: -2...2)
                particle.position.y += CGFloat.random(in: -2...2)
                
                // Wrap around screen
                if particle.position.x < 0 {
                    particle.position.x = screenWidth
                }
                if particle.position.x > screenWidth {
                    particle.position.x = 0
                }
                if particle.position.y < 0 {
                    particle.position.y = screenHeight
                }
                if particle.position.y > screenHeight {
                    particle.position.y = 0
                }
                
                particles[index] = particle
            }
        }
    }
}

struct MovingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}


