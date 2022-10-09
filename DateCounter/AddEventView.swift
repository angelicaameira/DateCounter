//
//  AddEventView.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 06/10/22.
//

import SwiftUI
import CoreData

struct AddEventView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var eventDescription = ""
    @State private var date = ""
    @State private var showError = false
    @State private var errorMessage = "No error"
    @State var event: Event
    
    var body: some View {
        VStack {
            Text("Add event")
                .font(.headline)
            Form {
                Section {
                    TextField("Event name", text: $title)
                }
                
                Section {
                    TextField("Description", text: $eventDescription)
                }
                
                Section {
                    TextField("Date", text: $date)
                }
                
                Section {
                    Button("save", action: addItem)
                }
            }
#if os(OSX)
            .padding()
            
#endif
            .alert("An error occurred when adding event", isPresented: $showError, actions: {
                Text("Ok")
            }, message: {
                Text(errorMessage)
            })
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private func addItem() {
        withAnimation {
            let newItem = Event(context: viewContext)
            newItem.id = UUID()
            newItem.title = title.isEmpty ? nil : title
            newItem.eventDescription = eventDescription.isEmpty ? nil : eventDescription
            newItem.date = Date()
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(context: PersistenceController.preview.container.viewContext)
        event.title = "My awesome event"
        event.eventDescription = "Event description, which might be big so we have a somewhat lenghty description here"
        event.date = Date()

        return NavigationView {
            AddEventView(event: event)
        }
    }
}
