/*
 * ProjectSelectorBar.swift
 * 
 * BOTTOM PROJECT SELECTOR COMPONENT
 * - Static project icon on left showing selected project
 * - Horizontal scrollable project list with names and task counts
 * - Snap-to-left behavior: leftmost visible project is always selected
 * - Smooth scrolling animations and haptic feedback
 * - New layout: VStack → HStack with static icon + scrollable content
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
    
    private func getActiveTaskCount(for option: ProjectOption) -> Int {
        if option.name == "All" {
            return projects.reduce(0) { $0 + $1.activeTodos.count }
        } else {
            return projects.first { $0.projectName == option.name }?.activeTodos.count ?? 0
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                // Static project icon (left side)
                StaticProjectIcon(project: viewModel.selectedProject)
                
                // Scrollable project list (right side)
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach(Array(allProjectOptions.enumerated()), id: \.offset) { index, option in
                                ProjectListItem(
                                    name: option.name,
                                    activeTaskCount: getActiveTaskCount(for: option),
                                    isSelected: index == (viewModel.scrollPosition ?? 0)
                                ) {
                                    // Handle selection through ViewModel
                                    viewModel.selectProject(option, at: index) { scrollIndex in
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            proxy.scrollTo(scrollIndex, anchor: .leading)
                                        }
                                    }
                                }
                                .id(index)
                            }
                        }
                        .padding(.leading, 16) // Left padding from icon
                        .padding(.trailing, 160) // Extra right padding so last item can reach left side
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
                }
            }
        }
        .padding(.leading, 16)
        .padding(.top, 32)
        .padding(.bottom, 52)
        .padding(.trailing, 0)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.95))
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
