/*
 * ProjectIcons.swift
 * 
 * CENTRALIZED PROJECT ICON DATA SOURCE
 * - Contains curated collection of SF Symbols for project icons
 * - Organized by category for easy browsing and maintenance
 * - Used by ProjectIconGrid component and anywhere icons are needed
 * - Easily extensible for future icon additions
 */

import Foundation

struct ProjectIcons {
    
    // MARK: - All Available Icons
    static let allIcons: [String] = [
        // Folders & Documents
        "folder.fill",
        "doc.fill", 
        "doc.text.fill",
        "bookmark.fill",
        "archivebox.fill",
        "tray.fill",
        
        // Common Symbols
        "star.fill",
        "heart.fill", 
        "flag.fill",
        "tag.fill",
        "target",
        "checkmark.circle.fill",
        
        // Communication & Work
        "paperplane.fill",
        "envelope.fill",
        "phone.fill",
        "message.fill",
        "megaphone.fill",
        "bell.fill",
        
        // Creative & Media
        "lightbulb.fill",
        "paintbrush.fill",
        "camera.fill",
        "photo.fill",
        "music.note",
        "headphones",
        
        // Activities & Hobbies
        "gamecontroller.fill",
        "sportscourt.fill",
        "dumbbell.fill",
        "book.fill",
        "graduationcap.fill",
        "airplane",
        
        // Life & Home
        "car.fill",
        "house.fill",
        "building.fill",
        "bed.double.fill",
        "sofa.fill",
        "cart.fill",
        
        // Nature & Weather  
        "leaf.fill",
        "tree.fill",
        "flame.fill",
        "drop.fill",
        "snow",
        "sun.max.fill",
        "moon.fill",
        "cloud.fill",
        "bolt.fill",
        "rainbow",
        
        // Food & Drink
        "cup.and.saucer.fill",
        "fork.knife",
        "wineglass.fill",
        "birthday.cake.fill",
        "carrot.fill",
        "apple.logo"
    ]
    
    // MARK: - Default Icon
    static let defaultIcon = "folder.fill"
    
    // MARK: - Convenience Methods
    
    /// Check if an icon exists in the collection
    static func contains(_ icon: String) -> Bool {
        return allIcons.contains(icon)
    }
    
    /// Get a random icon from the collection
    static func randomIcon() -> String {
        return allIcons.randomElement() ?? defaultIcon
    }
    
    /// Get icons by category (future enhancement)
    static func iconsByCategory() -> [String: [String]] {
        return [
            "Folders & Documents": Array(allIcons[0..<6]),
            "Common Symbols": Array(allIcons[6..<12]),
            "Communication & Work": Array(allIcons[12..<18]),
            "Creative & Media": Array(allIcons[18..<24]),
            "Activities & Hobbies": Array(allIcons[24..<30]),
            "Life & Home": Array(allIcons[30..<36]),
            "Nature & Weather": Array(allIcons[36..<45]),
            "Food & Drink": Array(allIcons[45..<51])
        ]
    }
}