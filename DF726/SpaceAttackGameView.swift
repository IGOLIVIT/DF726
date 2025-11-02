//
//  SpaceAttackGameView.swift
//

import SwiftUI

struct SpaceAttackGameView: View {
    @Binding var selectedGame: MainMenuView.GameType?
    @StateObject private var dataManager = DataManager.shared
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var level = 1
    @State private var difficulty: Difficulty = .normal
    @State private var meteorites: [Meteorite] = []
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var showLevelUp = false
    @State private var energyFragmentsEarned = 0
    @Environment(\.presentationMode) var presentationMode
    
    enum GameState {
        case ready, playing
    }
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
        
        var spawnInterval: Double {
            switch self {
            case .easy: return 2.0
            case .normal: return 1.5
            case .hard: return 1.0
            }
        }
        
        var baseSpeed: CGFloat {
            switch self {
            case .easy: return 1.5
            case .normal: return 2.5
            case .hard: return 4.0
            }
        }
        
        var color: Color {
            switch self {
            case .easy: return Color(hex: "00F5FF")
            case .normal: return Theme.primaryAccent
            case .hard: return Color(hex: "FF003C")
            }
        }
        
        var energyMultiplier: Int {
            switch self {
            case .easy: return 1
            case .normal: return 2
            case .hard: return 3
            }
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            if gameState == .ready {
                readyView
            } else {
                playingView
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            endGame()
        }
    }
    
    var readyView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.primaryAccent)
                
                Text("Space Attack")
                    .font(Theme.titleFont)
                    .foregroundColor(.white)
                
                Text("Tap the meteorites to destroy them.\nDon't let them escape!")
                    .font(Theme.bodyFont)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Difficulty selector
            VStack(spacing: 12) {
                Text("Select Difficulty")
                    .font(Theme.bodyFont)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ForEach(Difficulty.allCases, id: \.self) { diff in
                        Button(action: {
                            difficulty = diff
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            Text(diff.rawValue)
                                .font(Theme.captionFont)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(difficulty == diff ? diff.color : Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(diff.color, lineWidth: difficulty == diff ? 2 : 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, Theme.padding)
            
            GlowingButton(title: "Start Game", action: {
                gameState = .playing
            }, color: Theme.primaryAccent)
            .padding(.horizontal, Theme.padding)
        }
    }
    
    var playingView: some View {
        VStack {
            // Top HUD
            HStack {
                Button(action: {
                    endGame()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Theme.primaryAccent.opacity(0.3))
                                .blur(radius: 10)
                        )
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(Theme.bodyFont)
                        .foregroundColor(difficulty.color)
                    
                    HStack(spacing: 8) {
                        Text("Lv.\(level)")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.secondaryAccent)
                        
                        Text("Score: \(score)")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 50)
            
            Spacer()
            
            // Game area
            GeometryReader { geometry in
                ZStack {
                    ForEach(meteorites) { meteorite in
                        MeteoriteView(meteorite: meteorite) {
                            destroyMeteorite(meteorite)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    startGame(in: geometry.size)
                }
            }
            
            Spacer()
                .frame(height: 100)
        }
        .overlay(
            Group {
                if showLevelUp {
                    LevelUpOverlay(level: level, energyFragments: energyFragmentsEarned)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
    
    func startGame(in size: CGSize) {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: difficulty.spawnInterval / Double(level), repeats: true) { _ in
            spawnMeteorite(in: size)
        }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateMeteoritePositions(in: size)
        }
    }
    
    func spawnMeteorite(in size: CGSize) {
        let meteorite = Meteorite(
            position: CGPoint(
                x: CGFloat.random(in: 50...(size.width - 50)),
                y: -50
            ),
            size: CGFloat.random(in: 30...60),
            speed: difficulty.baseSpeed + CGFloat.random(in: 0...1.0) * CGFloat(level) * 0.3
        )
        meteorites.append(meteorite)
    }
    
    func updateMeteoritePositions(in size: CGSize) {
        for index in meteorites.indices {
            meteorites[index].position.y += meteorites[index].speed
        }
        
        // Remove meteorites that went off screen
        meteorites.removeAll { $0.position.y > size.height + 50 }
    }
    
    func destroyMeteorite(_ meteorite: Meteorite) {
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
        
        if let index = meteorites.firstIndex(where: { $0.id == meteorite.id }) {
            meteorites.remove(at: index)
            score += 10
            
            // Level up every 100 points
            if score > 0 && score % 100 == 0 {
                levelUp()
            }
            
            dataManager.updateSpaceAttackScore(score)
        }
    }
    
    func levelUp() {
        level += 1
        energyFragmentsEarned = level * 5 * difficulty.energyMultiplier
        
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
        
        withAnimation(.spring()) {
            showLevelUp = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut) {
                showLevelUp = false
            }
        }
        
        dataManager.addEnergyFragments(energyFragmentsEarned)
    }
    
    func endGame() {
        spawnTimer?.invalidate()
        gameTimer?.invalidate()
        spawnTimer = nil
        gameTimer = nil
    }
}

struct Meteorite: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let speed: CGFloat
}

struct MeteoriteView: View {
    let meteorite: Meteorite
    let onTap: () -> Void
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Theme.secondaryAccent.opacity(0.8),
                                Theme.primaryAccent.opacity(0.6),
                                Theme.primaryAccent
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: meteorite.size / 2
                        )
                    )
                
                Circle()
                    .fill(Theme.primaryAccent)
                    .blur(radius: 10)
                    .opacity(0.5)
            }
            .frame(width: meteorite.size, height: meteorite.size)
            .rotationEffect(.degrees(rotation))
        }
        .buttonStyle(PlainButtonStyle())
        .position(meteorite.position)
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct LevelUpOverlay: View {
    let level: Int
    let energyFragments: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LEVEL \(level)")
                .font(Theme.titleFont)
                .foregroundColor(Theme.secondaryAccent)
            
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(Theme.primaryAccent)
                Text("+\(energyFragments) Energy Fragments")
                    .font(Theme.bodyFont)
                    .foregroundColor(.white)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.background.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Theme.primaryAccent, Theme.secondaryAccent]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
        )
        .shadow(color: Theme.primaryAccent.opacity(0.5), radius: 30)
    }
}
