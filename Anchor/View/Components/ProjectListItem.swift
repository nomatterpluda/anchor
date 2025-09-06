/*
 * ProjectListItem.swift
 * 
 * PROJECT LIST ITEM COMPONENT
 * - Displays project name and active task count
 * - No icon (handled by static icon)
 * - Text styling: 34px bold name, 20px medium count
 * - Dynamic opacity based on selection state
 * - Used within the scrollable project list
 */

import SwiftUI

struct ProjectListItem: View {
    let name: String
    let activeTaskCount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .bottom, spacing: 5) {
                Text(name)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.2))
                
                Text("\(activeTaskCount)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? .white.opacity(0.4) : .white.opacity(0.2))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 20) {
        ProjectListItem(name: "Work", activeTaskCount: 5, isSelected: true, action: {})
        ProjectListItem(name: "Personal", activeTaskCount: 3, isSelected: false, action: {})
    }
    .padding()
    .background(.black)
}