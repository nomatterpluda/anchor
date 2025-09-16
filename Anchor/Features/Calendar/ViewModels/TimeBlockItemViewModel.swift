/*
 * TimeBlockItemViewModel.swift
 * 
 * SINGLE TIME BLOCK PRESENTATION VIEW MODEL
 * - Handles presentation logic for individual time blocks
 * - Provides computed properties for UI display
 * - Manages visual states (selected, dragging, drop target)
 * - Delegates business operations to TimeBlockViewModel
 * - Follows MVVM pattern with clear separation of concerns
 */

import Foundation
import SwiftUI
import CoreGraphics
internal import Combine

@MainActor
class TimeBlockItemViewModel: ObservableObject {
    
    // MARK: - Model Reference
    private let timeBlock: TimeBlock
    private weak var containerViewModel: TimeBlockViewModel?
    
    // MARK: - Published UI States
    @Published var isSelected: Bool = false
    @Published var isBeingDragged: Bool = false
    @Published var isDragTarget: Bool = false
    @Published var isResizing: Bool = false
    
    // MARK: - Constants for UI
    let titleFontSize: CGFloat = 17
    let durationFontSize: CGFloat = 11
    let taskFontSize: CGFloat = 14
    let cornerRadius: CGFloat = 12
    let internalPadding: CGFloat = 12
    
    // Height thresholds for content adaptation
    let largeBlockThreshold: CGFloat = 120
    let mediumBlockThreshold: CGFloat = 80
    
    // MARK: - Initialization
    init(timeBlock: TimeBlock, containerViewModel: TimeBlockViewModel?) {
        self.timeBlock = timeBlock
        self.containerViewModel = containerViewModel
    }
    
    // MARK: - Display Properties
    
    /// Time block name for display
    var displayName: String {
        timeBlock.name
    }
    
    /// Formatted duration string
    var displayDuration: String {
        timeBlock.formattedDuration
    }
    
    /// Icon name for display
    var displayIcon: String {
        timeBlock.iconName
    }
    
    /// Active task count
    var activeTaskCount: Int {
        timeBlock.activeTaskCount
    }
    
    /// Tasks for display (limited for UI)
    var displayTasks: [Todo] {
        Array(timeBlock.todos.prefix(5))
    }
    
    /// Additional task count (beyond displayed)
    var additionalTaskCount: Int {
        max(0, timeBlock.todos.count - 5)
    }
    
    /// Color palette for this block
    var colorPalette: ProjectColors.TimeBlockPalette {
        ProjectColors.timeBlockPalette(for: timeBlock.displayColor)
    }
    
    // MARK: - Display Mode Logic
    
    enum DisplayMode {
        case small   // Title + duration only
        case medium  // Title + task count + duration
        case large   // Title + full task list + duration
    }
    
    func displayMode(for height: CGFloat) -> DisplayMode {
        if height >= largeBlockThreshold {
            return .large
        } else if height >= mediumBlockThreshold {
            return .medium
        } else {
            return .small
        }
    }
    
    // MARK: - Content Display Logic
    
    func shouldShowTaskCount(for displayMode: DisplayMode) -> Bool {
        displayMode == .medium && activeTaskCount > 0
    }
    
    func shouldShowTaskList(for displayMode: DisplayMode) -> Bool {
        displayMode == .large && !timeBlock.todos.isEmpty
    }
    
    func shouldShowScheduledItemsText(for displayMode: DisplayMode) -> Bool {
        displayMode == .small && activeTaskCount > 0
    }
    
    func scheduledItemsText() -> String {
        "\(activeTaskCount) scheduled items"
    }
    
    func additionalTasksText() -> String {
        "... and \(additionalTaskCount) more"
    }
    
    // MARK: - Visual State Management
    
