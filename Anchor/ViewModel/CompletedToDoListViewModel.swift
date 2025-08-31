//
//  CompletedToDoListView.swift
//  Anchor
//
//  Created by Alex Pluda on 31/08/25.
//

import Foundation
import SwiftData
internal import Combine

class CompletedToDoListViewModel: ObservableObject {

    // Published Properties
    @Published var showAll: Bool = false

    var context: ModelContext?

    // Computed property for fetch descriptor that updates based on showAll
    var fetchDescriptor: FetchDescriptor<Todo> {
        let predicate = #Predicate<Todo> { $0.isCompleted }
        let sort = [SortDescriptor(\Todo.lastUpdate, order: .forward)]

        var descriptor = FetchDescriptor(predicate: predicate, sortBy: sort)
        if !showAll {
            descriptor.fetchLimit = 5
        }

        return descriptor
    }

    // Toggle show all state
    func toggleShowAll() {
        showAll.toggle()
    }

    // List header - takes count as parameter since actual list is managed by @Query
    func completedSectionTitle(count: Int) -> String {
        return count == 0 ? "Completed" : "Completed (\(count))"
    }

    // Footer logic
    func shouldShowFooter(count: Int) -> Bool {
        return count == 5 && !showAll
    }

    // Delete task
    func deleteTask(todo: Todo) {
        context?.delete(todo)
        Haptic.shared.taskDeleted()
    }
}
