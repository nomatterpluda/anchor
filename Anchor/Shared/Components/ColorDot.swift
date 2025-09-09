/*
 * ColorDot.swift
 * 
 * COLOR PICKER DOT COMPONENT
 * - 35x35 circle for color selection in AddProjectSheet
 * - Shows project color with selection state
 * - Animated selection ring and scale effects
 * - Haptic feedback on tap
 */

import SwiftUI

struct ColorDot: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    private var swiftUIColor: Color {
        ProjectColors.swiftUIColor(for: color)
    }
    
    var body: some View {
        Circle()
            .fill(swiftUIColor)
            .frame(width: 35, height: 35)
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: isSelected ? 4 : 0)
                    .frame(width: 23, height: 23)
            )
            .animation(.snappy(duration: 0.2), value: isSelected)
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    HStack {
        ColorDot(color: "blue", isSelected: false) {}
        ColorDot(color: "green", isSelected: true) {}
        ColorDot(color: "red", isSelected: false) {}
    }
    .padding()
    .background(.black)
}
