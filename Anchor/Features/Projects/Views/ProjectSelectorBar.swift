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
    
    // Menu State (passed from parent)
    @Binding var isMenuPresented: Bool
    
    // Direct query for todos to ensure reactivity
    @Query(filter: #Predicate<Todo> { !$0.isCompleted }) private var activeTodos: [Todo]
    
    // Computed Properties
    private var allProjectOptions: [ProjectOption] {
        viewModel.getAllProjectOptions(from: projects)
    }
    
    private func getActiveTaskCount(for option: ProjectOption) -> Int {
        switch option {
        case .all:
            return activeTodos.count
        case .project(let projectModel):
            return activeTodos.filter { $0.project?.projectID == projectModel.projectID }.count
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                // Static project icon (left side) - tappable
                StaticProjectIcon(
                    project: viewModel.selectedProject,
                    isThresholdReached: viewModel.isThresholdReached
                )
                    .onTapGesture {
                        Haptic.shared.lightImpact()
                        withAnimation(.snappy) {
                            isMenuPresented.toggle()
                        }
                    }
                
                // Scrollable project list (right side) - fade non-selected when menu open
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(Array(allProjectOptions.enumerated()), id: \.offset) { index, option in
                                    ProjectListItem(
                                        name: option.name,
                                        activeTaskCount: getActiveTaskCount(for: option),
                                        isSelected: index == (viewModel.scrollPosition ?? 0)
                                    ) {
                                        // If this is the selected project, toggle menu instead of selecting
                                        if index == (viewModel.scrollPosition ?? 0) {
                                            Haptic.shared.lightImpact()
                                            withAnimation(.snappy) {
                                                isMenuPresented.toggle()
                                            }
                                        } else {
                                            // Handle selection through ViewModel
                                            viewModel.selectProject(option, at: index) { scrollIndex in
                                                withAnimation(.easeOut(duration: 0.3)) {
                                                    proxy.scrollTo(scrollIndex, anchor: .leading)
                                                }
                                            }
                                        }
                                    }
                                    .opacity(isMenuPresented && index != (viewModel.scrollPosition ?? 0) ? 0.0 : 1.0)
                                    .allowsHitTesting(!(isMenuPresented && index != (viewModel.scrollPosition ?? 0)))
                                    .id(index)
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, max(80, geometry.size.width - 80))
                        }
                        .scrollPosition(id: $viewModel.scrollPosition)
                        .scrollTargetLayout()
                        .scrollTargetBehavior(.viewAligned)
                        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
                        .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                // Only detect over-scroll when we're at the first item (position 0)
                                // Position 0 is "All" - over-scroll creates new project
                                guard viewModel.scrollPosition == 0 else { return }
                                
                                // Check if dragging right (positive translation = scrolling left)
                                let dragDistance = value.translation.width
                                if dragDistance > 0 {
                                    viewModel.handleScrollOffset(dragDistance)
                                }
                            }
                            .onEnded { value in
                                viewModel.handleScrollEnd()
                            }
                    )
                    .onChange(of: viewModel.scrollPosition) { oldValue, newValue in
                        viewModel.handleScrollPositionChange(
                            newIndex: newValue,
                            in: allProjectOptions,
                            previousIndex: oldValue
                        )
                    }
                }
            }
            }
        }
        .padding(.leading, 16)
        .padding(.top, 32)
        .padding(.bottom, isMenuPresented ? 20 : 20)
        .padding(.trailing, 0)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.95))
                .ignoresSafeArea(edges: .bottom)
        )
        .sheet(isPresented: $viewModel.showNewProjectSheet) {
            AddProjectSheet(viewModel: viewModel)
        }
        .ignoresSafeArea(.keyboard)
    }
}
