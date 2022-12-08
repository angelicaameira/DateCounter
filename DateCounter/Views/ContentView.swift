//
//  ContentView.swift
//  DateCounter
//
//  Created by Antonio Germano on 04/10/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDelete = false
    @State private var selectedEvent: Event?
    @FetchRequest<Event>(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)])
    private var eventsFetchedResults: FetchedResults<Event>
    private var sectionKeys: [Period] = [
        .past, .month, .semester, .year, .decade
    ]
    private var eventsDictionary: [Period: [Event]] {
        Dictionary(grouping: eventsFetchedResults) { event in
            guard let date = event.date else { return .past }
            
            if date.compare(Date.now) == .orderedAscending {
                return Period.past
            }
            if date.compare(monthForFuture(period: .month)) == .orderedAscending {
                return Period.month
            }
            if date.compare(monthForFuture(period: .semester)) == .orderedAscending {
                return Period.semester
            }
            if date.compare(monthForFuture(period: .year)) == .orderedAscending {
                return Period.year
            }
            return Period.decade
        }
    }
    @State private var showManageEventView = false
    @State private var showOnboarding = false
    @State private var showError = false
    @State private var errorMessage = "No error"
    @State private var count = 0
    
    // MARK: - Views
    var body: some View {
        NavigationView {
            sidebarView
                .navigationTitle("Events")
#if !os(watchOS)
                .listStyle(.sidebar)
#endif
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
                    ToolbarItem(placement: .primaryAction, content: {
                        Button(action: {
                            showManageEventView.toggle()
                        }, label: {
                            Label("Add Event", systemImage: "plus")
                        })
                    })
                }
            DefaultDetailView(showError: $showError, errorMessage: $errorMessage)
        }
        .environment(\.eventListCount, eventsFetchedResults.count)
        
        .sheet(isPresented: $showManageEventView) {
            ManageEventView()
        }
        
        .sheet(isPresented: $showOnboarding) {
            Onboarding()
        }
        
        .alert("An error occurred when deleting an event", isPresented: $showError, actions: {
            Text("Ok")
        }, message: {
            Text(errorMessage)
        })
    }
    
    var sidebarContent: some View {
        ForEach(sectionKeys, id: \.self) { section in
            if let events = eventsDictionary[section] {
                Section {
                    ForEach(events, id: \.self) { event in
                        EventListRow(event: event)
                    }
                    .onDelete { indexSet in
                        deleteEvents(section: section, offsets: indexSet)
                    }
                } header: {
                    Text(section.stringValue)
                }
			}
		}
	}
   
    @ViewBuilder
    var sharedSidebar: some View {
#if os(OSX)
        List(selection: $selectedEvent) {
            sidebarContent
        }
#else
        List {
            sidebarContent
        }
#endif
    }
     
    @ViewBuilder
    var sidebarView: some View {
        sharedSidebar
#if os(OSX)
        .alert("Delete event", isPresented: $showDelete, actions: {
            Button("Delete", action: {
                guard
                    let selectedEvent = selectedEvent,
                    selectedEvent.managedObjectContext != nil
                else { return }
                viewContext.delete(selectedEvent)
                do {
                    try viewContext.save()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            })
            Button("Cancel", action: {
                showDelete = false
            })
        }, message: {
            Text("\"\(selectedEvent?.title ?? "It")\" will be permanently deleted.\nAre you sure?")
        })
        .onDeleteCommand {
            guard
                let selectedEvent = selectedEvent,
                selectedEvent.managedObjectContext != nil
            else { return }
            showDelete = true
        }
#endif
    }
    
    // MARK: - Functions
    private func deleteEvents(section: Period, offsets: IndexSet) {
        withAnimation {
            guard let events = eventsDictionary[section] else { return }
            
            offsets.map { events[$0] }
                .forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
#if os(OSX)
    func toggleSidebar() {
        NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
    }
#endif
    
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

// MARK: - Previews
#if !TEST
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .previewDisplayName("No events (new user)")
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDisplayName("Some events (existing user)")
    }
}
#endif
