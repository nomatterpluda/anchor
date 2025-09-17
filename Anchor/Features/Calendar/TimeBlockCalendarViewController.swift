import UIKit
import SwiftData

class TimeBlockCalendarViewController: UIViewController {
    
    private let timelineContainer: TimelineContainerController
    private let calendar = Calendar.current
    private var currentDate: Date = Date()
    
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
        
        // TimelineView doesn't use dataSource - we'll set layoutAttributes directly
        
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
        // Use currentDate instead of parameter (since we manage dates ourselves)
        let calendar = Calendar.current
        
        // Create test TimeBlock for today only
        guard calendar.isDate(currentDate, inSameDayAs: Date()) else {
            return []
        }
        
        let testBlock1 = TimeBlock(
            name: "Morning Meeting",
            startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: currentDate) ?? currentDate,
            endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: currentDate) ?? currentDate
        )
        
        let testBlock2 = TimeBlock(
            name: "Deep Work",
            startDate: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: currentDate) ?? currentDate,
            endDate: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: currentDate) ?? currentDate
        )
        
        return [testBlock1, testBlock2]
    }
}