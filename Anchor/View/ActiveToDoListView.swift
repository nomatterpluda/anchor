
import SwiftUI
import SwiftData

struct ActiveToDoListView: View {
  
    @Query private var activeList: [Todo]
    
    init() {
          // We'll need dynamic filtering based on current project
          // For now, we'll fetch all and filter in body
          _activeList = Query(
              filter: #Predicate<Todo> { !$0.isCompleted },
              sort: [SortDescriptor(\Todo.lastUpdate, order: .forward)],
              animation: .snappy
          )
      }
    
    //View Properties
    @EnvironmentObject var activeToDoListViewModel: ActiveToDoListViewModel
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @Environment(\.modelContext) private var context
    @FocusState private var isTaskFieldFocused: Bool
    
    private var filteredActiveList: [Todo] {
          if projectViewModel.isViewingAllProjects {
              return activeList // Show all tasks
          } else {
              return activeList.filter { $0.project?.projectID == projectViewModel.currentProject?.projectID }
          }
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
                    activeToDoListViewModel.addTask(dismissFocus: { 
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
                                activeToDoListViewModel.addTask(dismissFocus: { 
                                    isTaskFieldFocused = false 
                                })
                            }
                }
            
        }
        header: {
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

