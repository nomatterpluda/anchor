/*
 * ProjectSelectorBar.swift
 * 
 * BOTTOM PROJECT SELECTOR COMPONENT
 * - Horizontal scrollable bar with project buttons
 * - Snap-to-left behavior: leftmost visible project is always selected
 * - Smooth scrolling animations and haptic feedback
 * - Fixed-width buttons for consistent pagination
 * - Integrates with ProjectSelectionViewModel for state management
 */

import SwiftUI
import SwiftData

struct ProjectSelectorBar: View {
    // Data
    let projects: [ProjectModel]
    
    // ViewModel
    @ObservedObject var viewModel: ProjectSelectionViewModel
    
    // Computed Properties
    private var allProjectOptions: [ProjectOption] {
        viewModel.getAllProjectOptions(from: projects)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(allProjectOptions.enumerated()), id: \.offset) { index, option in
                        ProjectSelectorButton(
                            name: option.name,
                            icon: option.icon,
                            color: option.color,
                            isSelected: index == (viewModel.scrollPosition ?? 0)
                        ) {
                            // Handle selection through ViewModel
                            viewModel.selectProject(option, at: index) { scrollIndex in
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(scrollIndex, anchor: .leading)
                                }
                            }
                        }
                        .frame(width: 160) // Fixed width for consistent snapping
                        .id(index)
                    }
                }
                .padding(.leading, 12) // Left padding from screen edge
                .padding(.trailing, 12)
            }
            .scrollPosition(id: $viewModel.scrollPosition)
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: viewModel.scrollPosition) { oldValue, newValue in
                // Handle scroll position changes through ViewModel
                viewModel.handleScrollPositionChange(
                    newIndex: newValue,
                    in: allProjectOptions,
                    previousIndex: oldValue
                )
            }
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.95))
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}