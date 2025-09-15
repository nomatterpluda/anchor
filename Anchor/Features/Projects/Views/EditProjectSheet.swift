/*
 * EditProjectSheet.swift
 * 
 * EDIT PROJECT SHEET VIEW
 * - Modal sheet for editing existing projects with full customization
 * - Pre-populated with existing project details
 * - StaticProjectIcon + TextField for project name input
 * - Horizontal scrollable color picker with 35x35 dots
 * - Grid-based icon picker with SF Symbols (6 per row)
 * - Glass-style Cancel/Save buttons at bottom
 * - Real-time preview updates as user selects options
 */

import SwiftUI

struct EditProjectSheet: View {
    @ObservedObject var managementViewModel: ProjectManagementViewModel
    @ObservedObject var selectionViewModel: ProjectSelectionViewModel
    let project: ProjectModel
    
    // Form state - initialized with project details
    @State private var projectName: String
    @State private var selectedColor: String
    @State private var selectedIcon: String
    @FocusState private var isNameFieldFocused: Bool
    
    // MARK: - Initializer
    
    init(managementViewModel: ProjectManagementViewModel, selectionViewModel: ProjectSelectionViewModel, project: ProjectModel) {
        self.managementViewModel = managementViewModel
        self.selectionViewModel = selectionViewModel
        self.project = project
        self._projectName = State(initialValue: project.projectName)
        self._selectedColor = State(initialValue: project.projectColor)
        self._selectedIcon = State(initialValue: project.projectIcon)
    }
    
    private var mockProject: ProjectModel {
        let project = ProjectModel(name: projectName.isEmpty ? "Project" : projectName, 
                                  icon: selectedIcon, 
                                  color: selectedColor)
        return project
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with icon and text field
                headerSection
                
                // Color picker
                colorPickerSection
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                
                // Icon grid
                iconGridSection
                
                // Bottom buttons
                bottomButtonsSection
                    .padding(.top, 20)
            }
        }
        .background(.clear)
        .padding(30)
        .presentationDetents([.height(500), .large])
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            StaticProjectIcon(project: mockProject, isThresholdReached: false, isMenuPresented: false, dragProgress: 0)
            
            TextField("Project Name", text: $projectName)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .focused($isNameFieldFocused)
        }
    }
    
    // MARK: - Color Picker Section
    private var colorPickerSection: some View {
        ProjectColorPicker(selectedColor: $selectedColor)
    }
    
    // MARK: - Icon Grid Section
    private var iconGridSection: some View {
        ProjectIconGrid(selectedIcon: $selectedIcon)
            .padding(.horizontal, 4)
    }
    
    // MARK: - Bottom Buttons Section
    private var bottomButtonsSection: some View {
        HStack(spacing: 15) {
            Button {
                Haptic.shared.lightImpact()
                managementViewModel.showEditProjectSheet = false
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
            
            Button {
                handleSaveProject()
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
            .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
        }
    }
    
    // MARK: - Actions
    private func handleSaveProject() {
        let trimmedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Haptic.shared.mediumImpact()
        updateProject(name: trimmedName, icon: selectedIcon, color: selectedColor)
        managementViewModel.showEditProjectSheet = false
    }
    
    private func updateProject(name: String, icon: String, color: String) {
        project.projectName = name
        project.projectIcon = icon
        project.projectColor = color
        // SwiftData will automatically save the changes since project is a managed object
    }
}

#Preview {
    let sampleProject = ProjectModel(name: "Sample Project", icon: "folder.fill", color: "blue")
    EditProjectSheet(
        managementViewModel: ProjectManagementViewModel(),
        selectionViewModel: ProjectSelectionViewModel(),
        project: sampleProject
    )
}