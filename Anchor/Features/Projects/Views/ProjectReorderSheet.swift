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
    @ObservedObject var managementViewModel: ProjectManagementViewModel
    
    var body: some View {
        DynamicSheet(animation: .snappy(duration: 0.3)) {
            ProjectReorderSheetContent(managementViewModel: managementViewModel)
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Project Reorder Sheet Content

struct ProjectReorderSheetContent: View {
    @ObservedObject var managementViewModel: ProjectManagementViewModel
    @Query(sort: [SortDescriptor(\ProjectModel.orderIndex)]) private var projects: [ProjectModel]
    
    // Local state for reordering (changes only applied on Save)
    @State private var reorderedProjects: [ProjectModel] = []
    
    // Dynamic height calculations
    private var listHeight: CGFloat {
        CGFloat(reorderedProjects.count + 1) * 70 // +1 for Add Project row
    }
    
    private var maxListHeight: CGFloat {
        // Calculate max height: screen height minus header, buttons, padding, and safe area
        let screenHeight = UIScreen.main.bounds.height
        let reservedSpace: CGFloat = 300 // Header + buttons + padding + safe area
        return screenHeight - reservedSpace
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Reorder Projects")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            
            List {
                ForEach(Array(reorderedProjects.enumerated()), id: \.element.projectID) { index, project in
                    ProjectReorderRow(project: project)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.visible)
                }
                .onMove(perform: moveProjects)
                
                // Add Project row
                AddProjectRow {
                    handleAddProject()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .scrollDisabled(listHeight <= maxListHeight) // Disable scrolling only when content fits
            .frame(height: min(listHeight, maxListHeight)) // Cap at maximum height
            
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
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .background(.clear)
        .padding(20)
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
        managementViewModel.showReorderSheet = false
    }
    
    private func handleSave() {
        Haptic.shared.mediumImpact()
        
        // Update order indexes based on new positions
        for (index, project) in reorderedProjects.enumerated() {
            project.orderIndex = index
        }
        
        managementViewModel.saveReorderChanges()
    }
    
    private func handleAddProject() {
        Haptic.shared.lightImpact()
        managementViewModel.showReorderSheet = false
        
        // Open add project sheet after a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            managementViewModel.showNewProjectSheet = true
        }
    }
}

// MARK: - Project Reorder Row

struct ProjectReorderRow: View {
    let project: ProjectModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Project icon
            StaticProjectIcon(project: project, isThresholdReached: false, isMenuPresented: false, dragProgress: 0)
            
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
            
            // Move/drag handle icon
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
        }
    }
}

// MARK: - Add Project Row

struct AddProjectRow: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Plus icon (same size as StaticProjectIcon)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                    .frame(width: 34, height: 34) // Match StaticProjectIcon 34x34 frame
                
                // Add Project text
                Text("Add Project")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @Previewable @State var managementViewModel = ProjectManagementViewModel()
    
    let container = try! ModelContainer(for: ProjectModel.self, Todo.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Create dummy projects with varying counts to test dynamic height
    let dummyProjects = [
        ProjectModel(name: "Work", icon: "briefcase.fill", color: "blue", orderIndex: 0),
        ProjectModel(name: "Personal", icon: "person.fill", color: "green", orderIndex: 1),
        ProjectModel(name: "Learning", icon: "book.fill", color: "orange", orderIndex: 2),
        ProjectModel(name: "Health & Fitness", icon: "heart.fill", color: "red", orderIndex: 3),
        ProjectModel(name: "Travel Plans", icon: "airplane", color: "purple", orderIndex: 4),
        ProjectModel(name: "Side Projects", icon: "hammer.fill", color: "cyan", orderIndex: 5),
        ProjectModel(name: "Reading", icon: "books.vertical.fill", color: "mint", orderIndex: 6)
    ]
    
    // Insert dummy projects into container
    for project in dummyProjects {
        container.mainContext.insert(project)
    }
    
    return ProjectReorderSheet(managementViewModel: managementViewModel)
        .modelContainer(container)
        .background(Color.black)
}
