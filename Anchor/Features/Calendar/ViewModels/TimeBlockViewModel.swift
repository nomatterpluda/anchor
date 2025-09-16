/*
 * TimeBlockViewModel.swift
 * 
 * TIME BLOCK MANAGEMENT VIEW MODEL
 * - Manages CRUD operations for time blocks within a single day
 * - Handles drag/drop, resize operations with 15-minute snapping
 * - Implements overlap prevention for block positioning
 * - Manages task assignments to time blocks
 * - Coordinates with calendar view for positioning calculations
 * - Follows MVVM pattern with SwiftData integration
 */

import Foundation
import SwiftUI
import SwiftData
import CoreGraphics
internal import Combine

@MainActor
class TimeBlockViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var timeBlocks: [TimeBlock] = []
    @Published var currentDate: Date = Date()
    @Published var selectedBlock: TimeBlock?
    
    // UI State
    @Published var isDragging: Bool = false
    @Published var draggedBlock: TimeBlock?
    @Published var isResizing: Bool = false
    @Published var resizeHandle: ResizeHandle?
    
    // Settings (configurable - will connect to settings later)
    @Published var defaultDurationMinutes: Int = 60 // 1 hour default
    
    // MARK: - Constants
    let hourHeight: CGFloat = 64 // Match CalendarGridView
    let snapIntervalMinutes: Int = 15 // 15-minute snapping
    
    // MARK: - Private Properties
    private var context: ModelContext?
    private let calendar = Calendar.current
    
    // MARK: - Types
    enum ResizeHandle {
        case top    // Drag top edge to change start time
        case bottom // Drag bottom edge to change end time
    }
    
    // MARK: - Initialization
    init(context: ModelContext? = nil) {
        self.context = context
        loadTimeBlocksForCurrentDate()
    }
    
    // MARK: - Setup
    func setContext(_ context: ModelContext) {
        self.context = context
        loadTimeBlocksForCurrentDate()
    }
    
    func setCurrentDate(_ date: Date) {
        currentDate = calendar.startOfDay(for: date)
        loadTimeBlocksForCurrentDate()
    }
}

// MARK: - Time/Position Conversion
extension TimeBlockViewModel {
    
    /// Convert a date/time to Y position on calendar grid
    func dateToYPosition(date: Date) -> CGFloat {
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        let totalMinutes = hour * 60 + minute
        let hourProgress = CGFloat(totalMinutes) / 60.0
        
        return hourProgress * hourHeight
    }
    
    /// Convert Y position to date/time for current date
    func yPositionToDate(y: CGFloat) -> Date {
        let hourProgress = y / hourHeight
        let totalMinutes = Int(hourProgress * 60)
        
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate) ?? currentDate
    }
    
    /// Snap date to nearest 15-minute interval
    func snapToGrid(date: Date) -> Date {
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let snappedMinute = (minute / snapIntervalMinutes) * snapIntervalMinutes
        
        return calendar.date(bySettingHour: hour, minute: snappedMinute, second: 0, of: date) ?? date
    }
    
    /// Get height in points for a given duration
    func heightForDuration(minutes: Int) -> CGFloat {
        let hours = CGFloat(minutes) / 60.0
        return hours * hourHeight
    }
    
    /// Get duration in minutes from height
    func durationFromHeight(_ height: CGFloat) -> Int {
        let hours = height / hourHeight
        return Int(hours * 60)
    }
}

// MARK: - Data Loading
extension TimeBlockViewModel {
    
    /// Load time blocks for current date from SwiftData
    private func loadTimeBlocksForCurrentDate() {
        guard let context = context else { return }
        
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let fetchDescriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { block in
                block.startDate >= startOfDay && block.startDate < endOfDay
            },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        
        do {
            timeBlocks = try context.fetch(fetchDescriptor)
        } catch {
            print("Failed to fetch time blocks: \(error)")
            timeBlocks = []
        }
    }
    
    /// Refresh data (call after external changes)
    func refresh() {
        loadTimeBlocksForCurrentDate()
    }
}

// MARK: - CRUD Operations
extension TimeBlockViewModel {
    
    /// Create a new time block at specified start time
    func createBlock(at startDate: Date, name: String = "New Block") {
        guard let context = context else { return }
        
        let snappedStart = snapToGrid(date: startDate)
        let endDate = calendar.date(byAdding: .minute, value: defaultDurationMinutes, to: snappedStart) ?? snappedStart
        
        // Check for overlap before creating
        guard canDropBlock(at: snappedStart, duration: TimeInterval(defaultDurationMinutes * 60)) else {
            print("Cannot create block: overlaps with existing block")
            return
        }
        
        let newBlock = TimeBlock(name: name, startDate: snappedStart, endDate: endDate)
        context.insert(newBlock)
        
        do {
            try context.save()
            loadTimeBlocksForCurrentDate()
            Haptic.shared.mediumImpact()
        } catch {
            print("Failed to save new time block: \(error)")
        }
    }
    
