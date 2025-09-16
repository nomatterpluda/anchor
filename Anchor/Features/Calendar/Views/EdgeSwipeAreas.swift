/*
 * EdgeSwipeAreas.swift
 * 
 * EDGE SWIPE GESTURE AREAS
 * - Provides vertical swipe areas on left and right screen edges
 * - Allows calendar sheet control even when sheet is out of reach
 * - Follows PRD: "vertical swipe on left or right edges to resize calendar"
 * - Includes visual indicators for user discovery
 */

import SwiftUI

struct EdgeSwipeAreas: View {
    @ObservedObject var overlayViewModel: CalendarOverlayViewModel
    var geometry: GeometryProxy
    
    // Edge area configuration
    private let edgeWidth: CGFloat = 30 // Width of the edge swipe areas (increased)
    private let minDragDistance: CGFloat = 5 // Minimum distance to activate (reduced)
    
    @GestureState private var leftEdgeDragOffset: CGFloat = 0
    @GestureState private var rightEdgeDragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Left Edge Swipe Area
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: edgeWidth)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if value.translation == .zero {
                                    // First drag event - activate edge swipe
                                    overlayViewModel.handleEdgeSwipeStart()
                                }
                            }
                            .updating($leftEdgeDragOffset) { value, state, _ in
                                if overlayViewModel.dragStartedInDateSection {
                                    state = value.translation.height
                                    overlayViewModel.updateEdgeDragOffset(value.translation.height)
                                }
                            }
                            .onEnded { value in
                                overlayViewModel.handleDragEnd(
                                    translation: value.translation,
                                    predictedTranslation: value.predictedEndTranslation,
                                    screenHeight: geometry.size.height
                                )
                            }
                    )
                
                Spacer()
            }
            
            // Right Edge Swipe Area
            HStack(spacing: 0) {
                Spacer()
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: edgeWidth)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if value.translation == .zero {
                                    // First drag event - activate edge swipe
                                    overlayViewModel.handleEdgeSwipeStart()
                                }
                            }
                            .updating($rightEdgeDragOffset) { value, state, _ in
                                if overlayViewModel.dragStartedInDateSection {
                                    state = value.translation.height
                                    overlayViewModel.updateEdgeDragOffset(value.translation.height)
                                }
                            }
                            .onEnded { value in
                                overlayViewModel.handleDragEnd(
                                    translation: value.translation,
                                    predictedTranslation: value.predictedEndTranslation,
                                    screenHeight: geometry.size.height
                                )
                            }
                    )
            }
            
            // Visual Hint Indicators (subtle, only show when calendar is minimized)
            if overlayViewModel.isAtPosition(overlayViewModel.minHeightRatio) {
                VStack {
                    Spacer()
                    
                    HStack {
                        // Left edge hint
                        EdgeHintIndicator(edge: .leading)
                            .padding(.leading, 8)
                        
                        Spacer()
                        
                        // Right edge hint
                        EdgeHintIndicator(edge: .trailing)
                            .padding(.trailing, 8)
                    }
                    .padding(.bottom, 100) // Position above bottom UI elements
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: overlayViewModel.sheetPosition)
            }
        }
    }
}

// Edge hint indicator component
struct EdgeHintIndicator: View {
    let edge: Edge.Set
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 2, height: 15)
                    .opacity(isAnimating ? 0.3 : 0.1)
                    .animation(
                        Animation
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    GeometryReader { geometry in
        EdgeSwipeAreas(
            overlayViewModel: CalendarOverlayViewModel(),
            geometry: geometry
        )
    }
}