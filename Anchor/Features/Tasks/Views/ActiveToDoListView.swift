/*
 * ActiveToDoListView.swift
 * 
 * ACTIVE TASKS LIST SECTION
 * - Shows incomplete tasks filtered by selected project
 * - Includes "Add Task" input field with dynamic icon (+ or ✓)
 * - Supports swipe-to-delete functionality
 * - Uses @Query with project-specific filtering for performance
 * - Contains section header with task count and "View all" button
 */

import SwiftUI
import SwiftData

struct ActiveToDoListView: View {
  
    @Query private var activeList: [Todo]
    let project: ProjectModel? // nil means "All" projects
    
    init(project: ProjectModel? = nil) {
        self.project = project
        
        if let project = project {
            // Capture project ID to avoid complex predicate
            let projectID = project.projectID
            _activeList = Query(
                filter: #Predicate<Todo> { todo in
                    !todo.isCompleted && todo.project?.projectID == projectID
                },
                sort: [SortDescriptor(\Todo.lastUpdate, order: .forward)],
                animation: .snappy
            )
        } else {
            // Show all projects
            _activeList = Query(
                filter: #Predicate<Todo> { !$0.isCompleted },
                sort: [SortDescriptor(\Todo.lastUpdate, order: .forward)],
                animation: .snappy
            )
        }
    }
    
    //View Properties
    @EnvironmentObject var activeToDoListViewModel: ActiveToDoListViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.accentColor) private var accentColor
    @FocusState private var isTaskFieldFocused: Bool
    @Namespace private var morphNamespace
    
    // Computed binding for toolbar visibility
    private var toolbarVisible: Binding<Bool> {
        Binding(
            get: { isTaskFieldFocused },
            set: { _ in } // FocusState handles its own setting
        )
    }
    

   

    
    var body: some View {
        ScrollViewSection(
            content: {
                VStack(spacing: 0) {
                    // Tasks content with transition
                    VStack(spacing: 0) {
                        ForEach(activeList) { todo in
                            VStack(spacing: 0) {
                                SwipeableRowView(
                                    content: {
                                        ToDoRowView(todo: todo)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                    },
                                    onDelete: {
                                        activeToDoListViewModel.deleteTask(todo: todo)
                                    }
                                )
                                
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
                    
                    
                    // Input section (no transition - stays stable)
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            Button(action: {
                                Haptic.shared.mediumImpact()
                                
                                if isTaskFieldFocused {
                                    // Keyboard is visible - try to add task
                                    activeToDoListViewModel.addTask(to: project, dismissFocus: {
                                        isTaskFieldFocused = false
                                    })
                                } else {
                                    // Keyboard is not visible - focus text field to bring up keyboard
                                    isTaskFieldFocused = true
                                }
                            }, label: {
                                Image(systemName: activeToDoListViewModel.iconName(isTaskFieldFocused: isTaskFieldFocused))
                                    .font(.system(.headline,design: .rounded, weight: .bold))
                                    .foregroundStyle(accentColor)
                                    .animation(.none, value: accentColor)
                            })
                            
                            TextField("", text: $activeToDoListViewModel.newTaskText, prompt: Text("New To Do").foregroundColor(accentColor))
                                .font(.system(.title2,design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .focused($isTaskFieldFocused)
                                .toolbar {
                                    TaskInputToolbar(
                                        isVisible: toolbarVisible,
                                        morphNamespace: morphNamespace,
                                        task: nil, // No existing task when adding new ones
                                        newTaskFlagged: activeToDoListViewModel.newTaskFlagged,
                                        currentProject: project, // Pass current project for colors
                                        onDueDateSelected: { dueDateOption in
                                            activeToDoListViewModel.handleDueDateSelection(dueDateOption)
                                        },
                                        onCustomDateSelected: { date in
                                            activeToDoListViewModel.setCustomDate(date)
                                        },
                                        onFlagToggled: { isFlagged in
                                            activeToDoListViewModel.newTaskFlagged = isFlagged
                                        },
                                        onProjectChanged: { project in
                                            // TODO: Handle project change
                                            print("Project changed: \(project?.projectName ?? "None")")
                                        }
                                    )
                                }
                                .onChange(of: isTaskFieldFocused) { oldValue, newValue in
                                    if !oldValue && newValue {
                                        // Text field just became focused (keyboard appearing)
                                        Haptic.shared.mediumImpact()
                                    }
                                }
                                .onSubmit {
                                    Haptic.shared.mediumImpact()
                                    activeToDoListViewModel.addTask(to: project, dismissFocus: {
                                        isTaskFieldFocused = false
                                    })
                                }
                            
                            // Date display for new task - shows when set
                            if let dueDate = activeToDoListViewModel.newTaskDueDate {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(dueDate.taskDisplayString)
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    
                                    if let timeString = dueDate.timeString {
                                        Text(timeString)
                                            .font(.system(.caption2, design: .rounded, weight: .regular))
                                            .foregroundStyle(.secondary.opacity(0.8))
                                    }
                                }
                            }
                            
                            // Flag icon for new task - shows when flagged
                            if activeToDoListViewModel.newTaskFlagged {
                                Image(systemName: "flag.fill")
                                    .font(.system(.subheadline, weight: .medium))
                                    .foregroundStyle(project?.swiftUIColor ?? .orange)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                        .background(Color(hex: "1C1C1E"))
                    }
                }
            },
            header: {
                HStack {
                    Image(systemName: "circle.dotted")
                    Text("Tasks")
                    Spacer()
                }
                .padding(.top, 10)
            }
        )
        .onAppear {
            activeToDoListViewModel.context = context
        }
    }
}

#Preview {
    ActiveToDoListView()
        .environmentObject(ActiveToDoListViewModel())
        .environmentObject(CompletedToDoListViewModel())
        .modelContainer(for: [Todo.self, ProjectModel.self])
    }

