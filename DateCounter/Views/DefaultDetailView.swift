//
//  Default.swift
//  TheDateCounter
//
//  Created by Angélica Andrade de Meira on 27/11/22.
//

import Foundation
import SwiftUI
import CoreData

struct DefaultDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var showManageEventView: Bool = false
    @Binding var showError: Bool
    @Binding var errorMessage: String
    @State private var updateMessage = false
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
    
    var body: some View {
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
        
        .sheet(isPresented: $showManageEventView) {
            ManageEventView()
        }
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
}
