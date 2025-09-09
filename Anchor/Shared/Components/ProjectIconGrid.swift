/*
 * ProjectIconGrid.swift
 * 
 * REUSABLE PROJECT ICON GRID COMPONENT
 * - Displays SF Symbols in a 6-column grid layout
 * - Uses centralized ProjectIcons data source
 * - Handles selection state and animations
 * - Customizable columns and spacing
 * - Reusable across AddProjectSheet, EditProjectSheet, etc.
 */

import SwiftUI

struct ProjectIconGrid: View {
    @Binding var selectedIcon: String
    let columns: Int
    let spacing: CGFloat
    let onSelection: (() -> Void)?
    
    // Grid configuration
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
    
    // MARK: - Initializers
    
    /// Standard 6-column grid with default spacing
    init(selectedIcon: Binding<String>, onSelection: (() -> Void)? = nil) {
        self._selectedIcon = selectedIcon
        self.columns = 6
        self.spacing = 12
        self.onSelection = onSelection
    }
    
    /// Custom grid configuration
    init(
        selectedIcon: Binding<String>,
        columns: Int,
        spacing: CGFloat = 12,
        onSelection: (() -> Void)? = nil
    ) {
        self._selectedIcon = selectedIcon
        self.columns = columns
        self.spacing = spacing
        self.onSelection = onSelection
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: gridColumns, spacing: spacing) {
                ForEach(ProjectIcons.allIcons, id: \.self) { icon in
                    IconGridItem(
                        icon: icon,
                        isSelected: selectedIcon == icon
                    ) {
                        Haptic.shared.lightImpact()
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedIcon = icon
                        }
                        onSelection?()
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxHeight: 3 * (44 + spacing) - spacing) // Limit to 3 rows: 3 * (icon height + spacing) - last spacing
    }
}

// MARK: - Convenience Extensions
extension ProjectIconGrid {
    /// Create grid with custom selection handler
    static func withSelectionHandler(
        selectedIcon: Binding<String>,
        onSelection: @escaping (String) -> Void
    ) -> some View {
        ProjectIconGrid(selectedIcon: selectedIcon) {
            onSelection(selectedIcon.wrappedValue)
        }
    }
}

#Preview {
    @Previewable @State var selectedIcon = "folder.fill"
    
    ScrollView {
        VStack(spacing: 20) {
            Text("Selected: \(selectedIcon)")
                .font(.headline)
            
            ProjectIconGrid(selectedIcon: $selectedIcon)
                .padding(.horizontal, 20)
        }
    }
    .background(.black)
}