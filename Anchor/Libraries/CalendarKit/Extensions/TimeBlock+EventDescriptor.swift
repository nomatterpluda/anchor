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
    
    public var text: String { name }
    
    public var attributedText: NSAttributedString? { nil }
    
    public var lineBreakMode: NSLineBreakMode? { nil }
    
    public var font: UIFont { .boldSystemFont(ofSize: 12) }
    
    public var color: UIColor { 
        UIColor(swiftUIColor)
    }
    
    public var textColor: UIColor { .white }
    
    public var backgroundColor: UIColor { 
        // If this TimeBlock is editing another (i.e., it's an editing copy),
        // make it more opaque for better visual feedback
        if editedEvent != nil {
            return color.withAlphaComponent(0.8)  // More opaque during editing
        } else {
            return color.withAlphaComponent(0.3)  // Normal transparency
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