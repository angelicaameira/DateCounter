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
    @State private var date = Date()
    @State private var showError = false
    @State private var errorMessage = "No error"
    @State var event: Event? = nil
    
    var body: some View {
        VStack {
            Text(event == nil ? "Add event" : "Edit event")
                .font(.headline)
                .padding(.top)
            Form {
                Section {
                    TextField("Event name", text: $title)
                }
                Section {
                    TextField("Description", text: $eventDescription)
                }
                
                Section {
                    DatePicker("Date", selection: $date)
                }
                
                Section {
                    Button("Save", action: addItem)
                    Button("Cancel", role: .cancel, action: cancel)
                }
            }
            .onAppear(perform: {
                guard let event = event else { return }
                title = event.title ?? ""
                eventDescription = event.eventDescription ?? ""
                date = event.date ?? Date()
            })
            
            
#if os(OSX)
            .frame(minWidth: 200)
            .frame(maxWidth: 500)
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
    
    
    func cancel() {
        dismiss()
    }
    
    private func addItem() {
        withAnimation {
            let newItem: Event
            if let event = event {
                newItem = event
            } else {
                newItem = Event(context: viewContext)
                newItem.id = UUID()
            }
            newItem.title = title.isEmpty ? nil : title
            newItem.eventDescription = eventDescription.isEmpty ? nil : eventDescription
            newItem.date = date
            
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
    static let event: Event = {
        let event = Event(context: PersistenceController.preview.container.viewContext)
        event.title = "My awesome event"
        event.eventDescription = "Event description, which might be big so we have a somewhat lenghty description here"
        event.date = Date(timeInterval: -82173681, since: Date())
        return event
    }()
    
    static var previews: some View {
        NavigationView {
            AddEventView()
        }
        .previewDisplayName("Add event")
        NavigationView {
            AddEventView(event: AddEventView_Previews.event)
        }
        .previewDisplayName("Edit event")
    }
}
