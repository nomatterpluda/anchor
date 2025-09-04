
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
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @Environment(\.modelContext) private var context
    @FocusState private var isTaskFieldFocused: Bool
    
    // Remove filteredActiveList since filtering is now handled by Query
    private var filteredActiveList: [Todo] {
        return activeList // Query already handles the filtering
    }

   

    
    var body: some View {
        Section {
            ForEach(filteredActiveList) { todo in
                ToDoRowView(todo: todo)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    activeToDoListViewModel.deleteTask(todo: filteredActiveList[index])
                }
            }
           
            // Input section
            HStack (spacing: 16){
                Button(action: {
                    activeToDoListViewModel.addTask(to: project, dismissFocus: { 
                        isTaskFieldFocused = false 
                    })
                }, label: {
                        Image(systemName: activeToDoListViewModel.iconName(isTaskFieldFocused: isTaskFieldFocused))
                            .font(.system(.headline,design: .rounded, weight: .bold))
                            .foregroundStyle(.blue)
                            .contentTransition(.symbolEffect(.replace))
                        
                    })
                TextField("", text: $activeToDoListViewModel.newTaskText, prompt: Text("New To Do").foregroundColor(.blue))
                            .font(.system(.title2,design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .focused($isTaskFieldFocused)
                            .onSubmit {
                                activeToDoListViewModel.addTask(to: project, dismissFocus: { 
                                    isTaskFieldFocused = false 
                                })
                            }
                }
            
        } header: {
            HStack {
                Image(systemName: "circle.dotted")
                    .font(.system(.title2, design: .rounded).bold())
                Text("\(activeToDoListViewModel.activeSectionTitle(count: activeList.count))")
                    .font(.system(.title, design: .rounded).bold())
                Spacer()
                Button("View all") { }
            }
            .foregroundStyle(.white.opacity(0.25))
        }
        .onAppear {
            activeToDoListViewModel.context = context
        }
    }
}

#Preview {
    ActiveToDoListView()
    }

