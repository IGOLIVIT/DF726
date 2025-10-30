//
//  StellarReflexGameView.swift
//  Nebula Flow
//

import SwiftUI

struct StellarReflexGameView: View {
    @Binding var selectedGame: MainMenuView.GameType?
    @StateObject private var dataManager = DataManager.shared
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var level = 1
    @State private var difficulty: Difficulty = .normal
    @State private var targetPosition: CGPoint = .zero
    @State private var targetAppearTime: Date?
    @State private var reactionTimes: [TimeInterval] = []
    @State private var showTarget = false
    @State private var targetColor: Color = Theme.primaryAccent
    @State private var countdown = 3
    @State private var showCountdown = false
    @State private var gameTimer: Timer?
    @State private var roundsPlayed = 0
    @State private var maxRounds = 10
    @State private var showResultsView = false
    @State private var energyFragmentsEarned = 0
    @Environment(\.presentationMode) var presentationMode
    
    enum GameState {
        case ready, countdown, playing, results
    }
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
        
        var targetSize: CGFloat {
            switch self {
            case .easy: return 90
            case .normal: return 70
            case .hard: return 50
            }
        }
        
        var delayRange: ClosedRange<Double> {
            switch self {
            case .easy: return 1.5...3.0
            case .normal: return 1.0...2.5
            case .hard: return 0.6...2.0
            }
        }
        
        var color: Color {
            switch self {
            case .easy: return Color(hex: "00F5FF")
            case .normal: return Theme.secondaryAccent
            case .hard: return Theme.primaryAccent
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
    
    var averageReactionTime: Int {
        guard !reactionTimes.isEmpty else { return 0 }
        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        return Int(avg * 1000) // Convert to milliseconds
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
                        
                        Text("Round \(roundsPlayed)/\(maxRounds)")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 50)
                
                Spacer()
            }
            
            // Game area
            if gameState == .ready {
                readyView
            } else if gameState == .countdown {
                countdownView
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
                Image(systemName: "bolt.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.secondaryAccent)
                
                Text("Stellar Reflex")
                    .font(Theme.titleFont)
                    .foregroundColor(.white)
                
                Text("Tap the glowing targets as fast as you can!\nTest your reaction speed.")
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
            
            GlowingButton(title: "Start Challenge", action: {
                startGame()
            }, color: Theme.secondaryAccent)
            .padding(.horizontal, Theme.padding)
        }
    }
    
    var countdownView: some View {
        VStack {
            Text("\(countdown)")
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundColor(Theme.secondaryAccent)
                .shadow(color: Theme.secondaryAccent.opacity(0.8), radius: 30)
            
            Text("Get Ready!")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
        }
    }
    
    var playingView: some View {
        GeometryReader { geometry in
            ZStack {
                if showTarget {
                    Button(action: {
                        targetTapped()
                    }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                targetColor.opacity(0.9),
                                                targetColor.opacity(0.6),
                                                targetColor
                                            ]),
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: difficulty.targetSize / 2
                                        )
                                    )
                                    .frame(width: difficulty.targetSize, height: difficulty.targetSize)
                                
                                Circle()
                                    .fill(targetColor)
                                    .blur(radius: 20)
                                    .frame(width: difficulty.targetSize, height: difficulty.targetSize)
                                    .opacity(0.6)
                                
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: difficulty.targetSize * 0.375))
                                    .foregroundColor(.white)
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .position(targetPosition)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Instructions
                if !showTarget && roundsPlayed < maxRounds {
                    VStack {
                        Spacer()
                        Text("Wait for the target...")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.bottom, 100)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                startRound(in: geometry.size)
            }
        }
    }
    
    var resultsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.secondaryAccent)
                
                Text("Challenge Complete!")
                    .font(Theme.titleFont)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                StatRow(label: "Score", value: "\(score)", color: Theme.primaryAccent)
                StatRow(label: "Avg Reaction", value: "\(averageReactionTime)ms", color: Theme.secondaryAccent)
                StatRow(label: "Best Reaction", value: "\(Int((reactionTimes.min() ?? 0) * 1000))ms", color: Color(hex: "00F5FF"))
                StatRow(label: "Energy Earned", value: "+\(energyFragmentsEarned)", color: Theme.secondaryAccent)
            }
            .padding(.horizontal, Theme.padding)
            
            VStack(spacing: 12) {
                GlowingButton(title: "Play Again", action: {
                    resetGame()
                }, color: Theme.secondaryAccent)
                
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
        gameState = .countdown
        countdown = 3
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdown -= 1
            
            if countdown == 0 {
                timer.invalidate()
                gameState = .playing
            }
        }
    }
    
    func startRound(in size: CGSize) {
        guard roundsPlayed < maxRounds else {
            showResults()
            return
        }
        
        let delay = Double.random(in: difficulty.delayRange)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard gameState == .playing else { return }
            
            // Random position with padding
            let padding: CGFloat = difficulty.targetSize + 20
            targetPosition = CGPoint(
                x: CGFloat.random(in: padding...(size.width - padding)),
                y: CGFloat.random(in: (padding + 100)...(size.height - padding - 100))
            )
            
            // Random color for variety
            targetColor = [Theme.primaryAccent, Theme.secondaryAccent, Color(hex: "00F5FF"), Color(hex: "9D4EDD")].randomElement() ?? Theme.primaryAccent
            
            targetAppearTime = Date()
            
            withAnimation(.spring()) {
                showTarget = true
            }
            
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }
    }
    
    func targetTapped() {
        guard let appearTime = targetAppearTime else { return }
        
        let reactionTime = Date().timeIntervalSince(appearTime)
        reactionTimes.append(reactionTime)
        
        // Calculate score based on reaction time
        let points = max(1, Int((1.0 - min(reactionTime, 1.0)) * 100))
        score += points
        
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
        
        withAnimation(.easeOut(duration: 0.2)) {
            showTarget = false
        }
        
        roundsPlayed += 1
        
        // Level up every 3 rounds
        if roundsPlayed % 3 == 0 {
            level += 1
        }
        
        if roundsPlayed < maxRounds {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let size = UIScreen.main.bounds.size as CGSize? {
                    startRound(in: size)
                }
            }
        } else {
            showResults()
        }
    }
    
    func showResults() {
        gameState = .results
        
        // Calculate energy fragments based on performance and difficulty
        energyFragmentsEarned = (score / 10 + level * 5) * difficulty.energyMultiplier
        
        dataManager.addEnergyFragments(energyFragmentsEarned)
        dataManager.updateStellarReflexScore(score, avgReaction: averageReactionTime)
        
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    }
    
    func resetGame() {
        gameState = .ready
        score = 0
        level = 1
        reactionTimes = []
        roundsPlayed = 0
        showTarget = false
        showResultsView = false
        energyFragmentsEarned = 0
    }
    
    func endGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.bodyFont)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(Theme.headlineFont)
                .foregroundColor(color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

