/*
 * ProjectReorderSheet.swift
 * 
 * PROJECT REORDER SHEET VIEW
 * - Modal sheet for reordering projects with native List drag-and-drop
 * - Uses .insetGroupedListStyle() for native iOS appearance
 * - Shows project icons, names, and drag handles on the right
 * - Glass-style Cancel/Save buttons at bottom matching existing sheets
 * - Integrates with ProjectSelectionViewModel for MVVM compliance
 */

import SwiftUI
import SwiftData

struct ProjectReorderSheet: View {
    @ObservedObject var viewModel: ProjectSelectionViewModel
    @Query(sort: [SortDescriptor(\ProjectModel.orderIndex)]) private var projects: [ProjectModel]
    
    // Local state for reordering (changes only applied on Save)
    @State private var reorderedProjects: [ProjectModel] = []
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Reorder Projects")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            List {
                ForEach(reorderedProjects, id: \.projectID) { project in
                    ProjectReorderRow(project: project)
                }
                .onMove(perform: moveProjects)
            }
            .listStyle(.insetGrouped)
            .background(.clear)
            
            // Bottom buttons
            HStack(spacing: 15) {
                Button {
                    Haptic.shared.lightImpact()
                    handleCancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                
                Button {
                    handleSave()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 30)
        }
        .background(.clear)
        .presentationDetents([.medium, .large])
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
        .onAppear {
            // Initialize local state with current projects
            reorderedProjects = projects
        }
    }
    
    
    // MARK: - Actions
    
    private func moveProjects(from source: IndexSet, to destination: Int) {
        withAnimation {
            reorderedProjects.move(fromOffsets: source, toOffset: destination)
        }
        Haptic.shared.lightImpact()
    }
    
    private func handleCancel() {
        Haptic.shared.lightImpact()
        viewModel.showReorderSheet = false
    }
    
    private func handleSave() {
        Haptic.shared.mediumImpact()
        
        // Update order indexes based on new positions
        for (index, project) in reorderedProjects.enumerated() {
            project.orderIndex = index
        }
        
        viewModel.saveReorderChanges()
    }
}

// MARK: - Project Reorder Row

struct ProjectReorderRow: View {
    let project: ProjectModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Project icon
            StaticProjectIcon(project: project, isThresholdReached: false)
                .scaleEffect(0.8)
            
            // Project name
            Text(project.projectName)
                .font(.body)
            
            Spacer()
            
            // Move/drag handle icon
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
        }
    }
}

#Preview {
    @Previewable @State var viewModel = ProjectSelectionViewModel()
    
    let container = try! ModelContainer(for: ProjectModel.self, Todo.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Create dummy projects
    let dummyProjects = [
        ProjectModel(name: "Work", icon: "briefcase.fill", color: "blue", orderIndex: 0),
        ProjectModel(name: "Personal", icon: "person.fill", color: "green", orderIndex: 1),
        ProjectModel(name: "Learning", icon: "book.fill", color: "orange", orderIndex: 2),
        ProjectModel(name: "Health & Fitness", icon: "heart.fill", color: "red", orderIndex: 3),
        ProjectModel(name: "Travel Plans", icon: "airplane", color: "purple", orderIndex: 4)
    ]
    
    // Insert dummy projects into container
    for project in dummyProjects {
        container.mainContext.insert(project)
    }
    
    return ProjectReorderSheet(viewModel: viewModel)
        .modelContainer(container)
        .background(Color.black)
}
