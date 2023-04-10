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
  @State private var showManageEventView = false
#if APPSTORE_SCREENSHOTS
  @State private var showOnboardingView = true
#else
  @State private var showOnboardingView = !UserDefaults.standard.bool(forKey: "didShowOnboarding")
#endif
  @State private var showError = false
  @State private var error: LocalizedError?
  @State private var errorMessage = "No error"
  @State private var errorTitle = "No action"
  
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
          ToolbarItem(placement: .primaryAction) {
            Button {
              showManageEventView.toggle()
            } label: {
              Label {
                Text("Add Event", comment: "Add a new event at ContentView screen")
              } icon: {
                Image(systemName: "plus")
              }
            }
          }
        }
      DefaultDetailView(showError: $showError, error: $error)
    }
    .environment(\.eventListCount, eventsFetchedResults.count)
    
    .sheet(isPresented: $showManageEventView) {
      ManageEventView()
    }
    
    .sheet(isPresented: $showOnboardingView, onDismiss: {
      UserDefaults.standard.set(true, forKey: "didShowOnboarding")
    }, content: {
      Onboarding()
#if os(OSX)
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 700, minHeight: 370, idealHeight: 400, maxHeight: 600)
#endif
    })
    
    .alert(Text("An error occurred when deleting an event", comment: "alert shows a error to delete some event"), isPresented: $showError) {
      Text("Ok")
    }
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
      .alert(Text("\"\(selectedEvent?.title ?? "It")\" will be permanently deleted.\nAre you sure?", comment: "it shows a message to advise users about consequences to press delete"), isPresented: $showDelete, actions: {
        Button {
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
        } label: {
          Text("Delete", comment: "Button that confirm the event deletion")
        }
        Button {
          showDelete = false
        } label: {
          Text("Cancel", comment: "Button to cancel/prevent event deletion")
        }
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
        self.error = error as? LocalizedError
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
      components = DateComponents(nanosecond: 1) // FIXME: that's not supposed to happen
    }
    return Calendar.current.date(byAdding: components, to: Date.now) ?? Date.now
  }
}

enum Period: LocalizedStringKey, CaseIterable, Codable {
  case past = "Past"
  case month = "Next month"
  case semester = "Next semester"
  case year = "Next year"
  case decade = "Next decade"
  
  var stringValue: LocalizedStringKey { rawValue }
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
