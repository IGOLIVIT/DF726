//
//  Theme.swift
//  Nebula Flow
//

import SwiftUI

struct Theme {
    // Color Palette - Mellstroy-inspired
    static let background = Color(hex: "0E0E10")
    static let primaryAccent = Color(hex: "FF003C")
    static let secondaryAccent = Color(hex: "FFD000")
    
    // Typography
    static let titleFont = Font.system(size: 32, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 24, weight: .bold, design: .rounded)
    static let bodyFont = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
    
    // Layout
    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 60
    static let spacing: CGFloat = 20
    static let padding: CGFloat = 24
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

