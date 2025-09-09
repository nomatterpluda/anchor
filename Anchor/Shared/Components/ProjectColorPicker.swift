/*
 * ProjectColorPicker.swift
 * 
 * REUSABLE PROJECT COLOR PICKER COMPONENT
 * - Horizontal scrollable row of iOS 26 system colors
 * - 15px spacing between colors as per design
 * - Uses centralized ProjectColors data source
 * - Border selection style (no scaling)
 * - Reusable across AddProjectSheet, EditProjectSheet, etc.
 */

import SwiftUI

struct ProjectColorPicker: View {
    @Binding var selectedColor: String
    let onSelection: (() -> Void)?
    
    // MARK: - Initializers
    
    /// Standard color picker
    init(selectedColor: Binding<String>, onSelection: (() -> Void)? = nil) {
        self._selectedColor = selectedColor
        self.onSelection = onSelection
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) { // 15px spacing as requested
                ForEach(ProjectColors.allColorIDs, id: \.self) { colorID in
                    ColorDot(
                        color: colorID,
                        isSelected: selectedColor == colorID
                    ) {
                        Haptic.shared.lightImpact()
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedColor = colorID
                        }
                        onSelection?()
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
}

// MARK: - Convenience Extensions
extension ProjectColorPicker {
    /// Create color picker with custom selection handler
    static func withSelectionHandler(
        selectedColor: Binding<String>,
        onSelection: @escaping (String) -> Void
    ) -> some View {
        ProjectColorPicker(selectedColor: selectedColor) {
            onSelection(selectedColor.wrappedValue)
        }
    }
}

#Preview {
    @Previewable @State var selectedColor = ProjectColors.defaultColorID
    
    VStack(spacing: 20) {
        Text("Selected: \(selectedColor)")
            .font(.headline)
        
        ProjectColorPicker(selectedColor: $selectedColor)
    }
    .padding()
    .background(.black)
}