//
//  ContentView.swift
//  DateCounter
//
//  Created by Antonio Germano on 04/10/22.
//

import SwiftUI
import CoreData

#if !os(OSX)
extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredDisplayMode = .oneBesideSecondary
        self.preferredSplitBehavior = .displace
    }
}
#endif

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showManageEventView = false
    @State private var showError = false
    @State private var errorMessage = "No error"
    
    var body: some View {
        NavigationView {
            sidebarView
                .navigationTitle("Events")
                .listStyle(.sidebar)
#if os(OSX)
                .frame(minWidth: 220)
#endif
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
#endif
#if os(OSX)
                    ToolbarItem(placement: .navigation) {
                        Button {
                            toggleSidebar()
                        } label: {
                            Image(systemName: "sidebar.left")
                        }
                    }
#endif
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showManageEventView.toggle()
                        } label: {
                            Label("Add Event", systemImage: "plus")
                        }
                    }
                }
            defaultDetailView
        }
        
        .sheet(isPresented: $showManageEventView) {
            ManageEventView()
        }
        
        .alert("An error occurred when deleting event", isPresented: $showError, actions: {
            Text("Ok")
        }, message: {
            Text(errorMessage)
        })
    }
    
    var sidebarView: some View {
        List {
            FilteredList(
                predicates: [
                    NSPredicate(format: "%K < %@", "date", Date.now as CVarArg),
                ],
                ordering: [
                    NSSortDescriptor(key: "date", ascending: true)
                ],
                header: "Past"
            ){ (event: Event) in
                
                EventListRow(event: event)
                
            }
            
            FilteredList(
                predicates: [
                    NSPredicate(format: "%K > %@", "date", Date.now as CVarArg),
                    NSPredicate(format: "%K < %@", "date", monthForFuture(period: .month) as CVarArg)
                ],
                ordering: [
                    NSSortDescriptor(key: "date", ascending: true)
                ],
                header: Period.month.stringValue
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
                ], header: Period.semester.stringValue
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
                ],
                header: Period.year.stringValue
            ){ (event: Event) in
                EventListRow(event: event)
            }
            FilteredList(
                predicates: [
                    NSPredicate(format: "%K > %@", "date", monthForFuture(period: .year) as CVarArg)
                ],
                ordering: [
                    NSSortDescriptor(key: "date", ascending: true)
                ],
                header: Period.decade.stringValue
            ){ (event: Event) in
                EventListRow(event: event)
            }
        }
    }
    
    func toggleSidebar() {
#if os(OSX)
        NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
#else
        
#endif
    }
    
    func createEvents() {
        let event1 = Event(context: viewContext)
        event1.eventDescription = "Next Moon eclipse"
        event1.title = "Next Moon eclipse"
        event1.date = Date()
        
        let event2 = Event(context: viewContext)
        event2.eventDescription = "Next snow era"
        event2.title = "Next snow era"
        event2.date = Date()
        
        let event3 = Event(context: viewContext)
        event3.eventDescription = "Half level of Sun"
        event3.title = "Half level of Sun"
        event3.date = Date()
        
        try? viewContext.save()
    }
    
    var eventCount: Int {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        do {
            return try viewContext.count(for: fetchRequest)
        } catch {
#if DEBUG
            print(error)
#endif
            return 0
        }
    }
    
    private var defaultDetailView: some View {
        VStack {
            Text("Welcome!")
                .font(.largeTitle)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            if eventCount == 0 {
                completeMessageView
            }
            if eventCount > 0 {
                simpleMessageView
            }
        }
        .padding()
    }
    
    var completeMessageView: some View {
        HStack {
            Text("Start by")
            Button {
                showManageEventView = true
            } label: {
                Text("creating a new event")
            }
            Text("or")
            Button {
                showManageEventView = false
                createEvents()
            } label: {
                Text("adding some sample events for me")
            }
        }
    }
    
    var simpleMessageView: some View {
        VStack {
            HStack {
                Text("Tap an event to see details")
                    .padding(.bottom)
            }
        }
    }
    
    func monthForFuture(period: Period) -> Date {
        var components: DateComponents
        switch period {
        case .month:
            components = DateComponents(month: 1)
        case .semester:
            components = DateComponents(month: 6)
        case .year:
            components = DateComponents(year: 1)
        case .decade:
            components = DateComponents(year: 10)
        case .past:
            components = DateComponents(nanosecond: 1) //FIXME: that's not supposed to happen
        }
        return Calendar.current.date(byAdding: components, to: Date.now) ?? Date.now
    }
}

enum Period: String, CaseIterable, Codable {
    case past = "Past"
    case month = "Month"
    case semester = "Semester"
    case year = "Year"
    case decade = "Decade"
    
    var stringValue: String { rawValue }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
