/*
 * GlassEffectContainer.swift
 * 
 * GLASS EFFECT CONTAINER COMPONENT
 * - Provides consistent glass effect styling for containers
 * - Used by menu views and modal content for iOS 26 design consistency
 * - Wraps content with glass background and styling
 */

import SwiftUI

struct GlassEffectContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        GlassEffectContainer {
            VStack(spacing: 20) {
                Text("Glass Effect")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("This container provides a glass effect background")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(20)
        }
        .padding()
    }
}