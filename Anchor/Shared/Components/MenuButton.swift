/*
 * MenuButton.swift
 * 
 * GLASS MENU BUTTON COMPONENT
 * - Displays icon and title in vertical layout with iOS 26 glass effect
 * - Uses .glassEffect(.interactive()) for scaling, bouncing, and shimmering
 * - Bold rounded icon (size 19) with semibold rounded title (size 17)
 * - Reusable component for project menu actions
 */

import SwiftUI

struct MenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 70)
        }
        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HStack(spacing: 15) {
        MenuButton(icon: "pencil", title: "Edit") { }
        MenuButton(icon: "gearshape", title: "Settings") { }
        MenuButton(icon: "line.3.horizontal", title: "Reorder") { }
    }
    .padding()
    .background(Color.black)
}
