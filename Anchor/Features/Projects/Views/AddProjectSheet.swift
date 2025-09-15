/*
 * AddProjectSheet.swift
 * 
 * ADD PROJECT SHEET VIEW
 * - Modal sheet for creating new projects with full customization
 * - StaticProjectIcon + TextField for project name input
 * - Horizontal scrollable color picker with 35x35 dots
 * - Grid-based icon picker with SF Symbols (6 per row)
 * - Glass-style Cancel/Save buttons at bottom
 * - Real-time preview updates as user selects options
 */

import SwiftUI

struct AddProjectSheet: View {
    @ObservedObject var viewModel: ProjectSelectionViewModel
    
    // Form state
    @State private var projectName: String = ""
    @State private var selectedColor: String = ProjectColors.defaultColorID
    @State private var selectedIcon: String = ProjectIcons.defaultIcon
    @FocusState private var isNameFieldFocused: Bool
    
    
    private var mockProject: ProjectModel {
        let project = ProjectModel(name: projectName.isEmpty ? "New Project" : projectName, 
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
        .onAppear {
            // Autofocus the project name field when sheet appears
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                isNameFieldFocused = true
            }
        }
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
                viewModel.showNewProjectSheet = false
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
        viewModel.createProject(name: trimmedName, icon: selectedIcon, color: selectedColor)
        viewModel.showNewProjectSheet = false
    }
}

#Preview {
    AddProjectSheet(viewModel: ProjectSelectionViewModel())
}
