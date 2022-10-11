//
//  FilteredList.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 11/10/22.
//

import SwiftUI
import CoreData

struct FilteredList<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>
    var content: (T) -> Content
    
    var body: some View {
        ForEach(fetchRequest, id: \.self) { item in
            self.content(item)
        }
//        List(fetchRequest, id: \.self) { item in
//            self.content(item)
//        }
    }
    
    init(predicates: [NSPredicate]?, ordering: [NSSortDescriptor], @ViewBuilder content: @escaping (T) -> Content) {
        _fetchRequest = FetchRequest<T>(
            sortDescriptors: ordering,
            predicate: predicates != nil && !predicates!.isEmpty ? NSCompoundPredicate(andPredicateWithSubpredicates: predicates!) : nil
        )
        self.content = content
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
