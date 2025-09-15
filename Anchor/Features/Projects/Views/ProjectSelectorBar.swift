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
    
    // ViewModels
    @ObservedObject var selectionViewModel: ProjectSelectionViewModel
    @ObservedObject var overScrollViewModel: OverScrollViewModel
    
    // Menu State (passed from parent)
    @Binding var isMenuPresented: Bool
    
    // Direct query for todos to ensure reactivity
    @Query(filter: #Predicate<Todo> { !$0.isCompleted }) private var activeTodos: [Todo]
    
    // Computed Properties
    private var allProjectOptions: [ProjectOption] {
        selectionViewModel.getAllProjectOptions(from: projects)
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
                    project: selectionViewModel.selectedProject,
                    isThresholdReached: overScrollViewModel.isThresholdReached,
                    isMenuPresented: isMenuPresented,
                    dragProgress: overScrollViewModel.dragProgress
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
                .frame(width: overScrollViewModel.addTextWidth, alignment: .leading)
                .clipped()
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: overScrollViewModel.addTextWidth)
                
                // Scrollable project list (right side) - fade non-selected when menu open
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(Array(allProjectOptions.enumerated()), id: \.offset) { index, option in
                                    ProjectListItem(
                                        name: option.name,
                                        activeTaskCount: getActiveTaskCount(for: option),
                                        isSelected: index == selectionViewModel.leftmostIndex
                                    ) {
                                        // If this is the selected project, toggle menu instead of selecting
                                        if index == selectionViewModel.leftmostIndex {
                                            Haptic.shared.lightImpact()
                                            withAnimation(.snappy) {
                                                isMenuPresented.toggle()
                                            }
                                        } else {
                                            // Handle selection through ViewModel
                                            selectionViewModel.selectProject(option, at: index) { scrollIndex in
                                                withAnimation(.easeOut(duration: 0.3)) {
                                                    proxy.scrollTo(scrollIndex, anchor: .leading)
                                                }
                                            }
                                        }
                                    }
                                    .opacity(isMenuPresented && index != selectionViewModel.leftmostIndex ? 0.0 : 1.0)
                                    .allowsHitTesting(!(isMenuPresented && index != selectionViewModel.leftmostIndex))
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
                                    guard selectionViewModel.leftmostIndex == 0 else { return }
                                    
                                    // Check if dragging right (positive translation = scrolling left)
                                    let dragDistance = translation.width
                                    if dragDistance > 0 {
                                        overScrollViewModel.handleScrollOffset(dragDistance)
                                    }
                                }
                                .onEnded { value in
                                    overScrollViewModel.handleScrollEnd()
                                }
                        )
                        .onScrollTargetVisibilityChange(idType: Int.self) { ids in
                            // Skip if we're doing a manual scroll or view is reappearing
                            guard !selectionViewModel.isManualScrolling && !selectionViewModel.isViewReappearing else { return }
                            
                            // This detects when new items become visible, pick the first one as selected
                            if let firstId = ids.first, firstId != selectionViewModel.leftmostIndex {
                                // Only update and trigger haptic when selection actually changes
                                selectionViewModel.leftmostIndex = firstId
                                if firstId < allProjectOptions.count {
                                    let option = allProjectOptions[firstId]
                                    selectionViewModel.selectedProject = option.projectModel
                                    Haptic.shared.softImpact()
                                }
                            }
                        }
                        .onAppear {
                            // Restore scroll position when view appears
                            if selectionViewModel.leftmostIndex > 0 {
                                proxy.scrollTo(selectionViewModel.leftmostIndex, anchor: .leading)
                            }
                        }
                }
                .opacity(overScrollViewModel.projectTitlesOpacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: overScrollViewModel.projectTitlesOpacity)
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
        .ignoresSafeArea(.keyboard)
    }
}
