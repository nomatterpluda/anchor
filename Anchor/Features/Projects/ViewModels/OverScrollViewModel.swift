/*
 * OverScrollViewModel.swift
 * 
 * OVER-SCROLL GESTURE BUSINESS LOGIC (MVVM)
 * - Handles over-scroll detection and haptic feedback
 * - Manages threshold detection for new project creation
 * - Provides smooth animation states for over-scroll effects
 * - Separated from other ViewModels for focused responsibility
 */

import Foundation
import SwiftUI
internal import Combine

class OverScrollViewModel: ObservableObject {
    // Over-scroll properties
    @Published var overScrollProgress: CGFloat = 0
    @Published var isThresholdReached: Bool = false
    
    // Private state for haptic management
    private var isContinuousHapticActive: Bool = false
    private var hasTriggeredThresholdHaptic: Bool = false
    private let overScrollThreshold: CGFloat = 120
    
    // Callback for when threshold is reached and gesture ends
    var onThresholdReached: (() -> Void)?
    
    // MARK: - Over-Scroll Logic
    
    // Handle scroll offset changes for over-scroll detection
    func handleScrollOffset(_ dragDistance: CGFloat) {
        // Debug print to see if we're getting drag events
        print("📍 Drag distance: \(dragDistance)")
        
        // Use drag distance directly as over-scroll amount
        overScrollProgress = max(0, dragDistance)
        
        print("🎯 Over-scroll amount: \(overScrollProgress)")
        
        // Handle continuous haptic feedback
        handleContinuousHaptics(for: overScrollProgress)
    }
    
    // Handle scroll gesture end
    func handleScrollEnd() {
        if overScrollProgress >= overScrollThreshold {
            // Threshold reached - trigger callback
            onThresholdReached?()
            Haptic.shared.success()
        }
        resetOverScroll()
    }
    
    // Reset over-scroll state with smooth animation
    func resetOverScroll() {
        // Use withAnimation to ensure smooth reset
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            overScrollProgress = 0
            isThresholdReached = false
        }
        hasTriggeredThresholdHaptic = false
        // Stop continuous haptic when gesture ends
        if isContinuousHapticActive {
            Haptic.shared.stopContinuousHaptic()
            isContinuousHapticActive = false
        }
    }
    
    // MARK: - Computed Properties for UI
    
    // Calculate drag progress (0-1) for UI animations
    var dragProgress: CGFloat {
        min(overScrollProgress / overScrollThreshold, 1.0)
    }
    
    // Calculate "Add" text width based on drag progress
    var addTextWidth: CGFloat {
        dragProgress * 80 // Max width of 80pt for "Add" text
    }
    
    // Calculate project titles opacity - fade out as drag progresses
    var projectTitlesOpacity: Double {
        max(0, 1.0 - dragProgress) // Fade from 1.0 to 0.0 as drag progresses
    }
    
    // MARK: - Private Haptic Logic
    
    // Handle continuous haptic feedback with rising tension
    private func handleContinuousHaptics(for overScroll: CGFloat) {
        if overScroll > 0 && overScroll < overScrollThreshold {
            // Continuous ramp from 0 to threshold
            if !isContinuousHapticActive {
                Haptic.shared.startContinuousHaptic()
                isContinuousHapticActive = true
                hasTriggeredThresholdHaptic = false
            }
            
            // Ensure threshold state is false when under threshold
            if isThresholdReached {
                isThresholdReached = false
            }
            
            // Map progress = clamp(overscroll / threshold, 0, 1)
            let progress = min(overScroll / overScrollThreshold, 1.0)
            
            print("🎯 Continuous haptic - Progress: \(String(format: "%.2f", progress))")
            
            // Update continuous haptic with rising tension
            Haptic.shared.updateContinuousHaptic(progress: progress)
            
        } else if overScroll >= overScrollThreshold {
            // User passed threshold - signal and stop continuous haptic
            if !hasTriggeredThresholdHaptic {
                // Stop continuous haptic
                if isContinuousHapticActive {
                    Haptic.shared.stopContinuousHaptic()
                    isContinuousHapticActive = false
                }
                
                // Strong confirmation haptic to signal threshold crossed
                Haptic.shared.heavyImpact()
                hasTriggeredThresholdHaptic = true
                
                print("🎯 Threshold crossed! Heavy haptic triggered")
            }
            
            // Set threshold reached state for visual feedback
            if !isThresholdReached {
                isThresholdReached = true
            }
            
        } else {
            // Stop continuous haptic when no over-scroll
            if isContinuousHapticActive {
                Haptic.shared.stopContinuousHaptic()
                isContinuousHapticActive = false
            }
            hasTriggeredThresholdHaptic = false
            isThresholdReached = false
        }
    }
}