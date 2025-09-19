import UIKit
import SwiftData

open class EventView: UIView {
    public var descriptor: EventDescriptor?
    public var color = SystemColors.label
    
    public var contentHeight: Double {
        textView.frame.height
    }
    
    public private(set) lazy var textView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.clipsToBounds = true
        return view
    }()
    
    /// Custom content view for TimeBlocks with complex layout
    private lazy var timeBlockContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    // TimeBlock UI components
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 0.2)
        view.layer.cornerRadius = 9.5 // 19x19 circle
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor.withDesign(.rounded)!
            label.font = UIFont(descriptor: descriptor, size: 17)
        } else {
            label.font = .systemFont(ofSize: 17, weight: .semibold)
        }
        label.textColor = UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var durationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 0.05)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            let descriptor = UIFont.systemFont(ofSize: 11, weight: .semibold).fontDescriptor.withDesign(.rounded)!
            label.font = UIFont(descriptor: descriptor, size: 11)
        } else {
            label.font = .systemFont(ofSize: 11, weight: .semibold)
        }
        label.textColor = UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var bottomActionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var addTasksLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            let descriptor = UIFont.systemFont(ofSize: 14, weight: .medium).fontDescriptor.withDesign(.rounded)!
            label.font = UIFont(descriptor: descriptor, size: 14)
        } else {
            label.font = .systemFont(ofSize: 14, weight: .medium)
        }
        label.textColor = UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 1.0)
        label.text = "Add or drag tasks"
        return label
    }()
    
    private lazy var plusIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus.circle.fill")
        imageView.tintColor = UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Resize Handle views showing up when editing the event.
    /// The top handle has a tag of `0` and the bottom has a tag of `1`
    public private(set) lazy var eventResizeHandles = [EventResizeHandleView(), EventResizeHandleView()]
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        clipsToBounds = false
        color = tintColor
        addSubview(textView)
        
        // Set up TimeBlock content view
        setupTimeBlockContentView()
        
        for (idx, handle) in eventResizeHandles.enumerated() {
            handle.tag = idx
            addSubview(handle)
        }
    }
    
    private func setupTimeBlockContentView() {
        addSubview(timeBlockContentView)
        
        // Add icon container and icon
        timeBlockContentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        
        // Add title
        timeBlockContentView.addSubview(titleLabel)
        
        // Add duration container and label
        timeBlockContentView.addSubview(durationContainerView)
        durationContainerView.addSubview(durationLabel)
        
        // Add bottom action
        timeBlockContentView.addSubview(bottomActionView)
        bottomActionView.addSubview(plusIconImageView)
        bottomActionView.addSubview(addTasksLabel)
        
        // Initially hide the TimeBlock content view
        timeBlockContentView.isHidden = true
    }
    
    public func updateWithDescriptor(event: EventDescriptor) {
        descriptor = event
        backgroundColor = .clear
        layer.backgroundColor = event.backgroundColor.cgColor
        layer.cornerRadius = 12 // Updated to match Figma design
        color = event.color
        eventResizeHandles.forEach{
            $0.borderColor = event.color
            $0.isHidden = event.editedEvent == nil
        }
        drawsShadow = event.editedEvent != nil
        
        // Check if this is a TimeBlock
        if let timeBlock = event as? TimeBlock {
            setupTimeBlockLayout(timeBlock: timeBlock)
            textView.isHidden = true
            timeBlockContentView.isHidden = false
        } else {
            // Use regular text view for other event types
            if let attributedText = event.attributedText {
                textView.attributedText = attributedText
                textView.setNeedsLayout()
            } else {
                textView.text = event.text
                textView.textColor = event.textColor
                textView.font = event.font
            }
            if let lineBreakMode = event.lineBreakMode {
                textView.textContainer.lineBreakMode = lineBreakMode
            }
            textView.isHidden = false
            timeBlockContentView.isHidden = true
        }
        
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    private func setupTimeBlockLayout(timeBlock: TimeBlock) {
        // Set up icon with custom font configuration
        let iconName = timeBlock.iconName.isEmpty ? "clock" : timeBlock.iconName
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 8.5, weight: .bold)
        iconImageView.image = UIImage(systemName: iconName, withConfiguration: iconConfig)
        
        // Set up title
        titleLabel.text = timeBlock.name
        
        // Set up duration
        durationLabel.text = timeBlock.formattedDuration
        
        // Colors are already set in the lazy properties to match #212121
        // Icon container background is already set to black 20% opacity
        // Duration container background is already set to #212121 5% opacity
        
        // Show/hide bottom action based on empty state
        let isEmpty = timeBlock.todos.isEmpty
        bottomActionView.isHidden = !isEmpty
    }
    
    public func animateCreation() {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        func scaleAnimation() {
            transform = .identity
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 10,
                       options: [],
                       animations: scaleAnimation,
                       completion: nil)
    }
    
    /**
     Custom implementation of the hitTest method is needed for the tap gesture recognizers
     located in the ResizeHandleView to work.
     Since the ResizeHandleView could be outside of the EventView's bounds, the touches to the ResizeHandleView
     are ignored.
     In the custom implementation the method is recursively invoked for all of the subviews,
     regardless of their position in relation to the Timeline's bounds.
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for resizeHandle in eventResizeHandles {
            if let subSubView = resizeHandle.hitTest(convert(point, to: resizeHandle), with: event) {
                return subSubView
            }
        }
        return super.hitTest(point, with: event)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Check if this is an empty time block (no tasks assigned)
        let isEmptyBlock = (descriptor as? TimeBlock)?.todos.isEmpty ?? false
        
        // Don't draw the left border line for empty blocks to match Figma design
        if isEmptyBlock {
            return
        }
        
        // Draw left border line for blocks with tasks
        context.interpolationQuality = .none
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(3)
        context.setLineCap(.round)
        context.translateBy(x: 0, y: 0.5)
        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let x: Double = leftToRight ? 0 : frame.width - 1.0  // 1 is the line width
        let y: Double = 0
        let hOffset: Double = 3
        let vOffset: Double = 5
        context.beginPath()
        context.move(to: CGPoint(x: x + 2 * hOffset, y: y + vOffset))
        context.addLine(to: CGPoint(x: x + 2 * hOffset, y: (bounds).height - vOffset))
        context.strokePath()
        context.restoreGState()
    }
    
    private var drawsShadow = false
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout regular text view
        textView.frame = {
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
                return CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width - 3, height: bounds.height)
            } else {
                return CGRect(x: bounds.minX + 8, y: bounds.minY, width: bounds.width - 6, height: bounds.height)
            }
        }()
        if frame.minY < 0 {
            var textFrame = textView.frame;
            textFrame.origin.y = frame.minY * -1;
            textFrame.size.height += frame.minY;
            textView.frame = textFrame;
        }
        
        // Layout TimeBlock content view
        layoutTimeBlockContent()
        
        // Layout resize handles
        let first = eventResizeHandles.first
        let last = eventResizeHandles.last
        let radius: Double = 40
        let yPad: Double =  -radius / 2
        let width = bounds.width
        let height = bounds.height
        let size = CGSize(width: radius, height: radius)
        first?.frame = CGRect(origin: CGPoint(x: width - radius - layoutMargins.right, y: yPad),
                              size: size)
        last?.frame = CGRect(origin: CGPoint(x: layoutMargins.left, y: height - yPad - radius),
                             size: size)
        
        if drawsShadow {
            applySketchShadow(alpha: 0.13,
                              blur: 10)
        }
    }
    
    private func layoutTimeBlockContent() {
        guard !timeBlockContentView.isHidden else { return }
        
        let padding: CGFloat = 10
        let iconContainerSize: CGFloat = 19
        let bottomActionHeight: CGFloat = 20
        let spacing: CGFloat = 8
        
        // Set the content view frame (with 10px internal padding)
        timeBlockContentView.frame = bounds.insetBy(dx: padding, dy: padding)
        
        let contentBounds = timeBlockContentView.bounds
        let availableHeight = contentBounds.height
        let topRowHeight: CGFloat = iconContainerSize // Height for icon + title row
        
        // Icon container (19x19 circle)
        iconContainerView.frame = CGRect(x: 0, y: 0, width: iconContainerSize, height: iconContainerSize)
        
        // Icon inside container (centered)
        iconImageView.frame = CGRect(x: 3, y: 3, width: 13, height: 13) // Centered in 19x19 container
        
        // Duration container (capsule) - size to fit content with padding
        durationLabel.sizeToFit()
        let durationContentWidth = durationLabel.bounds.width
        let durationContainerWidth = durationContentWidth + 8 // 4px horizontal padding each side
        let durationContainerHeight: CGFloat = 19 // Height to match icon container
        
        durationContainerView.frame = CGRect(
            x: contentBounds.width - durationContainerWidth,
            y: 0,
            width: durationContainerWidth,
            height: durationContainerHeight
        )
        
        // Duration label inside container with 4px horizontal, 2px vertical padding
        durationLabel.frame = CGRect(
            x: 4,
            y: 2,
            width: durationContentWidth,
            height: durationContainerHeight - 4
        )
        
        // Title label (between icon and duration)
        let titleX = iconContainerView.frame.maxX + spacing
        let titleWidth = durationContainerView.frame.minX - titleX - spacing
        let titleFrame = CGRect(
            x: titleX,
            y: 0,
            width: titleWidth,
            height: topRowHeight
        )
        titleLabel.frame = titleFrame
        
        // Bottom action view (if there's enough space)
        if !bottomActionView.isHidden && availableHeight > topRowHeight + bottomActionHeight + spacing {
            let bottomY = contentBounds.height - bottomActionHeight
            bottomActionView.frame = CGRect(
                x: 0,
                y: bottomY,
                width: contentBounds.width,
                height: bottomActionHeight
            )
            
            // Layout plus icon and label within bottom action view
            let plusIconSize: CGFloat = 14
            plusIconImageView.frame = CGRect(x: 0, y: 3, width: plusIconSize, height: plusIconSize)
            
            addTasksLabel.sizeToFit()
            addTasksLabel.frame = CGRect(
                x: plusIconSize + 6,
                y: 0,
                width: addTasksLabel.bounds.width,
                height: bottomActionHeight
            )
        } else {
            // Hide bottom action if there's not enough space
            bottomActionView.isHidden = true
        }
    }
    
    private func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: Double = 0,
        y: Double = 2,
        blur: Double = 4,
        spread: Double = 0)
    {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2.0
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