    func updateSelectionState(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func updateDragState(_ isDragging: Bool) {
        isBeingDragged = isDragging
    }
    
    func updateDropTargetState(_ isDropTarget: Bool) {
        isDragTarget = isDropTarget
    }
    
    func updateResizeState(_ isResizing: Bool) {
        self.isResizing = isResizing
    }
    
    // MARK: - Action Delegation
    
    /// Handle tap gesture
    func handleTap() {
        containerViewModel?.selectedBlock = timeBlock
        Haptic.shared.lightImpact()
    }
    
    /// Handle long press gesture
    func handleLongPress() {
        containerViewModel?.selectedBlock = timeBlock
        Haptic.shared.mediumImpact()
        // Could trigger detail sheet presentation
    }
    
    /// Handle drag start
    func handleDragStart() {
        containerViewModel?.startDragging(timeBlock)
        updateDragState(true)
    }
    
    /// Handle drag change
    func handleDragChange(_ translation: CGSize) {
        guard let containerViewModel = containerViewModel else { return }
        
        // Calculate new position
        let currentYPosition = containerViewModel.dateToYPosition(date: timeBlock.startDate)
        let newYPosition = currentYPosition + translation.height
        let proposedStartDate = containerViewModel.yPositionToDate(y: newYPosition)
        
        // This is just for visual feedback - actual move happens on drag end
        // Could update a preview position here if needed
    }
    
    /// Handle drag end
    func handleDragEnd(_ translation: CGSize) {
        guard let containerViewModel = containerViewModel else { return }
        
        // Calculate final position
        let currentYPosition = containerViewModel.dateToYPosition(date: timeBlock.startDate)
        let newYPosition = currentYPosition + translation.height
        let proposedStartDate = containerViewModel.yPositionToDate(y: newYPosition)
        
        // Delegate actual move to container ViewModel
        containerViewModel.moveBlock(timeBlock, to: proposedStartDate)
        containerViewModel.endDragging()
        
        updateDragState(false)
    }
    
    /// Handle resize gesture
    func handleResizeStart(_ handle: TimeBlockViewModel.ResizeHandle) {
        containerViewModel?.startResizing(timeBlock, handle: handle)
        updateResizeState(true)
    }
    
    /// Handle resize change
    func handleResizeChange(_ translation: CGSize, handle: TimeBlockViewModel.ResizeHandle) {
        guard let containerViewModel = containerViewModel else { return }
        
        switch handle {
        case .top:
            let currentYPosition = containerViewModel.dateToYPosition(date: timeBlock.startDate)
            let newYPosition = currentYPosition + translation.height
            let proposedStartDate = containerViewModel.yPositionToDate(y: newYPosition)
            // Visual feedback only
            
        case .bottom:
            let currentYPosition = containerViewModel.dateToYPosition(date: timeBlock.endDate)
            let newYPosition = currentYPosition + translation.height
            let proposedEndDate = containerViewModel.yPositionToDate(y: newYPosition)
            // Visual feedback only
        }
    }
    
    /// Handle resize end
    func handleResizeEnd(_ translation: CGSize, handle: TimeBlockViewModel.ResizeHandle) {
        guard let containerViewModel = containerViewModel else { return }
        
        switch handle {
        case .top:
            let currentYPosition = containerViewModel.dateToYPosition(date: timeBlock.startDate)
            let newYPosition = currentYPosition + translation.height
            let proposedStartDate = containerViewModel.yPositionToDate(y: newYPosition)
            containerViewModel.resizeBlockStart(timeBlock, to: proposedStartDate)
            
        case .bottom:
            let currentYPosition = containerViewModel.dateToYPosition(date: timeBlock.endDate)
            let newYPosition = currentYPosition + translation.height
            let proposedEndDate = containerViewModel.yPositionToDate(y: newYPosition)
            containerViewModel.resizeBlock(timeBlock, to: proposedEndDate)
        }
        
        containerViewModel.endDragging()
        updateResizeState(false)
    }
    
    // MARK: - Utility Methods
    
    /// Check if this represents the same time block
    func represents(_ otherTimeBlock: TimeBlock) -> Bool {
        timeBlock.timeBlockID == otherTimeBlock.timeBlockID
    }
    
    /// Get underlying time block (for container operations)
    var underlyingTimeBlock: TimeBlock {
        timeBlock
    }
}