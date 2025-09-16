/*
 * TimeBlockView.swift
 * 
 * TIME BLOCK UI COMPONENT (PURE VIEW)
 * - Handles only UI layout and visual presentation
 * - Delegates all logic to TimeBlockItemViewModel
 * - Follows MVVM pattern with no business logic in view
 * - Adaptive content display based on height
 * - Native iOS gestures with proper delegation
 */

import SwiftUI

struct TimeBlockView: View {
    @ObservedObject private var itemViewModel: TimeBlockItemViewModel
    private let height: CGFloat
    
    // MARK: - Initialization
    init(itemViewModel: TimeBlockItemViewModel, height: CGFloat) {
        self.itemViewModel = itemViewModel
        self.height = height
    }
    
    // MARK: - Computed Properties
    private var displayMode: TimeBlockItemViewModel.DisplayMode {
        itemViewModel.displayMode(for: height)
    }
    
    private var colorPalette: ProjectColors.TimeBlockPalette {
        itemViewModel.colorPalette
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .frame(height: height)
        .scaleEffect(itemViewModel.isBeingDragged ? 1.05 : 1.0)
        .opacity(itemViewModel.isBeingDragged ? 0.8 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: itemViewModel.isBeingDragged)
        .animation(.easeInOut(duration: 0.2), value: itemViewModel.isSelected)
        .addGestures(itemViewModel)
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Group {
            if itemViewModel.isDragTarget {
                // Drop target: dashed border style
                RoundedRectangle(cornerRadius: itemViewModel.cornerRadius, style: .continuous)
                    .stroke(colorPalette.main, style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    .background(
                        RoundedRectangle(cornerRadius: itemViewModel.cornerRadius, style: .continuous)
                            .fill(Color.clear)
                    )
            } else {
                // Normal: filled background
                RoundedRectangle(cornerRadius: itemViewModel.cornerRadius, style: .continuous)
                    .fill(colorPalette.light)
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header (always visible)
            headerView
            
            // Conditional content based on display mode
            switch displayMode {
            case .small:
                if itemViewModel.shouldShowScheduledItemsText(for: displayMode) {
                    scheduledItemsView
                }
            case .medium:
                EmptyView() // Medium mode shows task count in header only
            case .large:
                if itemViewModel.shouldShowTaskList(for: displayMode) {
                    taskListView
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(itemViewModel.internalPadding)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .top, spacing: 8) {
            // Icon
            Image(systemName: itemViewModel.displayIcon)
                .font(.system(size: itemViewModel.titleFontSize, weight: .semibold, design: .rounded))
                .foregroundColor(colorPalette.dark)
            
            // Title
            Text(itemViewModel.displayName)
                .font(.system(size: itemViewModel.titleFontSize, weight: .semibold, design: .rounded))
                .foregroundColor(colorPalette.dark)
                .lineLimit(1)
            
            Spacer()
            
            // Task count (for medium blocks only)
            if itemViewModel.shouldShowTaskCount(for: displayMode) {
                taskCountBadge
            }
            
            // Duration
            Text(itemViewModel.displayDuration)
                .font(.system(size: itemViewModel.durationFontSize, weight: .semibold, design: .rounded))
                .foregroundColor(colorPalette.main)
        }
    }
    
    // MARK: - Task Count Badge
    private var taskCountBadge: some View {
        Text("\(itemViewModel.activeTaskCount)")
            .font(.system(size: itemViewModel.titleFontSize, weight: .semibold, design: .rounded))
            .foregroundColor(colorPalette.main)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(colorPalette.light)
            )
    }
    
    // MARK: - Scheduled Items Text (Small Blocks)
    private var scheduledItemsView: some View {
        Text(itemViewModel.scheduledItemsText())
            .font(.system(size: itemViewModel.taskFontSize, weight: .medium, design: .rounded))
            .foregroundColor(colorPalette.mid)
            .lineLimit(1)
    }
    
    // MARK: - Task List (Large Blocks)
    private var taskListView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Display up to 5 tasks
            ForEach(Array(itemViewModel.displayTasks.enumerated()), id: \.offset) { index, todo in
                taskRowView(todo: todo)
            }
            
            // Show additional count if needed
            if itemViewModel.additionalTaskCount > 0 {
                additionalTasksView
            }
        }
    }
    
    // MARK: - Individual Task Row
    private func taskRowView(todo: Todo) -> some View {
        HStack(spacing: 8) {
            // Checkbox
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: itemViewModel.taskFontSize, weight: .medium))
                .foregroundColor(todo.isCompleted ? colorPalette.main : colorPalette.mid)
            
            // Task name
            Text(todo.taskName)
                .font(.system(size: itemViewModel.taskFontSize, weight: .medium, design: .rounded))
                .foregroundColor(todo.isCompleted ? colorPalette.mid : colorPalette.dark)
                .strikethrough(todo.isCompleted)
                .lineLimit(1)
            
            Spacer()
        }
    }
    
    // MARK: - Additional Tasks View
    private var additionalTasksView: some View {
        Text(itemViewModel.additionalTasksText())
            .font(.system(size: itemViewModel.taskFontSize - 1, weight: .medium, design: .rounded))
            .foregroundColor(colorPalette.mid)
            .padding(.leading, 22) // Align with task text
    }
}

// MARK: - Gesture Extension
private extension View {
    func addGestures(_ itemViewModel: TimeBlockItemViewModel) -> some View {
        self
            .onTapGesture {
                itemViewModel.handleTap()
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                itemViewModel.handleLongPress()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !itemViewModel.isBeingDragged {
                            itemViewModel.handleDragStart()
                        }
                        itemViewModel.handleDragChange(value.translation)
                    }
                    .onEnded { value in
                        itemViewModel.handleDragEnd(value.translation)
                    }
            )
    }
}

// MARK: - Convenience Initializer
extension TimeBlockView {
    /// Convenience initializer that creates ItemViewModel internally
    init(timeBlock: TimeBlock, height: CGFloat, containerViewModel: TimeBlockViewModel) {
        let itemViewModel = TimeBlockItemViewModel(timeBlock: timeBlock, containerViewModel: containerViewModel)
        self.init(itemViewModel: itemViewModel, height: height)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        // Large block preview
        TimeBlockView(
            itemViewModel: {
                let block = TimeBlock(name: "Rise and shine", startDate: Date(), endDate: Date().addingTimeInterval(3600))
                return TimeBlockItemViewModel(timeBlock: block, containerViewModel: nil)
            }(),
            height: 150
        )
        .frame(width: 300)
        
        // Medium block preview
        TimeBlockView(
            itemViewModel: {
                let block = TimeBlock(name: "Rise and shine", startDate: Date(), endDate: Date().addingTimeInterval(3600))
                return TimeBlockItemViewModel(timeBlock: block, containerViewModel: nil)
            }(),
            height: 100
        )
        .frame(width: 300)
        
        // Small block preview
        TimeBlockView(
            itemViewModel: {
                let block = TimeBlock(name: "Rise and shine", startDate: Date(), endDate: Date().addingTimeInterval(3600))
                return TimeBlockItemViewModel(timeBlock: block, containerViewModel: nil)
            }(),
            height: 60
        )
        .frame(width: 300)
    }
    .padding()
    .background(Color.white)
}