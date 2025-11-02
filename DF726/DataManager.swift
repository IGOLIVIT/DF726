//
//  DataManager.swift
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    // Core stats
    @Published var energyFragments: Int = 0
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var totalGamesPlayed: Int = 0
    @Published var totalPlayTime: TimeInterval = 0
    @Published var lastPlayedDate: Date?
    @Published var firstPlayedDate: Date?
    
    // Game-specific stats
    @Published var spaceAttackHighScore: Int = 0
    @Published var spaceAttackGamesPlayed: Int = 0
    @Published var spaceAttackTotalScore: Int = 0
    
    @Published var mindOrbitHighScore: Int = 0
    @Published var mindOrbitGamesPlayed: Int = 0
    @Published var mindOrbitTotalScore: Int = 0
    
    @Published var stellarReflexHighScore: Int = 0
    @Published var stellarReflexGamesPlayed: Int = 0
    @Published var stellarReflexBestReaction: Int = 9999
    @Published var stellarReflexAvgReaction: Int = 0
    @Published var stellarReflexTotalScore: Int = 0
    
    @Published var cosmicBalanceHighScore: Int = 0
    @Published var cosmicBalanceGamesPlayed: Int = 0
    @Published var cosmicBalanceBestAccuracy: Int = 0
    @Published var cosmicBalanceTotalFocusTime: Int = 0
    @Published var cosmicBalanceTotalScore: Int = 0
    
    // Achievement tracking
    @Published var perfectRounds: Int = 0
    @Published var totalEnergyEarned: Int = 0
    @Published var favoriteGame: String = "None"
    
    private let defaults = UserDefaults.standard
    
    private init() {
        loadData()
        checkStreak()
    }
    
    func loadData() {
        // Core stats
        energyFragments = defaults.integer(forKey: "energyFragments")
        currentStreak = defaults.integer(forKey: "currentStreak")
        bestStreak = defaults.integer(forKey: "bestStreak")
        totalGamesPlayed = defaults.integer(forKey: "totalGamesPlayed")
        totalPlayTime = defaults.double(forKey: "totalPlayTime")
        totalEnergyEarned = defaults.integer(forKey: "totalEnergyEarned")
        perfectRounds = defaults.integer(forKey: "perfectRounds")
        favoriteGame = defaults.string(forKey: "favoriteGame") ?? "None"
        
        // Space Attack
        spaceAttackHighScore = defaults.integer(forKey: "spaceAttackHighScore")
        spaceAttackGamesPlayed = defaults.integer(forKey: "spaceAttackGamesPlayed")
        spaceAttackTotalScore = defaults.integer(forKey: "spaceAttackTotalScore")
        
        // Mind Orbit
        mindOrbitHighScore = defaults.integer(forKey: "mindOrbitHighScore")
        mindOrbitGamesPlayed = defaults.integer(forKey: "mindOrbitGamesPlayed")
        mindOrbitTotalScore = defaults.integer(forKey: "mindOrbitTotalScore")
        
        // Stellar Reflex
        stellarReflexHighScore = defaults.integer(forKey: "stellarReflexHighScore")
        stellarReflexGamesPlayed = defaults.integer(forKey: "stellarReflexGamesPlayed")
        stellarReflexBestReaction = defaults.integer(forKey: "stellarReflexBestReaction") == 0 ? 9999 : defaults.integer(forKey: "stellarReflexBestReaction")
        stellarReflexAvgReaction = defaults.integer(forKey: "stellarReflexAvgReaction")
        stellarReflexTotalScore = defaults.integer(forKey: "stellarReflexTotalScore")
        
        // Cosmic Balance
        cosmicBalanceHighScore = defaults.integer(forKey: "cosmicBalanceHighScore")
        cosmicBalanceGamesPlayed = defaults.integer(forKey: "cosmicBalanceGamesPlayed")
        cosmicBalanceBestAccuracy = defaults.integer(forKey: "cosmicBalanceBestAccuracy")
        cosmicBalanceTotalFocusTime = defaults.integer(forKey: "cosmicBalanceTotalFocusTime")
        cosmicBalanceTotalScore = defaults.integer(forKey: "cosmicBalanceTotalScore")
        
        // Dates
        if let dateString = defaults.string(forKey: "lastPlayedDate") {
            let formatter = ISO8601DateFormatter()
            lastPlayedDate = formatter.date(from: dateString)
        }
        
        if let dateString = defaults.string(forKey: "firstPlayedDate") {
            let formatter = ISO8601DateFormatter()
            firstPlayedDate = formatter.date(from: dateString)
        }
    }
    
    func saveData() {
        // Core stats
        defaults.set(energyFragments, forKey: "energyFragments")
        defaults.set(currentStreak, forKey: "currentStreak")
        defaults.set(bestStreak, forKey: "bestStreak")
        defaults.set(totalGamesPlayed, forKey: "totalGamesPlayed")
        defaults.set(totalPlayTime, forKey: "totalPlayTime")
        defaults.set(totalEnergyEarned, forKey: "totalEnergyEarned")
        defaults.set(perfectRounds, forKey: "perfectRounds")
        defaults.set(favoriteGame, forKey: "favoriteGame")
        
        // Space Attack
        defaults.set(spaceAttackHighScore, forKey: "spaceAttackHighScore")
        defaults.set(spaceAttackGamesPlayed, forKey: "spaceAttackGamesPlayed")
        defaults.set(spaceAttackTotalScore, forKey: "spaceAttackTotalScore")
        
        // Mind Orbit
        defaults.set(mindOrbitHighScore, forKey: "mindOrbitHighScore")
        defaults.set(mindOrbitGamesPlayed, forKey: "mindOrbitGamesPlayed")
        defaults.set(mindOrbitTotalScore, forKey: "mindOrbitTotalScore")
        
        // Stellar Reflex
        defaults.set(stellarReflexHighScore, forKey: "stellarReflexHighScore")
        defaults.set(stellarReflexGamesPlayed, forKey: "stellarReflexGamesPlayed")
        defaults.set(stellarReflexBestReaction, forKey: "stellarReflexBestReaction")
        defaults.set(stellarReflexAvgReaction, forKey: "stellarReflexAvgReaction")
        defaults.set(stellarReflexTotalScore, forKey: "stellarReflexTotalScore")
        
        // Cosmic Balance
        defaults.set(cosmicBalanceHighScore, forKey: "cosmicBalanceHighScore")
        defaults.set(cosmicBalanceGamesPlayed, forKey: "cosmicBalanceGamesPlayed")
        defaults.set(cosmicBalanceBestAccuracy, forKey: "cosmicBalanceBestAccuracy")
        defaults.set(cosmicBalanceTotalFocusTime, forKey: "cosmicBalanceTotalFocusTime")
        defaults.set(cosmicBalanceTotalScore, forKey: "cosmicBalanceTotalScore")
        
        // Dates
        if let date = lastPlayedDate {
            let formatter = ISO8601DateFormatter()
            defaults.set(formatter.string(from: date), forKey: "lastPlayedDate")
        }
        
        if let date = firstPlayedDate {
            let formatter = ISO8601DateFormatter()
            defaults.set(formatter.string(from: date), forKey: "firstPlayedDate")
        }
        
        updateFavoriteGame()
    }
    
    func checkStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastPlayed = lastPlayedDate {
            let lastPlayedDay = calendar.startOfDay(for: lastPlayed)
            let daysDifference = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                return
            } else if daysDifference == 1 {
                currentStreak += 1
                if currentStreak > bestStreak {
                    bestStreak = currentStreak
                }
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        lastPlayedDate = Date()
        
        if firstPlayedDate == nil {
            firstPlayedDate = Date()
        }
        
        saveData()
    }
    
    func addEnergyFragments(_ amount: Int) {
        energyFragments += amount
        totalEnergyEarned += amount
        totalGamesPlayed += 1
        checkStreak()
        saveData()
    }
    
    func updateSpaceAttackScore(_ score: Int) {
        spaceAttackGamesPlayed += 1
        spaceAttackTotalScore += score
        
        if score > spaceAttackHighScore {
            spaceAttackHighScore = score
        }
        saveData()
    }
    
    func updateMindOrbitScore(_ score: Int) {
        mindOrbitGamesPlayed += 1
        mindOrbitTotalScore += score
        
        if score > mindOrbitHighScore {
            mindOrbitHighScore = score
        }
        saveData()
    }
    
    func updateStellarReflexScore(_ score: Int, avgReaction: Int) {
        stellarReflexGamesPlayed += 1
        stellarReflexTotalScore += score
        
        if score > stellarReflexHighScore {
            stellarReflexHighScore = score
        }
        
        if avgReaction < stellarReflexBestReaction {
            stellarReflexBestReaction = avgReaction
        }
        
        // Update average reaction time
        if stellarReflexAvgReaction == 0 {
            stellarReflexAvgReaction = avgReaction
        } else {
            stellarReflexAvgReaction = (stellarReflexAvgReaction + avgReaction) / 2
        }
        
        saveData()
    }
    
    func updateCosmicBalanceScore(_ score: Int, focusTime: Int, accuracy: Int) {
        cosmicBalanceGamesPlayed += 1
        cosmicBalanceTotalScore += score
        cosmicBalanceTotalFocusTime += focusTime
        
        if score > cosmicBalanceHighScore {
            cosmicBalanceHighScore = score
        }
        
        if accuracy > cosmicBalanceBestAccuracy {
            cosmicBalanceBestAccuracy = accuracy
        }
        
        saveData()
    }
    
    func updateFavoriteGame() {
        let games = [
            ("Space Attack", spaceAttackGamesPlayed),
            ("Mind Orbit", mindOrbitGamesPlayed),
            ("Stellar Reflex", stellarReflexGamesPlayed),
            ("Cosmic Balance", cosmicBalanceGamesPlayed)
        ]
        
        if let favorite = games.max(by: { $0.1 < $1.1 }), favorite.1 > 0 {
            favoriteGame = favorite.0
        }
    }
    
    func averageFocusLevel() -> Int {
        guard totalGamesPlayed > 0 else { return 0 }
        
        let totalScore = spaceAttackTotalScore + mindOrbitTotalScore + stellarReflexTotalScore + cosmicBalanceTotalScore
        let avgScore = totalScore / totalGamesPlayed
        
        return min(100, max(0, avgScore / 10))
    }
    
    func daysActive() -> Int {
        guard let first = firstPlayedDate else { return 0 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: first, to: Date()).day ?? 0
        return max(1, days + 1)
    }
    
    func resetProgress() {
        energyFragments = 0
        currentStreak = 0
        bestStreak = 0
        totalGamesPlayed = 0
        totalPlayTime = 0
        totalEnergyEarned = 0
        perfectRounds = 0
        favoriteGame = "None"
        
        spaceAttackHighScore = 0
        spaceAttackGamesPlayed = 0
        spaceAttackTotalScore = 0
        
        mindOrbitHighScore = 0
        mindOrbitGamesPlayed = 0
        mindOrbitTotalScore = 0
        
        stellarReflexHighScore = 0
        stellarReflexGamesPlayed = 0
        stellarReflexBestReaction = 9999
        stellarReflexAvgReaction = 0
        stellarReflexTotalScore = 0
        
        cosmicBalanceHighScore = 0
        cosmicBalanceGamesPlayed = 0
        cosmicBalanceBestAccuracy = 0
        cosmicBalanceTotalFocusTime = 0
        cosmicBalanceTotalScore = 0
        
        lastPlayedDate = nil
        firstPlayedDate = nil
        
        saveData()
    }
}

