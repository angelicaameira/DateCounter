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
    @State private var updateMessage = false
    
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
        
        .alert("An error occurred to add an event", isPresented: $showError, actions: {
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
#endif
    }
    
    private func addSampleEvents() {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        
        updateMessage.toggle()
        
        for lunarEclipseDate in lunarEclipseDates {
            if let date = lunarEclipseDate.date,
               date.compare(Date.now) == .orderedDescending {
                let lunarEclipseEvent = Event(context: viewContext)
                lunarEclipseEvent.title = "\(lunarEclipseDate.type.stringValue) lunar eclipse"
                lunarEclipseEvent.eventDescription = "Will be visible from \(lunarEclipseDate.visibility).\nThe hour corresponds to the Terrestrial Dynamical Time of greatest eclipse"
                lunarEclipseEvent.date = lunarEclipseDate.date
                break
            }
        }
        
        let friendsBirthdayEvent = Event(context: viewContext)
        friendsBirthdayEvent.title = "Close friend's birthday"
        friendsBirthdayEvent.eventDescription = "Edit this event to set the birthday of a person dear to you"
        friendsBirthdayEvent.date = Calendar.current.date(byAdding: DateComponents(month: 2, day: 5), to: Date.now)
        
        let iceAgeEvent = Event(context: viewContext)
        iceAgeEvent.title = "Next ice age"
        iceAgeEvent.eventDescription = "The amount of anthropogenic greenhouse gases emitted into Earth's oceans and atmosphere is predicted to prevent the next glacial period for the next 500,000 years, which otherwise would begin in around 50,000 years, and likely more glacial cycles after."
        iceAgeEvent.date = gregorianCalendar
            .date(from:
                    DateComponents(
                        year: 502_022, month: 1, day: 1,
                        hour: 0, minute: 0
                    )
            )
        
        var date: Date = Date.now,
            intervalToWeekend: TimeInterval = 0
        if gregorianCalendar.nextWeekend(startingAfter: Date.now, start: &date, interval: &intervalToWeekend) {
            let nextWeekendEvent = Event(context: viewContext)
            nextWeekendEvent.title = "Time until next weekend"
            nextWeekendEvent.eventDescription = "Any exciting plans for the weekend? Edit this event and write them down!"
            nextWeekendEvent.date = date
        }
        
        let graduationEvent = Event(context: viewContext)
        graduationEvent.title = "College graduation date"
        graduationEvent.eventDescription = "If you started college today, you would graduate after about 4 years on average"
        graduationEvent.date = gregorianCalendar.date(byAdding: DateComponents(year: 4), to: Date.now)
        
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            errorMessage = error.localizedDescription
            showError = true
        }
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
            if updateMessage || true {
                Text("Welcome!")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            
                if eventCount == 0 {
                    noEventsMessageView
                } else {
                    pickEventMessageView
                }
            }
        }
        .padding()
    }
    
    var pickEventMessageView: some View {
        VStack {
#if os(OSX) || os(tvOS)
            Text("Click an event to see details")
#else
            Text("Tap an event to see details")
#endif
        }
        .padding()
    }
    
    @ViewBuilder
    var noEventsMessageView: some View {
        VStack {
            HStack {
#if os(OSX) || os(tvOS)
                Text("Start by clicking")
#else
                Text("Start by tapping")
#endif
                Button {
                    showManageEventView = true
                } label: {
                    Image(systemName: "plus")
                }
                Text("to create a new event")
            }
            .padding(.bottom)
            VStack {
                Text("Want some ideas?")
                Button {
                    showManageEventView = false
                    addSampleEvents()
                } label: {
                    Text("Add some sample events for me")
                }
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
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .previewDisplayName("No events (new user)")
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDisplayName("Some events (existing user)")
    }
}
