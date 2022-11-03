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
         header: String, //() -> Content,
//         onDelete: Optional<(IndexSet) -> Void>,
         @ViewBuilder content: @escaping (T) -> Content) {
        _fetchRequest = FetchRequest<T>(
            sortDescriptors: ordering,
            predicate: predicates != nil && !predicates!.isEmpty ? NSCompoundPredicate(andPredicateWithSubpredicates: predicates!) : nil
        )
        self.content = content
        self.header = header
//        self.onDelete = onDelete
    }
    
    private func deleteEvents(offsets: IndexSet) {
        withAnimation {
            offsets.map { fetchRequest[$0] }
                .forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
//                errorMessage = error.localizedDescription
//                showError = true
            }
        }
    }
}

// Usuário comum
//var qualFiltro = "BEGINSWITH"
//var filterKey = "shortName"
//var filterValue = "br"
//
//"%K \(qualFiltro) %@"
//"shortName BEGINSWITH br"



// Usuário malicioso
//var filterValue = "; DELETE * FROM TABLE COUNTRY"
//
//"\(filterKey) \(qualFiltro) \(filterValue)"
//"shortName BEGINSWITH ; DELETE * FROM TABLE COUNTRY"
// resultado: o banco de dados inteiro é apagado pelo usuário

//"%K \(qualFiltro) %@"
//"'shortName' BEGINSWITH '; DELETE * FROM TABLE COUNTRY'"
// resultado: o comando é formatado como uma string simples, e nada de mais acontece, ele procura um país com nome que não existe (o nome é a string simples "; DELETE * FROM TABLE COUNTRY"
