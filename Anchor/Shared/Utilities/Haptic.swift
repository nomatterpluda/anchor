
import UIKit
import CoreHaptics

/// A centralized manager for handling haptic feedback throughout the app
final class Haptic {
    static let shared = Haptic()
    
    // Core Haptics engine for continuous effects
    private var hapticEngine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    
    private init() {
        setupHapticEngine()
    }
    
    // MARK: - Core Haptics Setup
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    // MARK: - Impact Feedback
    
    /// Light impact feedback - for subtle interactions
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium impact feedback - for standard interactions
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy impact feedback - for significant interactions
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Heavy impact feedback - for significant interactions
    func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    /// Custom intensity impact feedback - for progressive effects
    func progressiveImpact(intensity: CGFloat) {
        let clampedIntensity = max(0.0, min(1.0, intensity))
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare() // Prepare for low latency
        generator.impactOccurred(intensity: clampedIntensity)
    }
    
    /// Ultra-light minimal haptic feedback - barely perceptible
    func minimalImpact() {
        // Check Low Power Mode to preserve battery
        if ProcessInfo.processInfo.isLowPowerModeEnabled { return }
        
        let generator = UIImpactFeedbackGenerator()
        generator.prepare() // Prepare for low latency
        generator.impactOccurred(intensity: 0.15) // Very minimal vibration
    }
    
    // MARK: - Notification Feedback
    
    /// Success notification feedback - for completed actions
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification feedback - for cautionary actions
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification feedback - for failed actions
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Selection feedback - for picker/selection changes
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Continuous Haptics for Over-Scroll
    
    /// Start continuous haptic feedback for over-scroll gesture
    func startContinuousHaptic() {
        guard let hapticEngine = hapticEngine else { return }
        
        do {
            // Create a continuous haptic pattern with higher base values
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            
            let continuousEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 10 // Long duration, we'll control it manually
            )
            
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            continuousPlayer = try hapticEngine.makeAdvancedPlayer(with: pattern)
            
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to start continuous haptic: \(error)")
        }
    }
    
    /// Update continuous haptic intensity based on progress (0.0 to 1.0)
    func updateContinuousHaptic(progress: CGFloat) {
        guard let continuousPlayer = continuousPlayer else { return }
        
        // Map progress = clamp(overscroll / 200, 0, 1)
        let clampedProgress = max(0.0, min(1.0, progress))
        
        // Intensity = 0.3 + (progress^1.5 * 0.7) for more noticeable range
        let intensityProgress = Float(pow(clampedProgress, 1.5))
        let intensity = 0.3 + (intensityProgress * 0.7) // Range: 0.3 to 1.0
        
        // Sharpness = 0.4 + (intensity * 0.6) for more noticeable definition
        let sharpness = min(1.0, 0.4 + (intensity * 0.6))
        
        do {
            let intensityParam = CHHapticDynamicParameter(
                parameterID: .hapticIntensityControl,
                value: intensity,
                relativeTime: 0
            )
            
            let sharpnessParam = CHHapticDynamicParameter(
                parameterID: .hapticSharpnessControl,
                value: sharpness,
                relativeTime: 0
            )
            
            try continuousPlayer.sendParameters([intensityParam, sharpnessParam], atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to update continuous haptic: \(error)")
        }
    }
    
    /// Stop continuous haptic feedback
    func stopContinuousHaptic() {
        do {
            try continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
            continuousPlayer = nil
        } catch {
            print("Failed to stop continuous haptic: \(error)")
        }
    }
}
