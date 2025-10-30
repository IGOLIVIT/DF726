//
//  CosmicBalanceGameView.swift
//  Nebula Flow
//

import SwiftUI

struct CosmicBalanceGameView: View {
    @Binding var selectedGame: MainMenuView.GameType?
    @StateObject private var dataManager = DataManager.shared
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var difficulty: Difficulty = .normal
    @State private var balance: CGFloat = 0.5 // 0 to 1 (position on bar)
    @State private var velocity: CGFloat = 0 // Velocity of the orb
    @State private var targetZone: ClosedRange<CGFloat> = 0.45...0.55
    @State private var isInZone = false
    @State private var isHolding = false
    @State private var timeInZone: TimeInterval = 0
    @State private var totalTimeInZone: TimeInterval = 0
    @State private var roundTimer: Timer?
    @State private var roundTimeRemaining: TimeInterval = 10.0
    @State private var currentRound = 1
    @State private var maxRounds = 5
    @State private var energyFragmentsEarned = 0
    @State private var perfectRounds = 0
    @Environment(\.presentationMode) var presentationMode
    
    enum GameState {
        case ready, playing, results
    }
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
        
        var zoneSize: CGFloat {
            switch self {
            case .easy: return 0.15
            case .normal: return 0.10
            case .hard: return 0.06
            }
        }
        
        var driftSpeed: CGFloat {
            switch self {
            case .easy: return 0.0008
            case .normal: return 0.0015
            case .hard: return 0.0025
            }
        }
        
        var controlStrength: CGFloat {
            switch self {
            case .easy: return 0.003
            case .normal: return 0.002
            case .hard: return 0.0015
            }
        }
        
