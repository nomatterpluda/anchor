/*
 * AddProjectSheet.swift
 * 
 * ADD PROJECT SHEET VIEW
 * - Modal sheet for creating new projects
 * - Clean MVVM implementation with ViewModel delegation
 * - Currently empty placeholder for future form implementation
 * - Triggered by over-scroll gesture in ProjectSelectorBar
 */

import SwiftUI

struct AddProjectSheet: View {
    @ObservedObject var viewModel: ProjectSelectionViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create New Project")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text("This is where the project creation form will go.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showNewProjectSheet = false
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Create project with form data
                        handleSaveProject()
                    }
                    .fontWeight(.semibold)
                    .disabled(true) // Disabled until form is implemented
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSaveProject() {
        // TODO: Implement project creation with form data
        // For now, create a basic project as placeholder
        viewModel.createProject(name: "New Project")
        viewModel.showNewProjectSheet = false
    }
}

#Preview {
    AddProjectSheet(viewModel: ProjectSelectionViewModel())
}