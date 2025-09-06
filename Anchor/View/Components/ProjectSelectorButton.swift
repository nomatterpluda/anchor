/*
 * ProjectSelectorButton.swift
 * 
 * INDIVIDUAL PROJECT BUTTON COMPONENT
 * - Displays project icon in colored circular background
 * - Shows project name with dynamic styling based on selection state
 * - Selected: Full color circle with white icon, white text
 * - Unselected: Semi-transparent circle with colored icon, muted text
 * - Reusable component used by ProjectSelectorBar
 */

import SwiftUI

struct ProjectSelectorButton: View {
    let name: String
    let icon: String
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    private var iconColor: Color {
        switch color {
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
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Circular icon background
                Circle()
                    .fill(isSelected ? iconColor : iconColor.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(isSelected ? .white : iconColor)
                    )
                
                Text(name)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}