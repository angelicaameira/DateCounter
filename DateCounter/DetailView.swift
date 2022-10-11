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
    
    var body: some View {
            List {
                Section {
                    Text(event.title ?? "Unknown title")
                } header: {
                    Text("Title")
                }
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
                Label("Delete this book", systemImage: "trash")
            }
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
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