    /// Update an existing time block
    func updateBlock(_ block: TimeBlock) {
        guard let context = context else { return }
        
        block.lastUpdate = Date.now
        
        do {
            try context.save()
            loadTimeBlocksForCurrentDate()
        } catch {
            print("Failed to update time block: \(error)")
        }
    }
    
    /// Delete a time block
    func deleteBlock(_ block: TimeBlock) {
        guard let context = context else { return }
        
        context.delete(block)
        
        do {
            try context.save()
            loadTimeBlocksForCurrentDate()
            Haptic.shared.lightImpact()
        } catch {
            print("Failed to delete time block: \(error)")
        }
    }
}

// MARK: - Overlap Detection
extension TimeBlockViewModel {
    
    /// Check if a block can be placed at given time without overlapping
    func canDropBlock(at startDate: Date, duration: TimeInterval, excluding excludedBlock: TimeBlock? = nil) -> Bool {
        let endDate = startDate.addingTimeInterval(duration)
        
        for block in timeBlocks {
            // Skip the block being moved/resized
            if let excluded = excludedBlock, block.timeBlockID == excluded.timeBlockID {
                continue
            }
            
            // Check for overlap
            if startDate < block.endDate && endDate > block.startDate {
                return false
            }
        }
        
        return true
    }
    
    /// Find available time slot of given duration starting from specified time
    func findNextAvailableSlot(after startTime: Date, duration: TimeInterval) -> Date? {
        var searchTime = snapToGrid(date: startTime)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 45, second: 0, of: currentDate) ?? currentDate
        
        while searchTime < endOfDay {
            if canDropBlock(at: searchTime, duration: duration) {
                return searchTime
            }
            
            // Move to next 15-minute slot
            searchTime = calendar.date(byAdding: .minute, value: snapIntervalMinutes, to: searchTime) ?? searchTime
        }
        
        return nil
    }
}

// MARK: - Block Movement & Resizing
extension TimeBlockViewModel {
    
    /// Move a time block to new start time
    func moveBlock(_ block: TimeBlock, to newStartDate: Date) {
        let snappedStart = snapToGrid(date: newStartDate)
        let duration = block.duration
        
        // Check if new position is valid
        guard canDropBlock(at: snappedStart, duration: duration, excluding: block) else {
            return
        }
        
        block.startDate = snappedStart
        block.endDate = snappedStart.addingTimeInterval(duration)
        
        updateBlock(block)
    }
    
    /// Resize a time block to new end time
    func resizeBlock(_ block: TimeBlock, to newEndDate: Date) {
        let snappedEnd = snapToGrid(date: newEndDate)
        
        // Ensure minimum duration (15 minutes)
        let minimumEnd = calendar.date(byAdding: .minute, value: snapIntervalMinutes, to: block.startDate) ?? block.startDate
        let finalEndDate = max(snappedEnd, minimumEnd)
        
        let newDuration = finalEndDate.timeIntervalSince(block.startDate)
        
        // Check if new size is valid
        guard canDropBlock(at: block.startDate, duration: newDuration, excluding: block) else {
            return
        }
        
        block.endDate = finalEndDate
        updateBlock(block)
    }
    
    /// Resize block by changing start time (drag top edge)
    func resizeBlockStart(_ block: TimeBlock, to newStartDate: Date) {
        let snappedStart = snapToGrid(date: newStartDate)
        
        // Ensure minimum duration and start is before end
        let minimumStart = calendar.date(byAdding: .minute, value: -snapIntervalMinutes, to: block.endDate) ?? block.endDate
        let finalStartDate = min(snappedStart, minimumStart)
        
        let newDuration = block.endDate.timeIntervalSince(finalStartDate)
        
        // Check if new position is valid
        guard canDropBlock(at: finalStartDate, duration: newDuration, excluding: block) else {
            return
        }
        
        block.startDate = finalStartDate
        updateBlock(block)
    }
}

// MARK: - Drag State Management
extension TimeBlockViewModel {
    
    /// Start dragging a block
    func startDragging(_ block: TimeBlock) {
        isDragging = true
        draggedBlock = block
        selectedBlock = block
        Haptic.shared.lightImpact()
    }
    
    /// End dragging
    func endDragging() {
        isDragging = false
        draggedBlock = nil
        isResizing = false
        resizeHandle = nil
        Haptic.shared.lightImpact()
    }
    
