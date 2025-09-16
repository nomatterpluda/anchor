/*
 * ProjectColors.swift
 * 
 * iOS 26 SYSTEM COLORS UTILITY
 * - Centralized access to iOS 26 system colors in chromatic order
 * - Provides consistent color palette across the entire app
 * - Easy to maintain and extend with new colors
 * - Uses native iOS system colors for proper dark mode support
 */

import SwiftUI

struct ProjectColors {
    
    // MARK: - Color Definitions
    struct ColorInfo {
        let id: String
        let name: String
        let systemColor: Color
    }
    
    // MARK: - iOS 26 System Colors (Chromatic Order)
    static let allColors: [ColorInfo] = [
        ColorInfo(id: "red", name: "Red", systemColor: .red),
        ColorInfo(id: "orange", name: "Orange", systemColor: .orange),
        ColorInfo(id: "yellow", name: "Yellow", systemColor: .yellow),
        ColorInfo(id: "green", name: "Green", systemColor: .green),
        ColorInfo(id: "teal", name: "Teal", systemColor: .teal),
        ColorInfo(id: "blue", name: "Blue", systemColor: .blue),
        ColorInfo(id: "indigo", name: "Indigo", systemColor: .indigo),
        //ColorInfo(id: "purple", name: "Purple", systemColor: .purple),
        //ColorInfo(id: "pink", name: "Pink", systemColor: .pink),
        ColorInfo(id: "brown", name: "Brown", systemColor: .brown),
        ColorInfo(id: "gray", name: "Gray", systemColor: .gray)
        //ColorInfo(id: "mint", name: "Mint", systemColor: .mint)
    ]
    
    // MARK: - Convenience Properties
    static let defaultColor = allColors[0] // Gray
    static let defaultColorID = defaultColor.id
    
    // MARK: - Helper Methods
    
    /// Get color info by ID
    static func colorInfo(for id: String) -> ColorInfo? {
        return allColors.first { $0.id == id }
    }
    
    /// Get SwiftUI Color by ID (with fallback)
    static func swiftUIColor(for id: String) -> Color {
        return colorInfo(for: id)?.systemColor ?? defaultColor.systemColor
    }
    
    /// Get all color IDs in chromatic order
    static var allColorIDs: [String] {
        return allColors.map { $0.id }
    }
    
    /// Check if color ID exists
    static func contains(_ id: String) -> Bool {
        return allColors.contains { $0.id == id }
    }
    
    /// Get random color ID
    static func randomColorID() -> String {
        return allColors.randomElement()?.id ?? defaultColorID
    }
}

// MARK: - Time Block Color Palette
extension ProjectColors {
    
    /// Time block color variants for a given project color
    struct TimeBlockPalette {
        let main: Color      // Project color at 100%
        let mid: Color       // Project color at 20% + black at 30%
        let dark: Color      // Project color at 100% + black at 50%
        let light: Color     // Project color at 20%
    }
    
    /// Get time block color palette for a project color ID
    static func timeBlockPalette(for colorID: String) -> TimeBlockPalette {
        let baseColor = swiftUIColor(for: colorID)
        
        return TimeBlockPalette(
            main: baseColor,                    // Project color at 100%
            mid: baseColor.opacity(0.6),        // Mid-tone version
            dark: baseColor.opacity(0.8),       // Darker version  
            light: baseColor.opacity(0.2)       // Light version (20%)
        )
    }
    
    /// Convenience method to get specific color variant
    enum TimeBlockColorVariant {
        case main, mid, dark, light
    }
    
    static func timeBlockColor(for colorID: String, variant: TimeBlockColorVariant) -> Color {
        let palette = timeBlockPalette(for: colorID)
        
        switch variant {
        case .main:
            return palette.main
        case .mid:
            return palette.mid
        case .dark:
            return palette.dark
        case .light:
            return palette.light
        }
    }
}
