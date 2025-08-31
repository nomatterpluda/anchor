
import SwiftUI
import SwiftData

struct ActiveToDoListView: View {
  
    @Query(filter: #Predicate<Todo> {!$0.isCompleted}, sort: [SortDescriptor(\Todo.lastUpdate, order: .forward)], animation: .snappy)
    private var activeList: [Todo]
    
    //View Properties
    @State private var newTaskText: String = ""
    @FocusState private var isTaskFieldFocused: Bool
    @Environment(\.modelContext) private var context
    
    
    var body: some View {
        Section {
            ForEach(activeList) { todo in
                ToDoRowView(todo: todo)
            }
            .onDelete(perform: deleteTask)
           
            // Input section
            HStack (spacing: 16){
                    Button(action: addTask, label: {
                        Image(systemName: iconName)
                            .font(.system(.headline,design: .rounded, weight: .bold))
                            .foregroundStyle(.blue)
                            .contentTransition(.symbolEffect(.replace))
                        
                    })
                    TextField("", text: $newTaskText, prompt: Text("New To Do").foregroundColor(.blue))
                            .font(.system(.title2,design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .focused($isTaskFieldFocused)
                            .onSubmit {
                                addTask()
                            }
                
                }
            
        }
        header: {
            HStack {
                Image(systemName: "circle.dotted")
                    .font(.system(.title2, design: .rounded).bold())
                Text("\(activeSectionTitle)")
                    .font(.system(.title, design: .rounded).bold())
                Spacer()
                Button("View all") { }
            }
            .foregroundStyle(.white.opacity(0.25))
        }
    }
    
    // List header
    var activeSectionTitle: String {
        let count = activeList.count
        return count == 0 ? "Tasks" : "Tasks (\(count))"
    }
    
    // Dynamic icon based on text field state
    var iconName: String {
        if isTaskFieldFocused && !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "checkmark.circle.fill"
        } else {
            return "plus.circle.fill"
        }
    }
    
    // add task
    func addTask() {
        if !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newToDo = Todo(taskName: newTaskText.trimmingCharacters(in: .whitespacesAndNewlines))
            context.insert(newToDo)
            newTaskText = ""
        }
        isTaskFieldFocused = false
    }
    
    // move task
    func moveTask(indices: IndexSet, newOffset: Int) {
        // Note: You'll need to implement this with your actual data source
        // activeList.move(fromOffsets: indices, toOffset: newOffset) // This won't work with @Query
    }
    
    // delete task
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let todoToDelete = activeList[index]
            context.delete(todoToDelete)
        }
    }
}

#Preview {
    ActiveToDoListView()
    }

