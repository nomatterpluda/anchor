import Foundation
import UIKit
import SwiftUI
import SwiftData

extension TimeBlock: EventDescriptor {
    public var dateInterval: DateInterval { 
        get { DateInterval(start: startDate, end: endDate) }
        set { 
            startDate = newValue.start
            endDate = newValue.end
        }
    }
    
    public var isAllDay: Bool { false }
    
    public var text: String { 
        // This is now handled by the custom EventView layout
        return name
    }
    
    public var attributedText: NSAttributedString? { nil }
    
    public var lineBreakMode: NSLineBreakMode? { nil }
    
    public var font: UIFont { 
        // Use lighter weight for placeholder text
        if todos.isEmpty {
            return .systemFont(ofSize: 12, weight: .medium)
        } else {
            return .boldSystemFont(ofSize: 12)
        }
    }
    
    public var color: UIColor { 
        // For empty blocks, use the subtle grey color from Figma design
        if todos.isEmpty {
            return UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0)
        } else {
            return UIColor(swiftUIColor)
        }
    }
    
    public var textColor: UIColor { 
        // For empty blocks, use darker grey text for better readability
        if todos.isEmpty {
            return UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1.0) // Similar to system gray
        } else {
            return .white
        }
    }
    
    public var backgroundColor: UIColor { 
        // For empty blocks, use the subtle background from Figma
        if todos.isEmpty {
            return UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 0.1)
        } else {
            // If this TimeBlock is editing another (i.e., it's an editing copy),
            // make it more opaque for better visual feedback
            if editedEvent != nil {
                return color.withAlphaComponent(0.8)  // More opaque during editing
            } else {
                return color.withAlphaComponent(0.3)  // Normal transparency
            }
        }
    }
    
    // Storage for tracking which TimeBlock this one is editing (if any)
    private static var editingStorage = [String: TimeBlock]()
    
    public var editedEvent: EventDescriptor? { 
        get { 
            return Self.editingStorage[timeBlockID]
        }
        set { 
            if let originalTimeBlock = newValue as? TimeBlock {
                Self.editingStorage[timeBlockID] = originalTimeBlock
            } else {
                Self.editingStorage.removeValue(forKey: timeBlockID)
            }
        }
    }
    
    public func makeEditable() -> Self {
        // Create a copy TimeBlock for editing (following CalendarKit's Event pattern)
        let editingCopy = TimeBlock(
            name: self.name,
            startDate: self.startDate, 
            endDate: self.endDate,
            iconName: self.iconName
        )
        
        // Copy other properties
        editingCopy.colorID = self.colorID
        editingCopy.isManualColor = self.isManualColor
        editingCopy.notes = self.notes
        editingCopy.hasStartNotification = self.hasStartNotification
        editingCopy.hasEndNotification = self.hasEndNotification
        
        // Set up editing relationship - the copy points to the original
        editingCopy.editedEvent = self
        
        return editingCopy as! Self
    }
    
    public func commitEditing() { 
        guard let originalTimeBlock = editedEvent as? TimeBlock else {
            // This TimeBlock is not editing anything - just update timestamp
            lastUpdate = Date.now
            return
        }
        
        // This is an editing copy - apply changes to the original
        originalTimeBlock.startDate = self.startDate
        originalTimeBlock.endDate = self.endDate
        originalTimeBlock.lastUpdate = Date.now
        
        print("✅ TimeBlock editing committed: '\(originalTimeBlock.name)' updated to \(self.dateInterval)")
        
        // Clear the editing relationship
        self.editedEvent = nil
    }
}