//
//  StatisticsView.swift
//  Nebula Flow
//

import SwiftUI

struct StatisticsView: View {
    @Binding var showStats: Bool
    @StateObject private var dataManager = DataManager.shared
    @State private var showResetAlert = false
    @State private var pulseAnimation = false
    @State private var selectedTab = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    // Top bar
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
                        
                        Text("Nebula Stats")
                            .font(Theme.headlineFont)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, Theme.padding)
                    .padding(.top, 50)
                    
                    // Nebula Core visualization with total energy
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
                                .frame(width: 150 - CGFloat(index * 30), height: 150 - CGFloat(index * 30))
                                .rotationEffect(.degrees(Double(index) * 120))
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
                                    endRadius: 60
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 15)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                            
                            Text("\(dataManager.energyFragments)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Energy")
                                .font(Theme.captionFont)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 20)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            pulseAnimation = true
                        }
                    }
                    
                    // Tab selector
                    HStack(spacing: 12) {
                        TabButton(title: "Overview", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "Games", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    .padding(.horizontal, Theme.padding)
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        overviewTab
                    } else {
                        gamesTab
                    }
                    
                    // Reset button
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Progress")
                        }
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(.white.opacity(0.2), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, Theme.padding)
                    .padding(.top, 20)
                    .alert(isPresented: $showResetAlert) {
                        Alert(
                            title: Text("Reset Progress"),
                            message: Text("Are you sure you want to reset all your progress? This action cannot be undone."),
                            primaryButton: .destructive(Text("Reset")) {
                                dataManager.resetProgress()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    var overviewTab: some View {
        VStack(spacing: 16) {
            // Main stats
            HStack(spacing: 12) {
                CompactStatCard(
                    title: "Total Games",
                    value: "\(dataManager.totalGamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: Theme.primaryAccent
                )
                
                CompactStatCard(
                    title: "Days Active",
                    value: "\(dataManager.daysActive())",
                    icon: "calendar",
                    color: Theme.secondaryAccent
                )
            }
            .padding(.horizontal, Theme.padding)
            
            // Streaks section
            VStack(spacing: 12) {
                SectionHeader(title: "Discipline Tracking", icon: "flame.fill")
                
                HStack(spacing: 12) {
                    StreakCard(
                        title: "Current",
                        value: "\(dataManager.currentStreak)",
                        subtitle: "days",
                        color: Theme.primaryAccent
                    )
                    
                    StreakCard(
                        title: "Best",
                        value: "\(dataManager.bestStreak)",
                        subtitle: "days",
                        color: Theme.secondaryAccent
                    )
                }
            }
            .padding(.horizontal, Theme.padding)
            
            // Performance metrics
            VStack(spacing: 12) {
                SectionHeader(title: "Performance", icon: "chart.line.uptrend.xyaxis")
                
                StatCard(
                    title: "Focus Level",
                    value: "\(dataManager.averageFocusLevel())%",
                    icon: "brain.head.profile",
                    color: Color(hex: "00F5FF")
                )
                
                StatCard(
                    title: "Total Energy Earned",
                    value: "\(dataManager.totalEnergyEarned)",
                    icon: "star.fill",
                    color: Theme.secondaryAccent
                )
                
                StatCard(
                    title: "Favorite Game",
                    value: dataManager.favoriteGame,
                    icon: "heart.fill",
                    color: Color(hex: "9D4EDD")
                )
            }
            .padding(.horizontal, Theme.padding)
            
            // Quick game stats
            VStack(spacing: 12) {
                SectionHeader(title: "Quick Stats", icon: "sparkles")
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    QuickStatCard(
                        label: "Best Reaction",
                        value: dataManager.stellarReflexBestReaction == 9999 ? "N/A" : "\(dataManager.stellarReflexBestReaction)ms",
                        color: Theme.secondaryAccent
                    )
                    
                    QuickStatCard(
                        label: "Best Accuracy",
                        value: dataManager.cosmicBalanceBestAccuracy == 0 ? "N/A" : "\(dataManager.cosmicBalanceBestAccuracy)%",
                        color: Color(hex: "9D4EDD")
                    )
                    
                    QuickStatCard(
                        label: "Total Focus",
                        value: "\(dataManager.cosmicBalanceTotalFocusTime)s",
                        color: Color(hex: "00F5FF")
                    )
                    
                    QuickStatCard(
                        label: "High Scores",
                        value: "\(max(dataManager.spaceAttackHighScore, dataManager.mindOrbitHighScore, dataManager.stellarReflexHighScore, dataManager.cosmicBalanceHighScore))",
                        color: Theme.primaryAccent
                    )
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }
    
    var gamesTab: some View {
        VStack(spacing: 16) {
            // Space Attack
            GameDetailCard(
                title: "Space Attack",
                icon: "sparkles",
                color: Theme.primaryAccent,
                highScore: dataManager.spaceAttackHighScore,
                gamesPlayed: dataManager.spaceAttackGamesPlayed,
                avgScore: dataManager.spaceAttackGamesPlayed > 0 ? dataManager.spaceAttackTotalScore / dataManager.spaceAttackGamesPlayed : 0
            )
            
            // Mind Orbit
            GameDetailCard(
                title: "Mind Orbit",
                icon: "brain.head.profile",
                color: Theme.secondaryAccent,
                highScore: dataManager.mindOrbitHighScore,
                gamesPlayed: dataManager.mindOrbitGamesPlayed,
                avgScore: dataManager.mindOrbitGamesPlayed > 0 ? dataManager.mindOrbitTotalScore / dataManager.mindOrbitGamesPlayed : 0
            )
            
            // Stellar Reflex
            StellarReflexDetailCard(
                dataManager: dataManager
            )
            
            // Cosmic Balance
            CosmicBalanceDetailCard(
                dataManager: dataManager
            )
        }
        .padding(.horizontal, Theme.padding)
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.bodyFont)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(isSelected ? Theme.primaryAccent.opacity(0.3) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(isSelected ? Theme.primaryAccent : .white.opacity(0.2), lineWidth: 2)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.secondaryAccent)
            
            Text(title)
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

struct CompactStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

struct StreakCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.white.opacity(0.7))
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(Theme.captionFont)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

struct QuickStatCard: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(Theme.captionFont)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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

struct GameDetailCard: View {
    let title: String
    let icon: String
    let color: Color
    let highScore: Int
    let gamesPlayed: Int
    let avgScore: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(title)
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("High Score")
                        .font(Theme.captionFont)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(highScore)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Games")
                        .font(Theme.captionFont)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(gamesPlayed)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average")
                        .font(Theme.captionFont)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(avgScore)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

struct StellarReflexDetailCard: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Theme.secondaryAccent)
                
                Text("Stellar Reflex")
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("High Score")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(dataManager.stellarReflexHighScore)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.secondaryAccent)
                }
                
                HStack {
                    Text("Best Reaction")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(dataManager.stellarReflexBestReaction == 9999 ? "N/A" : "\(dataManager.stellarReflexBestReaction)ms")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.secondaryAccent)
                }
                
                HStack {
                    Text("Avg Reaction")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(dataManager.stellarReflexAvgReaction == 0 ? "N/A" : "\(dataManager.stellarReflexAvgReaction)ms")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Games Played")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(dataManager.stellarReflexGamesPlayed)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.secondaryAccent.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.secondaryAccent.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

struct CosmicBalanceDetailCard: View {
    @ObservedObject var dataManager: DataManager
    let balanceColor = Color(hex: "9D4EDD")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "circle.circle")
                    .font(.system(size: 28))
                    .foregroundColor(balanceColor)
                
                Text("Cosmic Balance")
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("High Score")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(dataManager.cosmicBalanceHighScore)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(balanceColor)
                }
                
                HStack {
                    Text("Best Accuracy")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(dataManager.cosmicBalanceBestAccuracy)%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(balanceColor)
                }
                
                HStack {
                    Text("Total Focus Time")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(dataManager.cosmicBalanceTotalFocusTime)s")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Games Played")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(dataManager.cosmicBalanceGamesPlayed)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(balanceColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(balanceColor.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.captionFont)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

