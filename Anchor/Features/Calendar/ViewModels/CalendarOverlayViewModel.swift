/*
 * CalendarOverlayViewModel.swift
 * 
 * CALENDAR OVERLAY STATE MANAGEMENT
 * - Manages sheet position and drag states for UpsideDownBottomSheet
 * - Handles gesture calculations and position snapping logic
 * - Provides haptic feedback coordination
 * - Follows MVVM principles with clear separation of concerns
 */

import Foundation
import SwiftUI
internal import Combine

class CalendarOverlayViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var sheetPosition: CGFloat = 0.5 // Default to middle position
    @Published var dragStartedInDateSection: Bool = false
    
    // MARK: - Constants
    let minHeightRatio: CGFloat = 0.2
    let midHeightRatio: CGFloat = 0.5
    let maxHeightRatio: CGFloat = 1.0
    
    // MARK: - Private Properties
    private let dateSectionHeight: CGFloat = 36 + 25 + 60 + 16 // bottom + top + big number + spacing
    
    // MARK: - Computed Properties
    
    /// Calculate live sheet ratio based on current position and drag offset
    func liveSheetRatio(dragOffset: CGFloat, screenHeight: CGFloat) -> CGFloat {
        let dragRatio = dragOffset / screenHeight
        return min(max(sheetPosition + dragRatio, minHeightRatio), maxHeightRatio)
    }
    
    /// Check if drag started in the draggable date section
    func shouldStartDrag(at locationY: CGFloat, sheetHeight: CGFloat) -> Bool {
        let dateSectionTop = sheetHeight - dateSectionHeight
        return locationY >= dateSectionTop
    }
    
    // MARK: - Drag Gesture Handling
    
    /// Handle drag gesture start
    func handleDragStart(at locationY: CGFloat, sheetHeight: CGFloat) {
        dragStartedInDateSection = shouldStartDrag(at: locationY, sheetHeight: sheetHeight)
        // No haptic feedback on drag start
    }
    
    /// Handle drag gesture end with position snapping
    func handleDragEnd(translation: CGSize, predictedTranslation: CGSize, screenHeight: CGFloat) {
        guard dragStartedInDateSection else { return }
        
        let dragRatio = translation.height / screenHeight
        let current = min(max(sheetPosition + dragRatio, minHeightRatio), maxHeightRatio)
        sheetPosition = current
        
        let predictedDragRatio = predictedTranslation.height / screenHeight
        let predicted = current + (predictedDragRatio - dragRatio)
        
        let positions: [CGFloat] = [minHeightRatio, midHeightRatio, maxHeightRatio]
        let target = positions.min(by: { abs($0 - predicted) < abs($1 - predicted) }) ?? maxHeightRatio
        
        // Soft haptic feedback when sheet snaps to a position
        if abs(target - sheetPosition) > 0.1 {
            Haptic.shared.softImpact()
        }
        
        withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.82, blendDuration: 0.25)) {
            sheetPosition = target
        }
        
        dragStartedInDateSection = false
    }
    
    // MARK: - Position Management
    
    /// Set sheet position programmatically
    func setPosition(_ position: CGFloat, animated: Bool = true) {
        let clampedPosition = min(max(position, minHeightRatio), maxHeightRatio)
        
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                sheetPosition = clampedPosition
            }
        } else {
            sheetPosition = clampedPosition
        }
    }
    
    /// Reset to default position
    func resetToDefault() {
        setPosition(midHeightRatio)
    }
    
    /// Get current position as percentage
    var currentPositionPercentage: Int {
        Int(sheetPosition * 100)
    }
    
    /// Check if sheet is at specific position
    func isAtPosition(_ position: CGFloat, tolerance: CGFloat = 0.05) -> Bool {
        abs(sheetPosition - position) <= tolerance
    }
}