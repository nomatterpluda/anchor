/*
 * IconGridItem.swift
 * 
 * ICON GRID PICKER ITEM COMPONENT
 * - SF Symbol picker item for AddProjectSheet icon selection
 * - Square button with SF symbol inside
 * - Selection state with background and scale animation
 * - Haptic feedback on tap
 */

import SwiftUI

struct IconGridItem: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.15) : Color.clear)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.snappy(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
        IconGridItem(icon: "folder.fill", isSelected: true) {}
        IconGridItem(icon: "doc.fill", isSelected: false) {}
        IconGridItem(icon: "bookmark.fill", isSelected: false) {}
        IconGridItem(icon: "star.fill", isSelected: false) {}
        IconGridItem(icon: "heart.fill", isSelected: false) {}
        IconGridItem(icon: "flag.fill", isSelected: false) {}
    }
    .padding()
    .background(.black)
}