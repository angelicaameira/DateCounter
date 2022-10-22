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
    @State private var showingEditAlert = false
    @State private var eventDescription = ""
    @State private var eventDate = ""
    
    var body: some View {
        List {
#if os(iOS)
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
#endif
            
#if os(OSX)
            Section {
                TextField("Description", text: $eventDescription)
            } header: {
                Text("Description")
            }
            .onAppear {
                eventDescription = event.eventDescription ?? "Unknown description"
            }
            Section {
                TextField("Date", text: $eventDate)
            } header: {
                Text("Date")
            }
            .onAppear {
                eventDate = event.date?.formatted() ?? "Unknown date"
            }
#endif
        }
        .navigationTitle(event.title ?? "Unknown title")
        
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
        
        .toolbar {
            Button {
                showingDeleteAlert = true
            } label: {
                Label("Delete this event", systemImage: "trash")
            }
#if os(OSX)
            Button {
                editEventMac()
            } label: {
                Label("Edit this event", systemImage: "pencil")
            }
#endif
        }
    }
    
    func editEventMac() {
//        do {
//            try viewContext.save()
//        } catch {
//            errorMessage = error.localizedDescription
//            showError = true
//        }
    }
    
    func deleteEvent() {
        viewContext.delete(event)
        do {
            try? viewContext.save()
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
        let event = Event(context: PersistenceController.preview.container.viewContext)
        event.title = "My awesome event"
        event.eventDescription = "Event description, which might be big so we have a somewhat lenghty description here"
        event.date = Date()
        
        return NavigationView {
            DetailView(event: event)
        }
    }
}