    /// Start resizing a block
    func startResizing(_ block: TimeBlock, handle: ResizeHandle) {
        isResizing = true
        resizeHandle = handle
        selectedBlock = block
        Haptic.shared.lightImpact()
    }
}

// MARK: - Task Assignment
extension TimeBlockViewModel {
    
    /// Assign a task to a time block
    func assignTask(_ todo: Todo, to block: TimeBlock) {
        guard let context = context else { return }
        
        // Check if task is already assigned to this block
        let existingAssignment = block.assignments.first { assignment in
            assignment.todo?.taskID == todo.taskID
        }
        
        if existingAssignment != nil {
            return // Already assigned
        }
        
        // Create new assignment
        let assignment = TimeBlockAssignment.createAssignment(
            timeBlock: block,
            todo: todo,
            orderIndex: block.assignments.count
        )
        
        context.insert(assignment)
        
        do {
            try context.save()
            loadTimeBlocksForCurrentDate()
            Haptic.shared.softImpact()
        } catch {
            print("Failed to assign task to time block: \(error)")
        }
    }
    
    /// Remove a task from a time block
    func removeTask(_ todo: Todo, from block: TimeBlock) {
        guard let context = context else { return }
        
        // Find the assignment to remove
        guard let assignmentToRemove = block.assignments.first(where: { assignment in
            assignment.todo?.taskID == todo.taskID
        }) else { return }
        
        TimeBlockAssignment.removeAssignment(assignmentToRemove)
        context.delete(assignmentToRemove)
        
        do {
            try context.save()
            loadTimeBlocksForCurrentDate()
            Haptic.shared.softImpact()
        } catch {
            print("Failed to remove task from time block: \(error)")
        }
    }
    
    /// Move a task from one time block to another
    func moveTask(_ todo: Todo, from sourceBlock: TimeBlock, to targetBlock: TimeBlock) {
        // Remove from source
        removeTask(todo, from: sourceBlock)
        
        // Add to target (with small delay to ensure removal completes)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.assignTask(todo, to: targetBlock)
        }
    }
    
    /// Reorder tasks within a time block
    func reorderTasks(in block: TimeBlock, from sourceIndex: Int, to destinationIndex: Int) {
        TimeBlockAssignment.reorderAssignments(in: block, from: sourceIndex, to: destinationIndex)
        updateBlock(block)
    }
    
    /// Get tasks that can be assigned to time blocks (not completed)
    func getAssignableTasks() -> [Todo] {
        guard let context = context else { return [] }
        
        let fetchDescriptor = FetchDescriptor<Todo>(
            predicate: #Predicate<Todo> { todo in
                !todo.isCompleted
            },
            sortBy: [SortDescriptor(\.lastUpdate, order: .reverse)]
        )
        
        do {
            return try context.fetch(fetchDescriptor)
        } catch {
            print("Failed to fetch assignable tasks: \(error)")
            return []
        }
    }
}

// MARK: - Utility Methods
extension TimeBlockViewModel {
    
    /// Add 5 minutes to a time block (as mentioned in PRD)
    func addFiveMinutesToBlock(_ block: TimeBlock) {
        let newEndDate = calendar.date(byAdding: .minute, value: 5, to: block.endDate) ?? block.endDate
        let newDuration = newEndDate.timeIntervalSince(block.startDate)
        
        // Check if extension is valid (no overlaps)
        guard canDropBlock(at: block.startDate, duration: newDuration, excluding: block) else {
            return
        }
        
        block.addFiveMinutes()
        updateBlock(block)
    }
    
    /// Get block at specific Y position (for tap detection)
    func blockAt(yPosition: CGFloat) -> TimeBlock? {
        let tapDate = yPositionToDate(y: yPosition)
        
        return timeBlocks.first { block in
            tapDate >= block.startDate && tapDate <= block.endDate
        }
    }
    
    /// Get suggested name for new block based on time
    func suggestedBlockName(for startDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let hour = calendar.component(.hour, from: startDate)
        
        switch hour {
        case 6..<12:
            return "Morning Block"
        case 12..<17:
            return "Afternoon Block"
        case 17..<22:
            return "Evening Block"
        default:
            return "Block \(formatter.string(from: startDate))"
        }
    }
    
    /// Calculate total scheduled time for the day
    var totalScheduledMinutes: Int {
        timeBlocks.reduce(0) { total, block in
            total + block.durationInMinutes
        }
    }
    
    /// Get formatted total scheduled time
    var totalScheduledTimeString: String {
        let hours = totalScheduledMinutes / 60
        let minutes = totalScheduledMinutes % 60
        
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}