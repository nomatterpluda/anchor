/*
 * CalendarPageViewController.swift
 * 
 * CALENDAR DAY PAGINATION CONTROLLER
 * - UIKit/SwiftUI hybrid using UIPageViewController for native iOS pagination
 * - Smooth left/right swiping between days (+/- 1 day)
 * - Proper caching mechanism (limits to 10 view controllers)
 * - Haptic feedback on page changes
 * - Clean coordinator pattern for data source and delegate
 * - Hosts CalendarGridView for each day's content
 */

import SwiftUI
import UIKit

// MARK: - SwiftUI Wrapper for UIPageViewController
struct CalendarPageViewController: UIViewControllerRepresentable {
    @Binding var currentDate: Date
    let onDateChange: (Date) -> Void
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 0]
        )
        
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        
        // Set initial view controller (today)
        let initialViewController = context.coordinator.viewController(for: currentDate)
        pageViewController.setViewControllers(
            [initialViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
        
        return pageViewController
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        // Update if currentDate changed externally
        guard let currentViewController = uiViewController.viewControllers?.first as? CalendarViewController,
              !Calendar.current.isDate(currentViewController.date, inSameDayAs: currentDate) else {
            return
        }
        
        let newViewController = context.coordinator.viewController(for: currentDate)
        let direction: UIPageViewController.NavigationDirection = currentDate > currentViewController.date ? .forward : .reverse
        
        uiViewController.setViewControllers(
            [newViewController],
            direction: direction,
            animated: true,
            completion: nil
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: CalendarPageViewController
        private var viewControllerCache: [String: CalendarViewController] = [:]
        
        init(_ parent: CalendarPageViewController) {
            self.parent = parent
        }
        
        // MARK: - UIPageViewControllerDataSource
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let calendarVC = viewController as? CalendarViewController else { return nil }
            
            let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: calendarVC.date) ?? calendarVC.date
            return self.viewController(for: previousDate)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let calendarVC = viewController as? CalendarViewController else { return nil }
            
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: calendarVC.date) ?? calendarVC.date
            return self.viewController(for: nextDate)
        }
        
        // MARK: - UIPageViewControllerDelegate
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed,
                  let currentViewController = pageViewController.viewControllers?.first as? CalendarViewController else {
                return
            }
            
            // Update the binding and notify parent
            parent.currentDate = currentViewController.date
            parent.onDateChange(currentViewController.date)
            
            // Add haptic feedback
            Haptic.shared.lightImpact()
        }
        
        // MARK: - Helper Methods
        func viewController(for date: Date) -> CalendarViewController {
            let dateKey = DateFormatter.cacheKey.string(from: date)
            
            if let cachedViewController = viewControllerCache[dateKey] {
                return cachedViewController
            }
            
            let viewController = CalendarViewController(date: date, onDateChange: parent.onDateChange)
            viewControllerCache[dateKey] = viewController
            
            // Limit cache size to prevent memory issues
            if viewControllerCache.count > 10 {
                let oldestKey = viewControllerCache.keys.first!
                viewControllerCache.removeValue(forKey: oldestKey)
            }
            
            return viewController
        }
    }
}

// MARK: - UIViewController for Calendar Pages
class CalendarViewController: UIViewController {
    let date: Date
    let onDateChange: (Date) -> Void
    private var hostingController: UIHostingController<CalendarKitTimelineView>?
    
    init(date: Date, onDateChange: @escaping (Date) -> Void) {
        self.date = date
        self.onDateChange = onDateChange
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
    }
    
    private func setupCalendarView() {
        // Create SwiftUI CalendarKitTimelineView (replaces CalendarGridView)
        let calendarView = CalendarKitTimelineView(
            displayDate: date,
            onDateChange: onDateChange
        )
        
        // Wrap in UIHostingController
        hostingController = UIHostingController(rootView: calendarView)
        
        guard let hostingController = hostingController else { return }
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Setup constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Ensure background is clear
        hostingController.view.backgroundColor = .clear
        view.backgroundColor = .clear
    }
}

// MARK: - DateFormatter Extension
private extension DateFormatter {
    static let cacheKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}