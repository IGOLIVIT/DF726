//
//  AnimatedBackground.swift
//  Nebula Flow
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            // Animated stars
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(animate ? 0.2 : 1)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
            
            // Nebula gradient overlay
            RadialGradient(
                gradient: Gradient(colors: [
                    Theme.primaryAccent.opacity(0.15),
                    Theme.secondaryAccent.opacity(0.1),
                    Color.clear
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .blur(radius: 50)
            .scaleEffect(animate ? 1.2 : 1.0)
            .animation(
                Animation.easeInOut(duration: 8)
                    .repeatForever(autoreverses: true),
                value: animate
            )
        }
        .onAppear {
            animate = true
        }
    }
}

struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    let particleCount: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
    }
    
    func generateParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...6),
                color: [Theme.primaryAccent, Theme.secondaryAccent, .white].randomElement() ?? .white,
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}

struct GlowingButton: View {
    let title: String
    let action: () -> Void
    var color: Color = Theme.primaryAccent
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Text(title)
                .font(Theme.bodyFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.buttonHeight)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .fill(color)
                        
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .fill(color)
                            .blur(radius: 20)
                            .opacity(0.6)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(color.opacity(0.5), lineWidth: 2)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(color: color.opacity(0.5), radius: isPressed ? 10 : 20, x: 0, y: isPressed ? 5 : 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

