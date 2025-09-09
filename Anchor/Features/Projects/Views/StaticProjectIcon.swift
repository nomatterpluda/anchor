/*
 * StaticProjectIcon.swift
 * 
 * STATIC PROJECT ICON COMPONENT
 * - Shows the currently selected project's icon and color from ProjectModel
 * - 34px circle with 18px SF Symbol centered
 * - Does not scroll, remains fixed on the left side
 * - Handles both "All" project (nil) and individual projects
 * - Gets data directly from stored ProjectModel information
 */

import SwiftUI

struct StaticProjectIcon: View {
    let project: ProjectModel?
    let isThresholdReached: Bool
    
    private var iconColor: Color {
        // Handle "All" project case (nil) - use gray as default
        guard let project = project else { return .allProjectColor }
        return project.swiftUIColor
    }
    
    private var iconName: String {
        // Show plus when threshold is reached
        if isThresholdReached {
            return "plus"
        }
        
        // Handle "All" project case (nil) - use tray.fill as default
        // Otherwise use the stored projectIcon from the model
        return project?.projectIcon ?? "tray.fill"
    }
    
    private var iconScale: Double {
        // Make plus icon slightly larger for better visibility
        return isThresholdReached ? 1.3 : 1.1
    }
    
    var body: some View {
        Circle()
            .fill(iconColor)
            .frame(width: 34, height: 34)
            .animation(.snappy(duration: 0.3), value: iconColor)
            .overlay(
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(iconScale)
                    .animation(.snappy(duration: 0.3), value: iconName)
                    .animation(.snappy(duration: 0.2), value: iconScale)
            )
    }
}

#Preview {
    StaticProjectIcon(project: nil, isThresholdReached: false)
        .background(.black)
}
