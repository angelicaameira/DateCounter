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
            ToolbarItem {
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
        
        .alert("An error occurred when deleting event", isPresented: $showError, actions: {
            Text("Ok")
        }, message: {
            Text(errorMessage)
        })
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
            .onAppear {
                eventDescription = event.eventDescription ?? "Unknown description"
            }
            Section {
                DatePicker("Date", selection: $eventDate)
            } header: {
                Text("Date")
            }
            .onAppear {
                eventTitle = event.title ?? ""
                eventDescription = event.eventDescription ?? ""
                eventDate = event.date ?? Date.now
            }
        }
    }
    
    func toolbarContent() -> ToolbarItem<(), Button<Label<Text, Image>>> {
        if !isEditing {
            return ToolbarItem(placement: .cancellationAction) {
                Button {
                    isEditing = true
                } label: {
                    Label("Edit this event", systemImage: "pencil")
                }
            }
        }
        return ToolbarItem(placement: .cancellationAction) {
            Button {
                saveEvent()
                isEditing = false
            } label: {
                Label("Save this event", systemImage: "checkmark.circle")
            }
        }
    }
    
    func saveEvent() {
        do {
            event.title = eventTitle
            event.eventDescription = eventDescription
            event.date = eventDate
            try viewContext.save()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func deleteEvent() {
        viewContext.delete(event)
        do {
            try viewContext.save()
#if os(iOS)
            dismiss()
#endif
        } catch {
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
