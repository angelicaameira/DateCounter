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
    @State var event: Event
    @State private var showingDeleteAlert = false
    @State private var showError = false
    @State private var errorMessage = "No error"
    @State private var errorTitle = "No action"
    @State private var eventTitle = ""
    @State private var eventDescription = ""
    @State private var eventDate = Date.now
    @State private var isEditing = false
    
    var body: some View {
        List {
            if isEditing {
                editingView()
            } else {
                displayingView()
            }
        }
        .navigationTitle(event.title ?? "Unknown title")
        .toolbar {
            toolbarContent()
            
            ToolbarItem(placement: destructiveActionPlacement) {
                Button {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete this event", systemImage: "trash")
                }
            }
        }
        
        .alert("Delete event", isPresented: $showingDeleteAlert) {
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
    }
    
    var destructiveActionPlacement: ToolbarItemPlacement {
#if os(OSX)
        .automatic
#else
        .destructiveAction
#endif
    }
    
    func displayingView() -> some View {
        return Group {
            Section {
                Text(event.eventDescription ?? "Unknown description")
            } header: {
                Text("Details")
            }
            Section {
                Text(event.date?.formatted() ?? "No date")
            } header: {
                Text("Date")
            }
        }
    }
    
    func editingView() -> some View {
        return Group {
            Section {
                TextField("Title", text: $eventTitle)
            } header: {
                Text("Title")
            }
            Section {
                TextField("Description", text: $eventDescription)
            } header: {
                Text("Description")
            }
            Section {
                DatePicker("Date", selection: $eventDate)
#if !os(OSX)
                    .datePickerStyle(.graphical)
#endif
            } header: {
                Text("Date")
            }
            .onAppear {
                eventTitle = event.title ?? ""
                eventDescription = event.eventDescription ?? ""
                eventDate = event.date ?? Date.now
            }
//            .onDisappear {
//                viewContext.reset()
//            }
        }
    }
    
    func toolbarContent() -> ToolbarItem<(), Button<Label<Text, Image>>> {
        if !isEditing {
            return ToolbarItem(placement: .primaryAction) {
                Button {
                    isEditing = true
                } label: {
                    Label("Edit this event", systemImage: "pencil")
                }
            }
        }
        return ToolbarItem(placement: .primaryAction) {
            Button {
                saveEvent()
            } label: {
                Label("Save this event", systemImage: "checkmark.circle")
            }
        }
    }
    
    func saveEvent() {
        do {
            event.title = eventTitle.isEmpty ? nil : eventTitle
            event.eventDescription = eventDescription.isEmpty ? nil : eventDescription
            event.date = eventDate
            
            try viewContext.save()
            isEditing = false
        } catch {
            errorMessage = error.localizedDescription
            errorTitle = "Error when editing event"
            showError = true
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
            viewContext.reset()
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
#if !os(OSX)
        NavigationView {
            DetailView(event: DateCounterApp_Previews.event)
        }
#endif
#if os(OSX)
        DetailView(event: DateCounterApp_Previews.event)
#endif
    }
}
