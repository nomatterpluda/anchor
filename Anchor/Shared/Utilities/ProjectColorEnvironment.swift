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
    /// Converts project color string to SwiftUI Color using iOS 26 system colors
    /// Used by both StaticProjectIcon and todo list accent colors
    var swiftUIColor: Color {
        return ProjectColors.swiftUIColor(for: projectColor)
    }
}

// MARK: - Helper for "All" Projects
extension Color {
    /// Default color for "All" project (when project is nil)
    static var allProjectColor: Color { .gray }
}