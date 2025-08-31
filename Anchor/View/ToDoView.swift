//
//  ContentView.swift
//  Anchor
//
//  Created by Alex Pluda on 28/08/25.
//

import SwiftUI
import SwiftData

struct ToDoView: View {
    
    @Query(filter: #Predicate<Todo> {!$0.isCompleted}, sort: [SortDescriptor(\Todo.lastUpdate, order: .forward)], animation: .snappy)
    private var activeList: [Todo]
    let onAddTask: (String) -> Void
    @State private var isAddingTask: Bool = false
    @State private var newTaskText: String = ""
    @FocusState private var isTaskFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            
            VStack {
                List {
                    CompletedToDoListView()
                        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                    
                    Section {
                        ForEach(activeList) { todo in
                            ToDoRowView(todo: todo)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteTask)
                        .onMove(perform: { indices, newOffset in 
                            moveTask(indices: indices, newOffset: newOffset)
                        })
                        
                        // Input section
                        HStack (spacing: 16){
                                Button(action: {}, label: {
                                    Image(systemName: "circle")
                                        .font(.title2)
                                        .foregroundStyle(.gray)
                                        .contentTransition(.symbolEffect(.replace))
                                    
                                })
                                TextField("New To Do", text: $newTaskText)
                                .foregroundStyle(.gray)
                            }
                           
                        
                        
                        
                        
                     /*   if isAddingTask {
                            // Text input field
                            HStack(spacing: 8) {
                                Image(systemName: newTaskText.isEmpty ? "plus.circle.fill" : "circle")
                                    .font(.system(size: 19, weight: .medium, design: .rounded))
                                    .foregroundColor(.accentColor)
                                
                                TextField("Enter task name", text: $newTaskText)
                                    .font(.system(size: 19, weight: .medium, design: .rounded))
                                    .foregroundColor(.accentColor)
                                    .focused($isTaskFieldFocused)
                                    .onSubmit {
                                        if !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            onAddTask(newTaskText.trimmingCharacters(in: .whitespacesAndNewlines))
                                            newTaskText = ""
                                        }
                                        isAddingTask = false
                                        isTaskFieldFocused = false
                                    }
                                    .onAppear {
                                        isTaskFieldFocused = true
                                    }
                                
                                Spacer()
                            }
                        } else {
                            // New task button
                            Button(action: {
                                isAddingTask = true
                                newTaskText = ""
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 19, weight: .medium, design: .rounded))
                                        .foregroundColor(.accentColor)
                                    Text("New task")
                                        .font(.system(size: 19, weight: .medium, design: .rounded))
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                }
                            }
                        } */
                    } header: {
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
                .listStyle(.insetGrouped)
                .environment(\.defaultMinListRowHeight, 0) // reset default row minimum height
            }
        }
        .font(.system(.body, design: .rounded))
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
    ToDoView(onAddTask: { _ in })
}
