//
//  DetailView.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 06/10/22.
//

import SwiftUI
import CoreData

struct DetailView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    var event: Event
    @State private var showDeleteAlert = false
    @State private var showError = false
    @State private var errorMessage = "No error"
    @State private var errorTitle = "No action"
    @State var isEditing = false
    @State private var updateScreen = false
    
    var isValidEvent: Bool {
        return !(event.isDeleted || event.title == nil)
    }
    
    var body: some View {
        if !isValidEvent {
            DefaultDetailView(showError: $showError, errorMessage: $errorMessage)
                .navigationTitle("")
        } else {
            Group {
                displayingView
            }
            .navigationTitle(event.title ?? "Unknown title")
            .toolbar {
                editToolbarItem
                deleteToolbarItem
            }
#if os(OSX)
            .onDeleteCommand {
                showDeleteAlert = true
            }
#endif
            .alert("Delete event", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive, action: deleteEvent)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure?")
            }
            
            .alert(errorTitle, isPresented: $showError, actions: {
                Text("Ok")
            }, message: {
                Text(errorMessage)
            })
            
            .sheet(isPresented: $isEditing) {
                ManageEventView(event: event)
            }
        }
    }
    
    private let components: [Calendar.Component] = [.era, .year, .month, .weekOfMonth, .day, .hour, .minute, .second]
    private var displayingView: some View {
        List {
            if let description = event.eventDescription {
                Section {
                    Text(description)
                } header: {
                    Text("Details")
                }
            }
            if let date = event.date {
                Section {
                    Text("\(date, style: .date), \(date, style: .time)")
                } header: {
                    Text("Date")
                }
            }
            
            Section {
                ForEach(components, id: \.self) { component in
                    if let time = remainingTime(forComponent: component), time != 0 {
                        Text("\(time) \(stringForComponent(component))\(time > 1 || time < 1 ? "s" : "")")
                    }
                }
            } header: {
                if (updateScreen || true) {
                    Text("Remaining time on different units")
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .default).autoconnect()) { timerOutput in
                self.updateScreen.toggle()
            }
        }
    }
    
    func stringForComponent(_ component: Calendar.Component) -> String {
        switch component {
        case .era: return "era"
        case .year: return "year"
        case .month: return "month"
        case .day: return "day"
        case .hour: return "hour"
        case .minute: return "minute"
        case .second: return "second"
        case .weekday: return "week day"
        case .weekdayOrdinal: return "weekday ordinal"
        case .quarter: return "quarter"
        case .weekOfMonth: return "week"
        case .weekOfYear: return "week of year"
        case .yearForWeekOfYear: return "year for week of year"
        case .nanosecond: return "nanosecond"
        case .calendar: return "calendar"
        case .timeZone: return "timezone"
        @unknown default: return "unknown"
        }
    }
    
    func remainingTime(forComponent component: Calendar.Component) -> Int? {
        guard let dataOfEvent = event.date else { return 0 }
        let dateComponents = Calendar.current.dateComponents([component], from: Date.now, to: dataOfEvent)
        
        return dateComponents.value(for: component)
    }
    
    private var editToolbarItem: ToolbarItem<(), Button<Label<Text, Image>>> {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isEditing = true
            } label: {
                Label("Edit this event", systemImage: "pencil")
            }
        }
    }
    
    private var deleteToolbarItem: ToolbarItem<(), Button<Label<Text, Image>>> {
        ToolbarItem(placement: .destructiveAction) {
            Button {
                showDeleteAlert = true
            } label: {
                Label("Delete this event", systemImage: "trash")
            }
        }
    }
    
    func deleteEvent() {
        viewContext.delete(event)
        do {
            try viewContext.save()
#if !os(OSX)
            dismiss()
#endif
        } catch {
            viewContext.undo()
            errorMessage = error.localizedDescription
            errorTitle = "Error when deleting event"
            showError = true
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
#if !os(OSX)
        NavigationView {
            DetailView(event: DateCounterApp_Previews.event(period: .semester))
        }
        .previewDisplayName("Detail")
        NavigationView {
            DetailView(event: DateCounterApp_Previews.event(period: .semester), isEditing: true)
        }
        .previewDisplayName("Edit")
#endif
#if os(OSX)
        DetailView(event: DateCounterApp_Previews.event(period: .past))
            .previewDisplayName("Detail")
        DetailView(event: DateCounterApp_Previews.event(period: .past), isEditing: true)
            .previewDisplayName("Edit")
#endif
    }
}
