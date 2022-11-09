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
    @State private var eventTitle = ""
    @State private var eventDescription = ""
    @State private var eventDate = Date.now
    @State var isEditing = false
    @State private var updateScreen = false
    
    var isValidEvent: Bool {
        return !(event.isDeleted || event.title == nil)
    }
    
    var defaultDetailView: some View {
        Text("Select an event")
    }
    
    var body: some View {
        if !isValidEvent {
            defaultDetailView
        } else {
            Group {
                displayingView
            }
            .navigationTitle(event.title ?? "Unknown title")
            .toolbar {
                toolbarContent
                ToolbarItem(placement: destructiveActionPlacement) {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete this event", systemImage: "trash")
                    }
                }
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
    
    var destructiveActionPlacement: ToolbarItemPlacement {
#if os(OSX)
        .automatic
#else
        .destructiveAction
#endif
    }
    
    private var displayingView: some View {
        List {
            if let description = event.eventDescription {
                Section {
                    Text(description)
                } header: {
                    Text("Details")
                }
            }
            Section {
                Text(event.date?.formatted() ?? "No date")
            } header: {
                Text("Date")
            }
            
            Section {
                if let time = remainingTime(forComponent: .year), time != 0 {
                    Text("\(time) years")
                }
                if let time = remainingTime(forComponent: .month), time != 0 {
                    Text("\(time) months")
                }
                if let time = remainingTime(forComponent: .weekOfYear), time != 0 {
                    Text("\(time) weeks")
                }
                if let time = remainingTime(forComponent: .day), time != 0 {
                    Text("\(time) days")
                }
                if let time = remainingTime(forComponent: .hour), time != 0 {
                    Text("\(time) hours")
                }
                if let time = remainingTime(forComponent: .minute), time != 0 {
                    Text("\(time) minutes")
                }
                if let time = remainingTime(forComponent: .second), time != 0 {
                    Text("\(time) seconds")
                }
            } header: {
                if (updateScreen || true ) {
                    Text("Remaining time on different units")
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .default).autoconnect()) { timerOutput in
                self.updateScreen.toggle()
            }
        }
    }
    
    func remainingTime(forComponent component: Calendar.Component) -> Int? {
        guard let dataOfEvent = event.date else { return 0 }
        let dateComponents = Calendar.current.dateComponents([component], from: Date.now, to: dataOfEvent)
        
        return dateComponents.value(for: component)
    }
    
    private var toolbarContent: ToolbarItem<(), Button<Label<Text, Image>>> {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isEditing = true
            } label: {
                Label("Edit this event", systemImage: "pencil")
            }
        }
    }
    
    func deleteEvent() {
        viewContext.delete(event)
        do {
//            throw NSError(domain: "error", code: 152, userInfo: [NSLocalizedFailureErrorKey: "Could not delete because I didn't want to do it"])
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
