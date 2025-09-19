/*
 * AnchorDayViewController.swift
 * 
 * CALENDARKIT DAY VIEW CONTROLLER WITH SWIFTDATA
 * - Inherits from CalendarKit's DayViewController for full editing capabilities
 * - Integrates with SwiftData for TimeBlock persistence
 * - Handles drag/resize operations and saves changes
 * - Provides tap-to-edit and long-press-to-create functionality
 * - Replaces the old TimeBlockCalendarViewController approach
 */

import UIKit
import SwiftData
import SwiftUI

class AnchorDayViewController: DayViewController {
    
    // MARK: - Properties
    
    /// SwiftData ModelContext for fetching and saving TimeBlocks
    var modelContext: ModelContext? {
        didSet {
            // Reload data when context is set
            if modelContext != nil {
                reloadData()
            }
        }
    }
    
    /// Current date being displayed
    private var currentDate: Date = Date()
    
    /// Callback to notify SwiftUI when date changes
    var onDateChange: ((Date) -> Void)?
    
    /// Track last processed update to prevent duplicate saves
    private var lastProcessedUpdate: (timeBlockID: String, timestamp: Date) = ("", Date.distantPast)
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupCalendarKitConfiguration()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCalendarKitConfiguration()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force light theme to match our white calendar overlay
        overrideUserInterfaceStyle = .light
        dayView.overrideUserInterfaceStyle = .light
        
        // Configure appearance
        view.backgroundColor = UIColor.white
        
        // Ensure interaction is enabled
        dayView.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        
        print("🗓️ AnchorDayViewController loaded for date: \(currentDate)")
        print("🗓️ DayView interaction enabled: \(dayView.isUserInteractionEnabled)")
        print("🗓️ Root view interaction enabled: \(view.isUserInteractionEnabled)")
        print("🗓️ DataSource: \(String(describing: dataSource))")
        print("🗓️ Delegate: \(String(describing: delegate))")
        
        // Debug touch events
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(debugTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func debugTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        print("🖱️ Debug tap detected at: \(location)")
    }
    
    // MARK: - Configuration
    
    private func setupCalendarKitConfiguration() {
        // Configure editing behavior
        eventEditingSnappingBehavior = SnapTo15MinuteIntervals()
        
        // Set up style - use proper nested structure
        var style = CalendarStyle()
        style.timeline.backgroundColor = UIColor.white
        style.timeline.timeIndicator.color = UIColor.systemRed
        style.timeline.timeColor = UIColor.darkGray
        style.timeline.separatorColor = UIColor.lightGray
        style.timeline.minimumEventDurationInMinutesWhileEditing = 30
        
        updateStyle(style)
        
        print("⚙️ CalendarKit configuration completed")
        print("⚙️ Event editing snapping: \(eventEditingSnappingBehavior)")
    }
    
    // MARK: - Public Methods
    
    /// Move to a specific date
    func moveToDate(_ date: Date) {
        currentDate = date
        move(to: date)
        onDateChange?(date)
        print("📅 Moved to date: \(date)")
    }
    
    // MARK: - EventDataSource Override
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        guard let modelContext = modelContext else {
            print("⚠️ ModelContext not available - returning empty events")
            return []
        }
        
        // Convert the date to local timezone for proper day boundaries
        let calendar = Calendar.current
        let timeZone = TimeZone.current
        
        // Get date components in local timezone
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.timeZone = timeZone
        
        // Create start of day in local timezone
        guard let localStartOfDay = calendar.date(from: dateComponents) else {
            print("⚠️ Failed to create local start of day")
            return []
        }
        
        // Create end of day in local timezone
        guard let localEndOfDay = calendar.date(byAdding: .day, value: 1, to: localStartOfDay) else {
            print("⚠️ Failed to create local end of day")
            return []
        }
        
        print("🔍 Fetching events for date: \(date)")
        print("🔍 Local start of day: \(localStartOfDay)")
        print("🔍 Local end of day: \(localEndOfDay)")
        
