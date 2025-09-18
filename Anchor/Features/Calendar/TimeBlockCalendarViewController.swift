import UIKit
import SwiftData

class TimeBlockCalendarViewController: UIViewController, TimelineViewDelegate {
    
    private let timelineContainer: TimelineContainerController
    private let calendar = Calendar.current
    private var currentDate: Date = Date()
    
    // SwiftData ModelContext for fetching TimeBlocks
    var modelContext: ModelContext?
    
    // Callback to communicate date changes back to SwiftUI
    var onDateChange: ((Date) -> Void)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.timelineContainer = TimelineContainerController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        self.timelineContainer = TimelineContainerController()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow timeline to extend into full space
        edgesForExtendedLayout = .all
        
        // Force light theme
        overrideUserInterfaceStyle = .light
        view.overrideUserInterfaceStyle = .light
        
        // Setup timeline container directly (single day, no horizontal paging)
        setupTimeline()
        
        // Ensure clean background
        view.backgroundColor = UIColor.white
    }
    
    private func setupTimeline() {
        // Configure timeline appearance for light theme
        var style = TimelineStyle()
        style.backgroundColor = UIColor.white
        style.timeIndicator.color = UIColor.systemRed
        style.timeColor = UIColor.darkGray
        style.separatorColor = UIColor.lightGray
        timelineContainer.timeline.updateStyle(style)
        
        // Set up delegate for handling user interactions
        timelineContainer.timeline.delegate = self
        
        // Add as child view controller
        addChild(timelineContainer)
        view.addSubview(timelineContainer.view)
        timelineContainer.didMove(toParent: self)
        
        // Setup constraints to fill entire space
        timelineContainer.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineContainer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timelineContainer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timelineContainer.view.topAnchor.constraint(equalTo: view.topAnchor),
            timelineContainer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func move(to date: Date) {
        // Store current date and update timeline
        currentDate = date
        timelineContainer.timeline.date = currentDate
        
        // Get events for this date
        let events = eventsForDate(currentDate)
        
        // Convert to layout attributes and set on timeline
        let layoutAttributes = events.map(EventLayoutAttributes.init)
        timelineContainer.timeline.layoutAttributes = layoutAttributes
    }
    
    // MARK: - Event Management
    private func eventsForDate(_ date: Date) -> [EventDescriptor] {
        guard let modelContext = modelContext else { 
            print("ModelContext not available for fetching TimeBlocks")
            return [] 
        }
        
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let fetchDescriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { block in
                block.startDate >= startOfDay && block.startDate < endOfDay
            },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        
        do {
            let timeBlocks = try modelContext.fetch(fetchDescriptor)
            return timeBlocks  // TimeBlock already conforms to EventDescriptor
        } catch {
            print("Failed to fetch time blocks: \(error)")
            return []
        }
    }
}

// MARK: - TimelineViewDelegate
extension TimeBlockCalendarViewController {
    func timelineView(_ timelineView: TimelineView, didTapAt date: Date) {
        // Handle tap on empty space - could be used for quick event creation
        print("Tapped at: \(date)")
    }
    
    func timelineView(_ timelineView: TimelineView, didLongPressAt date: Date) {
        // Handle long press on empty space - create new TimeBlock
        createTimeBlock(at: date)
    }
    
    func timelineView(_ timelineView: TimelineView, didTap event: EventView) {
        // Handle tap on existing event - could be used for editing
        print("Tapped event: \(event)")
    }
    
    func timelineView(_ timelineView: TimelineView, didLongPress event: EventView) {
        // Handle long press on existing event - could be used for context menu
        print("Long pressed event: \(event)")
    }
    
    private func createTimeBlock(at date: Date) {
        guard let modelContext = modelContext else {
            print("ModelContext not available for creating TimeBlock")
            return
        }
        
        // Create a new TimeBlock at the pressed time with 1 hour duration
        let endDate = calendar.date(byAdding: .hour, value: 1, to: date) ?? date
        
        let newTimeBlock = TimeBlock(
            name: "New Task",
            startDate: date,
            endDate: endDate
        )
        
        // Save to SwiftData
        modelContext.insert(newTimeBlock)
        
        do {
            try modelContext.save()
            print("Created new TimeBlock: \(newTimeBlock.name) at \(date)")
            
            // Refresh the timeline to show the new event
            move(to: currentDate)
        } catch {
            print("Failed to save new TimeBlock: \(error)")
        }
    }
}