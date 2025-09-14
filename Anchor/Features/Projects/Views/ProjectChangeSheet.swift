/*
 * ProjectChangeSheet.swift
 * 
 * PROJECT CHANGE SHEET VIEW
 * - Modal sheet for changing task's project assignment
 * - Shows list of all projects with checkmark selection
 * - Current project is pre-selected by default
 * - Glass-style Cancel/Confirm buttons at bottom
 * - Follows same UI patterns as ProjectReorderSheet
 */

import SwiftUI
import SwiftData

struct ProjectChangeSheet: View {
    @Query(sort: [SortDescriptor(\ProjectModel.orderIndex)]) private var projects: [ProjectModel]
    
    // Current project (might be nil for "All" view)
    let currentProject: ProjectModel?
    
    // Callback when project is selected
    let onProjectSelected: (ProjectModel?) -> Void
    let onCancel: () -> Void
    
    // Local state for selection
    @State private var selectedProject: ProjectModel?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        DynamicSheet(animation: .snappy(duration: 0.3)) {
            ProjectChangeSheetContent(
                projects: projects,
                currentProject: currentProject,
                selectedProject: $selectedProject,
                onCancel: onCancel,
                onConfirm: {
                    onProjectSelected(selectedProject)
                    dismiss()
                }
            )
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
        .onAppear {
            // Set initial selection to current project
            selectedProject = currentProject
        }
    }
}

// MARK: - Project Change Sheet Content

struct ProjectChangeSheetContent: View {
    let projects: [ProjectModel]
    let currentProject: ProjectModel?
    @Binding var selectedProject: ProjectModel?
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    // Dynamic height calculations (reusing pattern from ProjectReorderSheet)
    private var listHeight: CGFloat {
        CGFloat(projects.count) * 70
    }
    
    private var maxListHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let reservedSpace: CGFloat = 300 // Header + buttons + padding + safe area
        return screenHeight - reservedSpace
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Change Project")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            
            // Project list
            List {
                ForEach(projects) { project in
                    ProjectSelectionRow(
                        project: project,
                        isSelected: selectedProject?.projectID == project.projectID,
                        onTap: {
                            Haptic.shared.lightImpact()
                            selectedProject = project
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.visible)
                }
            }
            .listStyle(.plain)
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .scrollDisabled(listHeight <= maxListHeight)
            .frame(height: min(listHeight, maxListHeight))
            
            // Bottom buttons
            HStack(spacing: 15) {
                Button {
                    Haptic.shared.lightImpact()
                    onCancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                
                Button {
                    Haptic.shared.mediumImpact()
                    onConfirm()
                } label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .background(.clear)
        .padding(20)
    }
}

// MARK: - Project Selection Row

struct ProjectSelectionRow: View {
    let project: ProjectModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Project icon
                StaticProjectIcon(
                    project: project,
                    isThresholdReached: false,
                    isMenuPresented: false
                )
                
                // Project name and task count
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(project.projectName)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text("\(project.activeTodos.count)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                
                Spacer()
                
                // Checkmark for selected project
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(project.swiftUIColor)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}