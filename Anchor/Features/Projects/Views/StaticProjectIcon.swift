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
    let isMenuPresented: Bool
    let dragProgress: CGFloat // 0-1 progress for stroke animation
    
    private var iconColor: Color {
        // Handle "All" project case (nil) - use gray as default
        guard let project = project else { return .allProjectColor }
        return project.swiftUIColor
    }
    
    private var iconName: String {
        // Show x when menu is open
        if isMenuPresented {
            return "xmark"
        }
        
        // Show plus when dragging (any progress > 0)
        if dragProgress > 0 {
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
        ZStack {
            // Background circle
            Circle()
                .fill(dragProgress > 0 ? .clear : iconColor)
                .frame(width: 34, height: 34)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: iconColor)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragProgress)
            
            // Progressive stroke - always present but with conditional opacity
            Circle()
                .trim(from: 0, to: dragProgress)
                .stroke(.white, lineWidth: 2)
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(-90)) // Start from top
                .opacity(dragProgress > 0 ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragProgress)
            
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(dragProgress > 0 ? .white : .white)
                .scaleEffect(iconScale)
                .animation(.snappy(duration: 0.3), value: iconName)
                .animation(.snappy(duration: 0.2), value: iconScale)
        }
    }
}

#Preview {
    StaticProjectIcon(project: nil, isThresholdReached: false, isMenuPresented: false, dragProgress: 0.5)
        .background(.black)
}
