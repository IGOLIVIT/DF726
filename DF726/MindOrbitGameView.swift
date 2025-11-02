//
//  MindOrbitGameView.swift
//

import SwiftUI

struct MindOrbitGameView: View {
    @Binding var selectedGame: MainMenuView.GameType?
    @StateObject private var dataManager = DataManager.shared
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var level = 1
    @State private var difficulty: Difficulty = .normal
    @State private var pattern: [Int] = []
    @State private var userPattern: [Int] = []
    @State private var showPattern = false
    @State private var canInput = false
    @State private var highlightedIndex: Int? = nil
    @State private var showLevelUp = false
    @State private var energyFragmentsEarned = 0
    @Environment(\.presentationMode) var presentationMode
    
    enum GameState {
        case ready, showing, input, correct, wrong
    }
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
        
        var patternBase: Int {
            switch self {
            case .easy: return 2
            case .normal: return 3
            case .hard: return 4
            }
        }
        
        var showSpeed: Double {
            switch self {
            case .easy: return 1.0
            case .normal: return 0.8
            case .hard: return 0.6
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
    
    let gridSize = 4
    let colors: [Color] = [
        Theme.primaryAccent,
        Theme.secondaryAccent,
        Color(hex: "9D4EDD"),
        Color(hex: "00F5FF")
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    // Top HUD
                    HStack {
                        Button(action: {
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
                        .frame(height: 40)
                    
                    // Difficulty selector (only show when ready)
                    if gameState == .ready {
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
                        .padding(.bottom, 16)
                    }
                    
                    // Instructions
                    Text(instructionText)
                        .font(Theme.bodyFont)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.padding)
                        .frame(minHeight: 60)
                    
                    // Game grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: gridSize), spacing: 16) {
                        ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                            GameCell(
                                index: index,
                                color: colors[index % colors.count],
                                isHighlighted: highlightedIndex == index,
                                isEnabled: canInput
                            ) {
                                handleCellTap(index: index)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.padding)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Start button
                    if gameState == .ready || gameState == .correct || gameState == .wrong {
                        GlowingButton(
                            title: gameState == .ready ? "Start" : "Next Level",
                            action: startRound,
                            color: gameState == .wrong ? Theme.primaryAccent : Theme.secondaryAccent
                        )
                        .padding(.horizontal, Theme.padding)
                    }
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
            
            // Level up overlay
            if showLevelUp {
                LevelUpOverlay(level: level, energyFragments: energyFragmentsEarned)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
    }
    
    var instructionText: String {
        switch gameState {
        case .ready:
            return "Watch the pattern and repeat it"
        case .showing:
            return "Watch carefully..."
        case .input:
            return "Repeat the pattern"
        case .correct:
            return "Correct! Well done."
        case .wrong:
            return "Incorrect. Try again."
        }
    }
    
    func startRound() {
        gameState = .showing
        userPattern = []
        generatePattern()
        showPatternSequence()
    }
    
    func generatePattern() {
        pattern = []
        let patternLength = difficulty.patternBase + level
        for _ in 0..<patternLength {
            pattern.append(Int.random(in: 0..<(gridSize * gridSize)))
        }
    }
    
    func showPatternSequence() {
        var delay = 0.5
        let highlightDuration = difficulty.showSpeed * 0.6
        let pauseDuration = difficulty.showSpeed * 0.4
        
        for (_, cell) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                highlightCell(cell)
            }
            delay += highlightDuration
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                highlightedIndex = nil
            }
            delay += pauseDuration
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            canInput = true
            gameState = .input
        }
    }
    
    func highlightCell(_ index: Int) {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        highlightedIndex = index
    }
    
    func handleCellTap(index: Int) {
        guard canInput else { return }
        
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
        
        highlightCell(index)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            highlightedIndex = nil
        }
        
        userPattern.append(index)
        
        // Check if pattern matches so far
        if userPattern.count <= pattern.count {
            if userPattern[userPattern.count - 1] != pattern[userPattern.count - 1] {
                // Wrong
                patternFailed()
                return
            }
            
            if userPattern.count == pattern.count {
                // Complete and correct
                patternCompleted()
            }
        }
    }
    
    func patternCompleted() {
        canInput = false
        gameState = .correct
        
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
        
        score += 10 * level * difficulty.energyMultiplier
        level += 1
        energyFragmentsEarned = level * 3 * difficulty.energyMultiplier
        
        dataManager.updateMindOrbitScore(score)
        dataManager.addEnergyFragments(energyFragmentsEarned)
        
        withAnimation(.spring()) {
            showLevelUp = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut) {
                showLevelUp = false
            }
        }
    }
    
    func patternFailed() {
        canInput = false
        gameState = .wrong
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
        
        // Don't reset level, just retry
    }
}

struct GameCell: View {
    let index: Int
    let color: Color
    let isHighlighted: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(
                    isHighlighted ?
                    color :
                    color.opacity(0.3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(color, lineWidth: 2)
                )
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: isHighlighted ? color.opacity(0.8) : color.opacity(0.3), radius: isHighlighted ? 20 : 10)
                .scaleEffect(isHighlighted ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHighlighted)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