        // Create fetch descriptor for TimeBlocks on this date
        let fetchDescriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { timeBlock in
                timeBlock.startDate >= localStartOfDay && timeBlock.startDate < localEndOfDay
            },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        
        do {
            let timeBlocks = try modelContext.fetch(fetchDescriptor)
            print("📦 Fetched \(timeBlocks.count) TimeBlocks for \(date)")
            
            // Debug: show each TimeBlock's time range
            for timeBlock in timeBlocks {
                print("   📦 TimeBlock: '\(timeBlock.name)' from \(timeBlock.startDate) to \(timeBlock.endDate)")
            }
            
            // TimeBlocks already conform to EventDescriptor
            return timeBlocks
        } catch {
            print("❌ Failed to fetch TimeBlocks: \(error)")
            return []
        }
    }
    
    // MARK: - DayViewDelegate Overrides
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        print("👆 Event tapped - EventView: \(eventView)")
        print("   Descriptor: \(String(describing: eventView.descriptor))")
        
        guard let timeBlock = eventView.descriptor as? TimeBlock else {
            print("⚠️ Selected event is not a TimeBlock")
            return
        }
        
        print("📄 Single tap - should navigate to TimeBlock detail page")
        print("   TimeBlock: \(timeBlock.name)")
        print("   TimeBlock ID: \(timeBlock.timeBlockID)")
        
        // TODO: Navigate to TimeBlock detail page when implemented
        // For now, just log that this should navigate
        print("🚧 Navigation to TimeBlock detail page not implemented yet")
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        print("🔗 Long press on existing event - entering edit mode")
        print("   EventView: \(eventView)")
        
        guard let timeBlock = eventView.descriptor as? TimeBlock else {
            print("⚠️ Long pressed event is not a TimeBlock")
            return
        }
        
        print("✏️ Starting edit mode for TimeBlock: \(timeBlock.name)")
        print("   TimeBlock ID: \(timeBlock.timeBlockID)")
        
        // Start editing mode for drag/resize - this will create an editing copy via makeEditable()
        beginEditing(event: timeBlock, animated: true)
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        print("👆 Timeline tapped at: \(date)")
        
        // Exit edit mode when tapping empty space
        print("🚪 Exiting edit mode due to empty timeline tap")
        endEventEditing()
        
        // Force reload to clear any visual editing artifacts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadData()
        }
        
        super.dayView(dayView: dayView, didTapTimelineAt: date)
    }
    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        print("➕ Creating new TimeBlock at: \(date)")
        createNewTimeBlock(at: date)
    }
    
    // Add more delegate debugging
    override func dayViewDidBeginDragging(dayView: DayView) {
        print("🖱️ Drag began")
        super.dayViewDidBeginDragging(dayView: dayView)
    }
    
    override func dayView(dayView: DayView, willMoveTo date: Date) {
        print("📅 Will move to: \(date)")
        super.dayView(dayView: dayView, willMoveTo: date)
    }
    
    override func dayView(dayView: DayView, didMoveTo date: Date) {
        print("📅 Did move to: \(date)")
        super.dayView(dayView: dayView, didMoveTo: date)
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let timeBlock = event as? TimeBlock else {
            print("⚠️ Updated event is not a TimeBlock")
            return
        }
        
        // Prevent duplicate processing of the same update
        let now = Date()
        if lastProcessedUpdate.timeBlockID == timeBlock.timeBlockID && 
           now.timeIntervalSince(lastProcessedUpdate.timestamp) < 0.5 {
            print("🔄 Skipping duplicate update for TimeBlock: \(timeBlock.name)")
            return
        }
        lastProcessedUpdate = (timeBlock.timeBlockID, now)
        
        print("💾 Updating TimeBlock: \(timeBlock.name)")
        print("   New time: \(timeBlock.dateInterval)")
        
        guard let modelContext = modelContext else {
            print("⚠️ Cannot save - ModelContext not available")
            return
        }
        
        // Find the original TimeBlock in SwiftData and update it
        do {
            let targetID = timeBlock.timeBlockID
            let descriptor = FetchDescriptor<TimeBlock>(predicate: #Predicate<TimeBlock> { block in
                block.timeBlockID == targetID
            })
            let existingBlocks = try modelContext.fetch(descriptor)
            
            if let originalTimeBlock = existingBlocks.first {
                // Update the original TimeBlock with new times
                originalTimeBlock.startDate = timeBlock.startDate
                originalTimeBlock.endDate = timeBlock.endDate
                originalTimeBlock.lastUpdate = Date.now
                print("✅ Updated original TimeBlock in SwiftData")
            } else {
                print("⚠️ Could not find original TimeBlock to update")
            }
        } catch {
            print("⚠️ Error finding original TimeBlock: \(error)")
        }
        
        // Commit editing to clear visual state (this handles the editing copy)
        timeBlock.commitEditing()
        
        // Save changes to SwiftData
        saveChanges()
        
        // End editing mode and reload to show the updated original
        endEventEditing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadData()
        }
    }
    
    // MARK: - TimeBlock Management
    
    private func createNewTimeBlock(at date: Date) {
        guard let modelContext = modelContext else {
            print("⚠️ Cannot create TimeBlock - ModelContext not available")
            return
        }
        
        // Create new TimeBlock with 1 hour duration
        let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
        let newTimeBlock = TimeBlock(
            name: "New Task",
            startDate: date,
            endDate: endDate
        )
        
        // Insert the ORIGINAL TimeBlock into SwiftData immediately
        // CalendarKit will create its own editing copy for the UI
        modelContext.insert(newTimeBlock)
        saveChanges()
        
        // Start editing the new TimeBlock (CalendarKit will create editing copy)
        beginEditing(event: newTimeBlock, animated: true)
        
        print("✅ Created and inserted new TimeBlock: \(newTimeBlock.name)")
        print("   TimeBlock ID: \(newTimeBlock.timeBlockID)")
    }
    
    private func saveChanges() {
        guard let modelContext = modelContext else {
            print("⚠️ Cannot save - ModelContext not available")
            return
        }
        
        // Ensure SwiftData operations are on main thread
        DispatchQueue.main.async {
            do {
                try modelContext.save()
                print("💾 SwiftData changes saved successfully")
            } catch {
                print("❌ Failed to save SwiftData changes: \(error)")
            }
        }
    }
}