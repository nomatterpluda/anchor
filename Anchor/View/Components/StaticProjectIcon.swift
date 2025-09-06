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
    
    private var iconColor: Color {
        // Handle "All" project case (nil) - use gray as default
        guard let colorString = project?.projectColor else { return .gray }
        
        switch colorString {
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
    
    private var iconName: String {
        // Handle "All" project case (nil) - use tray.fill as default
        // Otherwise use the stored projectIcon from the model
        return project?.projectIcon ?? "tray.fill"
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
                    .scaleEffect(1.1)
                    .animation(.snappy(duration: 0.3), value: iconName)
            )
    }
}

#Preview {
    StaticProjectIcon(project: nil)
        .background(.black)
}
