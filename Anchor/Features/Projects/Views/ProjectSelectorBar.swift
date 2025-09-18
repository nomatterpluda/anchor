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
    
    // Calculate drag progress (0-1) for UI animations
    private var dragProgress: CGFloat {
        min(viewModel.overScrollProgress / 120, 1.0)
    }
    
    // Calculate "Add" text width based on drag progress
    private var addTextWidth: CGFloat {
        dragProgress * 80 // Max width of 80pt for "Add" text (increased for larger font)
    }
    
    // Calculate project titles opacity - fade out as drag progresses
    private var projectTitlesOpacity: Double {
        max(0, 1.0 - dragProgress) // Fade from 1.0 to 0.0 as drag progresses
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
                    isThresholdReached: viewModel.isThresholdReached,
                    isMenuPresented: isMenuPresented,
                    dragProgress: dragProgress
                )
                    .onTapGesture {
                        Haptic.shared.lightImpact()
                        withAnimation(.snappy) {
                            isMenuPresented.toggle()
                        }
                    }
                
                // Reveal-style "Add" text
                HStack {
                    Text("Add")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer(minLength: 0)
                }
                .frame(width: addTextWidth, alignment: .leading)
                .clipped()
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: addTextWidth)
                
                // Scrollable project list (right side) - fade non-selected when menu open
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(Array(allProjectOptions.enumerated()), id: \.offset) { index, option in
                                    ProjectListItem(
                                        name: option.name,
                                        activeTaskCount: getActiveTaskCount(for: option),
                                        isSelected: index == viewModel.leftmostIndex
                                    ) {
                                        // If this is the selected project, toggle menu instead of selecting
                                        if index == viewModel.leftmostIndex {
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
                                    .opacity(isMenuPresented && index != viewModel.leftmostIndex ? 0.0 : 1.0)
                                    .allowsHitTesting(!(isMenuPresented && index != viewModel.leftmostIndex))
                                    .id(index)
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, max(80, geometry.size.width - 80))
                        }
                        .scrollTargetLayout()
                        .scrollTargetBehavior(.viewAligned)
                        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    let translation = value.translation
                                    
                                    // Vertical drag gesture for menu control
                                    if abs(translation.height) > abs(translation.width) * 1.5 {
                                        if translation.height < -30 && !isMenuPresented {
                                            // Drag up - open menu
                                            Haptic.shared.lightImpact()
                                            withAnimation(.snappy) {
                                                isMenuPresented = true
                                            }
                                        } else if translation.height > 30 && isMenuPresented {
                                            // Drag down - close menu
                                            Haptic.shared.lightImpact()
                                            withAnimation(.snappy) {
                                                isMenuPresented = false
                                            }
                                        }
                                    }
                                    
                                    // Horizontal over-scroll for new project creation
                                    // Only detect over-scroll when we're at the first item (position 0)
                                    guard viewModel.leftmostIndex == 0 else { return }
                                    
                                    // Check if dragging right (positive translation = scrolling left)
                                    let dragDistance = translation.width
                                    if dragDistance > 0 {
                                        viewModel.handleScrollOffset(dragDistance)
                                    }
                                }
                                .onEnded { value in
                                    viewModel.handleScrollEnd()
                                }
                        )
                        .onScrollTargetVisibilityChange(idType: Int.self) { ids in
                            // Skip if we're doing a manual scroll or view is reappearing
                            guard !viewModel.isManualScrolling && !viewModel.isViewReappearing else { return }
                            
                            // This detects when new items become visible, pick the first one as selected
                            if let firstId = ids.first, firstId != viewModel.leftmostIndex {
                                // Only update and trigger haptic when selection actually changes
                                viewModel.leftmostIndex = firstId
                                if firstId < allProjectOptions.count {
                                    let option = allProjectOptions[firstId]
                                    viewModel.selectedProject = option.projectModel
                                    Haptic.shared.softImpact()
                                }
                            }
                        }
                        .onAppear {
                            // Restore scroll position when view appears
                            if viewModel.leftmostIndex > 0 {
                                proxy.scrollTo(viewModel.leftmostIndex, anchor: .leading)
                            }
                        }
                }
                .opacity(projectTitlesOpacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: projectTitlesOpacity)
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