        var color: Color {
            switch self {
            case .easy: return Color(hex: "00F5FF")
            case .normal: return Color(hex: "9D4EDD")
            case .hard: return Theme.primaryAccent
            }
        }
    }
    
    let totalRoundTime: TimeInterval = 10.0
    
    var balancePercentage: Int {
        Int(totalTimeInZone / (totalRoundTime * Double(maxRounds)) * 100)
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
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
                        
                        if gameState == .playing {
                            Text("Round \(currentRound)/\(maxRounds)")
                                .font(Theme.bodyFont)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 50)
                
                Spacer()
            }
            
            // Game content
            if gameState == .ready {
                readyView
            } else if gameState == .playing {
                playingView
            } else if gameState == .results {
                resultsView
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
                Image(systemName: "circle.circle")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "9D4EDD"))
                
                Text("Cosmic Balance")
                    .font(Theme.titleFont)
                    .foregroundColor(.white)
                
                Text("Hold the button to move orb toward center.\nKeep it balanced in the target zone!")
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
            
            GlowingButton(title: "Start Training", action: {
                startGame()
            }, color: Color(hex: "9D4EDD"))
            .padding(.horizontal, Theme.padding)
        }
    }
    
    var playingView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Score display
            VStack(spacing: 8) {
                Text("\(Int(timeInZone * 10))")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(isInZone ? Theme.secondaryAccent : .white.opacity(0.5))
                    .animation(.easeInOut(duration: 0.2), value: isInZone)
                
                Text("Balance Score")
                    .font(Theme.captionFont)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Balance bar
            VStack(spacing: 20) {
                // Time remaining indicators
                HStack(spacing: 8) {
                    ForEach(0..<maxRounds, id: \.self) { index in
                        RoundIndicator(
                            isComplete: index < currentRound - 1,
                            isCurrent: index == currentRound - 1,
                            progress: index == currentRound - 1 ? CGFloat(1.0 - (roundTimeRemaining / totalRoundTime)) : 0
                        )
                    }
                }
                
                // Instructions
                Text(isInZone ? "Perfect! Keep holding!" : (isHolding ? "Moving to center..." : "Hold button to control"))
                    .font(Theme.bodyFont)
                    .foregroundColor(isInZone ? Theme.secondaryAccent : .white.opacity(0.6))
                    .animation(.easeInOut, value: isInZone)
                
                // Balance indicator bar
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.1))
                        .frame(height: 80)
                    
                    GeometryReader { geo in
                        // Target zone
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.secondaryAccent.opacity(0.25))
                            .frame(
                                width: geo.size.width * CGFloat(targetZone.upperBound - targetZone.lowerBound),
                                height: 70
                            )
                            .offset(x: geo.size.width * CGFloat(targetZone.lowerBound), y: 5)
                        
                        // Zone borders
                        Rectangle()
                            .fill(Theme.secondaryAccent)
                            .frame(width: 3, height: 70)
                            .offset(x: geo.size.width * CGFloat(targetZone.lowerBound), y: 5)
                        
                        Rectangle()
                            .fill(Theme.secondaryAccent)
                            .frame(width: 3, height: 70)
                            .offset(x: geo.size.width * CGFloat(targetZone.upperBound) - 3, y: 5)
                        
                        // Moving orb
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            isInZone ? Theme.secondaryAccent : Theme.primaryAccent,
                                            isInZone ? Theme.secondaryAccent.opacity(0.6) : Theme.primaryAccent.opacity(0.6)
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 30
                                    )
                                )
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .fill(isInZone ? Theme.secondaryAccent : Theme.primaryAccent)
                                .frame(width: 60, height: 60)
                                .blur(radius: 12)
                                .opacity(0.6)
                        }
                        .position(x: max(30, min(geo.size.width - 30, geo.size.width * balance)), y: 40)
                    }
                }
                .frame(height: 80)
                .padding(.horizontal, Theme.padding)
            }
            
            Spacer()
            
            // Control button
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "9D4EDD").opacity(0.8),
                                    Color(hex: "9D4EDD")
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 140, height: 140)
                    
                    if isHolding {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                    }
                    
                    Text("HOLD")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .shadow(color: Color(hex: "9D4EDD").opacity(0.6), radius: isHolding ? 40 : 25)
                .scaleEffect(isHolding ? 0.95 : 1.0)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHolding {
                            isHolding = true
                            let impactLight = UIImpactFeedbackGenerator(style: .light)
                            impactLight.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        isHolding = false
                    }
            )
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
                .frame(height: 60)
        }
    }
    
    var resultsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "9D4EDD"))
                
                Text("Training Complete!")
                    .font(Theme.titleFont)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                StatRow(label: "Balance Score", value: "\(score)", color: Theme.primaryAccent)
                StatRow(label: "Focus Time", value: "\(Int(totalTimeInZone))s", color: Color(hex: "9D4EDD"))
                StatRow(label: "Accuracy", value: "\(balancePercentage)%", color: Theme.secondaryAccent)
                StatRow(label: "Perfect Rounds", value: "\(perfectRounds)/\(maxRounds)", color: Color(hex: "00F5FF"))
                StatRow(label: "Energy Earned", value: "+\(energyFragmentsEarned)", color: Theme.secondaryAccent)
            }
            .padding(.horizontal, Theme.padding)
            
            VStack(spacing: 12) {
                GlowingButton(title: "Train Again", action: {
                    resetGame()
                }, color: Color(hex: "9D4EDD"))
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Menu")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }
    
    func startGame() {
        gameState = .playing
        balance = 0.5
        velocity = 0
        currentRound = 1
        roundTimeRemaining = totalRoundTime
        
        // Set target zone based on difficulty
        let center: CGFloat = 0.5
        let halfZone = difficulty.zoneSize / 2
        targetZone = (center - halfZone)...(center + halfZone)
        
        startRound()
    }
    
    func startRound() {
        roundTimeRemaining = totalRoundTime
        
        roundTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in // ~60fps
            updatePhysics()
        }
    }
    
    func updatePhysics() {
        roundTimeRemaining -= 0.016
        
        // Apply control force when holding
        if isHolding {
            // Move toward center
            if balance < 0.5 {
                velocity += difficulty.controlStrength
            } else if balance > 0.5 {
                velocity -= difficulty.controlStrength
            }
        }
        
        // Apply random drift (simulating instability)
        let drift = CGFloat.random(in: -difficulty.driftSpeed...difficulty.driftSpeed)
        velocity += drift
        
        // Apply damping
        velocity *= 0.95
        
        // Update position
        balance += velocity
        
        // Clamp to bounds with bounce
        if balance < 0 {
            balance = 0
            velocity = abs(velocity) * 0.3
        } else if balance > 1 {
            balance = 1
            velocity = -abs(velocity) * 0.3
        }
        
        // Check if in zone
        let wasInZone = isInZone
        isInZone = targetZone.contains(balance)
        
        if isInZone {
            timeInZone += 0.016
            totalTimeInZone += 0.016
            score += 1
            
            if !wasInZone {
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
            }
        }
        
        if roundTimeRemaining <= 0 {
            finishRound()
        }
    }
    
    func finishRound() {
        roundTimer?.invalidate()
        
        // Check if it was a perfect round (>90% time in zone)
        if timeInZone >= totalRoundTime * 0.9 {
            perfectRounds += 1
            
            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()
        }
        
        timeInZone = 0
        currentRound += 1
        
        if currentRound > maxRounds {
            endRound()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Reset position for next round
                balance = 0.5
                velocity = 0
                startRound()
            }
        }
    }
    
    func endRound() {
        gameState = .results
        
        // Calculate rewards based on difficulty
        let difficultyMultiplier: Int = {
            switch difficulty {
            case .easy: return 1
            case .normal: return 2
            case .hard: return 3
            }
        }()
        
        energyFragmentsEarned = (score / 20 + perfectRounds * 10) * difficultyMultiplier
        
        dataManager.addEnergyFragments(energyFragmentsEarned)
        dataManager.updateCosmicBalanceScore(score, focusTime: Int(totalTimeInZone), accuracy: balancePercentage)
        
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    }
    
    func resetGame() {
        gameState = .ready
        score = 0
        timeInZone = 0
        totalTimeInZone = 0
        currentRound = 1
        perfectRounds = 0
        energyFragmentsEarned = 0
        balance = 0.5
        velocity = 0
        isHolding = false
    }
    
    func endGame() {
        roundTimer?.invalidate()
        roundTimer = nil
    }
}

struct RoundIndicator: View {
    let isComplete: Bool
    let isCurrent: Bool
    let progress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 3)
            
            if isComplete {
                Circle()
                    .fill(Theme.secondaryAccent)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else if isCurrent {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.secondaryAccent, lineWidth: 3)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .frame(width: 30, height: 30)
    }
}
