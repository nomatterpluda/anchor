/*
 * ViewModifiers.swift
 * 
 * REUSABLE VIEW MODIFIERS
 * - Collection of custom view modifiers used across the app
 * - Keeps UI modifiers organized and reusable
 */

import SwiftUI

// MARK: - Flip Modifier for Chat-like List


extension View {
    func flippedUpsideDown() -> some View {
        self.rotationEffect(.degrees(180))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
