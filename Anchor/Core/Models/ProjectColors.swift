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
