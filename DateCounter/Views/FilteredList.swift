//
//  FilteredList.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 11/10/22.
//

import SwiftUI
import CoreData

struct FilteredList<T: NSManagedObject, Content: View>: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest var fetchRequest: FetchedResults<T>
    var content: (T) -> Content
    let header: String
    
    var body: some View {
        if (!fetchRequest.isEmpty) {
            Section {
                ForEach(fetchRequest, id: \.self) { item in
                    self.content(item)
                }
                .onDelete(perform: deleteEvents(offsets:))
            } header: {
                Text(header)
            }
        }
    }
    
    init(predicates: [NSPredicate]?, ordering: [NSSortDescriptor],
         header: String,
         @ViewBuilder content: @escaping (T) -> Content) {
        _fetchRequest = FetchRequest<T>(
            sortDescriptors: ordering,
            predicate: predicates != nil && !predicates!.isEmpty ? NSCompoundPredicate(andPredicateWithSubpredicates: predicates!) : nil
        )
        self.content = content
        self.header = header
    }
    
    private func deleteEvents(offsets: IndexSet) {
        withAnimation {
            offsets.map { fetchRequest[$0] }
                .forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
            }
        }
    }
}
