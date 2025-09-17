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
        color.withAlphaComponent(0.3) 
    }
    
    public var editedEvent: EventDescriptor? { 
        get { nil } 
        set { }
    }
    
    public func makeEditable() -> Self { 
        self 
    }
    
    public func commitEditing() { 
        lastUpdate = Date.now
    }
}