
import SwiftUI
import SwiftData

struct ActiveToDoList: View {
  
    @Query(filter: #Predicate<Todo> {!$0.isCompleted}, sort: [SortDescriptor(\Todo.lastUpdate, order: .forward)], animation: .snappy)
    private var activeList: [Todo]
    
    //View Properties
    @State private var isAddingTask: Bool = false
    @State private var newTaskText: String = ""
    @FocusState private var isTaskFieldFocused: Bool
    let onAddTask: (String) -> Void
    
    
    var body: some View {
        Section {
            ForEach(activeList) { todo in
                ToDoRowView(todo: todo)
                    .listRowSeparator(.hidden)
            }
               // .onDelete(perform: deleteTask)
               // .onMove(perform: { indices, newOffset in
               //  moveTask(indices: indices, newOffset: newOffset)
            //})
            
            // Input section
            HStack (spacing: 16){
                    Button(action: {}, label: {
                        Image(systemName: "plus.circle.fill")
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
                                if !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    onAddTask(newTaskText.trimmingCharacters(in: .whitespacesAndNewlines))
                                    newTaskText = ""
                                }
                                isTaskFieldFocused = false
                            }
                }
               
            
            
            
            
  
        }
    }
    
    // List header
    var activeSectionTitle: String {
        let count = activeList.count
        return count == 0 ? "Tasks" : "Tasks (\(count))"
    }
    
    // delete Task
    func deleteTask(at offsets: IndexSet) {
        // Note: You'll need to implement this with your actual data source
        // activeList.remove(atOffsets: offsets) // This won't work with @Query
    }
    
    // move task
    func moveTask(indices: IndexSet, newOffset: Int) {
        // Note: You'll need to implement this with your actual data source
        // activeList.move(fromOffsets: indices, toOffset: newOffset) // This won't work with @Query
    }
}

#Preview {
    ActiveToDoList { taskText in
        print("Adding task: \(taskText)")
    }
}
