/*
 * ProjectColorEnvironment.swift
 * 
 * SHARED PROJECT COLOR SYSTEM
 * - Environment key for passing accent color down component tree  
 * - ProjectModel extension for consistent color conversion
 * - Used by both StaticProjectIcon and todo list components
 */

import SwiftUI

// MARK: - Environment Key
struct AccentColorEnvironmentKey: EnvironmentKey {
    static let defaultValue: Color = .blue
}

extension EnvironmentValues {
    var accentColor: Color {
        get { self[AccentColorEnvironmentKey.self] }
        set { self[AccentColorEnvironmentKey.self] = newValue }
    }
}

// MARK: - ProjectModel Color Extension
extension ProjectModel {
    /// Converts project color string to SwiftUI Color
    /// Used by both StaticProjectIcon and todo list accent colors
    var swiftUIColor: Color {
        switch projectColor {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "yellow": return .yellow
        case "pink": return .pink
        case "gray": return .gray
        default: return .blue
        }
    }
}

// MARK: - Helper for "All" Projects
extension Color {
    /// Default color for "All" project (when project is nil)
    static var allProjectColor: Color { .gray }
}