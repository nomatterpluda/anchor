/*
 * SwipeableRowView.swift
 * 
 * SWIPEABLE ROW COMPONENT
 * - Replicates List swipe-to-delete functionality for ScrollView
 * - Provides smooth swipe gestures with haptic feedback
 * - Matches native iOS swipe behavior and animations
 * - Wraps content with swipe gesture detection and delete action
 */

import SwiftUI

struct SwipeableRowView<Content: View>: View {
    let content: Content
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isDeleting: Bool = false
    
    private let deleteThreshold: CGFloat = -80
    private let deleteButtonWidth: CGFloat = 80
    
    init(@ViewBuilder content: () -> Content, onDelete: @escaping () -> Void) {
        self.content = content()
        self.onDelete = onDelete
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button background
            if offset < 0 {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: abs(offset))
                    .overlay(
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .opacity(abs(offset) > 30 ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: offset)
                    )
            }
            
            // Main content
            content
                .background(Color(hex: "1C1C1E"))
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow left swipe (negative translation)
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, deleteThreshold * 1.5)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.snappy(duration: 0.3)) {
                                if offset < deleteThreshold {
                                    // Delete action
                                    Haptic.shared.mediumImpact()
                                    performDelete()
                                } else {
                                    // Snap back
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .clipped()
        .animation(.snappy(duration: 0.3), value: isDeleting)
    }
    
    private func performDelete() {
        isDeleting = true
        // Animate out and then delete
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = -UIScreen.main.bounds.width
        }
        
        // Small delay before actual deletion for smooth animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onDelete()
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SwipeableRowView(
            content: {
                HStack {
                    Image(systemName: "circle")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Swipe me left to delete")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            },
            onDelete: {
                print("Delete action")
            }
        )
        

        
        SwipeableRowView(
            content: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Another swipeable row")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .strikethrough()
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            },
            onDelete: {
                print("Delete action 2")
            }
        )
    }
    .background(Color(.systemGray6).opacity(0.3))
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding()
    .background(Color.black)
}
