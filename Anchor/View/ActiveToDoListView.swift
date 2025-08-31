
import SwiftUI
import SwiftData

struct ActiveToDoListView: View {
  
    @Query(filter: #Predicate<Todo> {!$0.isCompleted}, sort: [SortDescriptor(\Todo.lastUpdate, order: .forward)], animation: .snappy)
    private var activeList: [Todo]
    
    //View Properties
    @EnvironmentObject var activeToDoListViewModel: ActiveToDoListViewModel
    @Environment(\.modelContext) private var context
    @FocusState private var isTaskFieldFocused: Bool
    
    
    var body: some View {
        Section {
            ForEach(activeList) { todo in
                ToDoRowView(todo: todo)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    activeToDoListViewModel.deleteTask(todo: activeList[index])
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

