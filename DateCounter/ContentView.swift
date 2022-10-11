//
//  ContentView.swift
//  DateCounter
//
//  Created by Antonio Germano on 04/10/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    //    @Environment(\.managedObjectContext) private var viewContext
    //    @FetchRequest(
    //        sortDescriptors: [
    //            NSSortDescriptor(keyPath: \Event.date, ascending: true)
    //        ],
    //        animation: .default
    //    )
    //    private var events: FetchedResults<Event>
    @State private var showingAddAlert = false
    @State private var showingEditSheet = false
    @State private var showError = false
    @State private var errorMessage = "No error"
    
    var body: some View {
        NavigationView {
            List {
                FilteredList(
                    predicates: [
                        NSPredicate(format: "%K > %@", "date", Date.now as CVarArg),
                        NSPredicate(format: "%K < %@", "date", monthForFuture(period: .month) as CVarArg)
                    ],
                    ordering: [
                        NSSortDescriptor(key: "date", ascending: true)
                    ], header: {
                        Text(Period.month.stringValue())
                    }
                ){ (event: Event) in
                    EventListRow(event: event)
                }
                FilteredList(
                    predicates: [
                        NSPredicate(format: "%K > %@", "date", monthForFuture(period: .month) as CVarArg),
                        NSPredicate(format: "%K < %@", "date", monthForFuture(period: .semester) as CVarArg)
                    ],
                    ordering: [
                        NSSortDescriptor(key: "date", ascending: true)
                    ], header: {
                        Text(Period.semester.stringValue())
                    }
                ){ (event: Event) in
                    EventListRow(event: event)
                }
                FilteredList(
                    predicates: [
                        NSPredicate(format: "%K > %@", "date", monthForFuture(period: .semester) as CVarArg),
                        NSPredicate(format: "%K < %@", "date", monthForFuture(period: .year) as CVarArg)
                    ],
                    ordering: [
                        NSSortDescriptor(key: "date", ascending: true)
                    ], header: {
                        Text(Period.year.stringValue())
                    }
                ){ (event: Event) in
                    EventListRow(event: event)
                }
                FilteredList(
                    predicates: [
                        NSPredicate(format: "%K > %@", "date", monthForFuture(period: .year) as CVarArg)
                    ],
                    ordering: [
                        NSSortDescriptor(key: "date", ascending: true)
                    ], header: {
                        Text(Period.decade.stringValue())
                    }
                ){ (event: Event) in
                    EventListRow(event: event)
                }
            }
            .sheet(isPresented: $showingAddAlert) {
                AddEventView()
            }
            .navigationTitle("Events")
#if os(OSX)
            .listStyle(.sidebar)
#endif
#if os(iOS)
            .listStyle(.insetGrouped)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button {
                        showingAddAlert.toggle()
                    } label: {
                        Label("Add Event", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
        
        .alert("An error occurred when deleting event", isPresented: $showError, actions: {
            Text("Ok")
        }, message: {
            Text(errorMessage)
        })
    }
    
    enum Period {
        case month
        case semester
        case year
        case decade
        
        func stringValue() -> String {
            switch self {
            case .month:
                return "Month"
            case .semester:
                return "Semester"
            case .year:
                return "Year"
            case .decade:
                return "Decade"
            }
        }
    }
    
    func monthForFuture(period: Period) -> Date {
        switch period {
        case .month:
            let components = DateComponents(month: 1)
            return Calendar.current.date(byAdding: components, to: Date.now) ?? Date.now
        case .semester:
            let components = DateComponents(month: 6)
            return Calendar.current.date(byAdding: components, to: Date.now) ?? Date.now
        case .year:
            let components = DateComponents(year: 1)
            return Calendar.current.date(byAdding: components, to: Date.now) ?? Date.now
        case .decade:
            let components = DateComponents(year: 10)
            return Calendar.current.date(byAdding: components, to: Date.now) ?? Date.now
        }
    }
}

struct EventListRow: View {
    let event: Event
    
    var body: some View {
        NavigationLink {
            DetailView(event: event)
        } label: {
            HStack {
                Text(event.title ?? "Unnamed event")
                Spacer()
                Text(event.date?.formatted() ?? Date.now.formatted())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
