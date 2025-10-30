//
//  MainMenuView.swift
//  Nebula Flow
//

import SwiftUI

struct MainMenuView: View {
    @State private var selectedGame: GameType? = nil
    @State private var showStats = false
    @State private var buttonScale: [Int: CGFloat] = [:]
    
    enum GameType: Identifiable {
        case spaceAttack
        case mindOrbit
        case stellarReflex
        case cosmicBalance
        
        var id: Int {
            switch self {
            case .spaceAttack: return 0
            case .mindOrbit: return 1
            case .stellarReflex: return 2
            case .cosmicBalance: return 3
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    VStack(spacing: Theme.spacing) {
                        Spacer()
                            .frame(height: 60)
                        
                        // Nebula Core logo
                        ZStack {
                            ForEach(0..<2) { index in
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Theme.primaryAccent, Theme.secondaryAccent]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 80 - CGFloat(index * 15), height: 80 - CGFloat(index * 15))
                                    .rotationEffect(.degrees(Double(index) * 180))
                            }
                            
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Theme.primaryAccent.opacity(0.6),
                                            Theme.secondaryAccent.opacity(0.4),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 35
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .blur(radius: 8)
                        }
                        .padding(.bottom, 20)
                        
                        Text("Select Your Challenge")
                            .font(Theme.headlineFont)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, 10)
                        
                        // Navigation buttons
                        VStack(spacing: Theme.spacing) {
                            MenuButton(
                                title: "Space Attack",
                                subtitle: "Destroy meteors",
                                icon: "sparkles",
                                color: Theme.primaryAccent,
                                index: 0,
                                scale: buttonScale[0] ?? 1.0
                            ) {
                                selectedGame = .spaceAttack
                            }
                            
                            MenuButton(
                                title: "Mind Orbit",
                                subtitle: "Memory & patterns",
                                icon: "brain.head.profile",
                                color: Theme.secondaryAccent,
                                index: 1,
                                scale: buttonScale[1] ?? 1.0
                            ) {
                                selectedGame = .mindOrbit
                            }
                            
                            MenuButton(
                                title: "Stellar Reflex",
                                subtitle: "Test reactions",
                                icon: "bolt.fill",
                                color: Theme.secondaryAccent,
                                index: 2,
                                scale: buttonScale[2] ?? 1.0
                            ) {
                                selectedGame = .stellarReflex
                            }
                            
                            MenuButton(
                                title: "Cosmic Balance",
                                subtitle: "Focus training",
                                icon: "circle.circle",
                                color: Color(hex: "9D4EDD"),
                                index: 3,
                                scale: buttonScale[3] ?? 1.0
                            ) {
                                selectedGame = .cosmicBalance
                            }
                            
                            MenuButton(
                                title: "Nebula Stats",
                                subtitle: "View progress",
                                icon: "chart.bar.fill",
                                color: Color(hex: "00F5FF"),
                                index: 4,
                                scale: buttonScale[4] ?? 1.0
                            ) {
                                showStats = true
                            }
                        }
                        .padding(.horizontal, Theme.padding)
                        
                        Spacer()
                            .frame(height: 60)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Navigation links
                NavigationLink(
                    destination: SpaceAttackGameView(selectedGame: $selectedGame),
                    tag: GameType.spaceAttack,
                    selection: $selectedGame
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: MindOrbitGameView(selectedGame: $selectedGame),
                    tag: GameType.mindOrbit,
                    selection: $selectedGame
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: StellarReflexGameView(selectedGame: $selectedGame),
                    tag: GameType.stellarReflex,
                    selection: $selectedGame
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: CosmicBalanceGameView(selectedGame: $selectedGame),
                    tag: GameType.cosmicBalance,
                    selection: $selectedGame
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: StatisticsView(showStats: $showStats),
                    isActive: $showStats
                ) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let index: Int
    let scale: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            
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
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.bodyFont)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(Theme.captionFont)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(color)
                    
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.8), color]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(color)
                        .blur(radius: 15)
                        .opacity(0.5)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.3), color.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: color.opacity(0.6), radius: isPressed ? 15 : 25, x: 0, y: isPressed ? 5 : 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

