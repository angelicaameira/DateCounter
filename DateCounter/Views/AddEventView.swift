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
#if !os(OSX)
        NavigationView {
            content()
        }
#endif
#if os(OSX)
        content()
            .frame(minWidth: 250, maxWidth: 500)
            .padding()
#endif
    }
    
    func content() -> some View {
        return VStack {
#if os(OSX)
            Text(event == nil ? "Add event" : "Edit event")
                .font(.headline)
                .padding(.top)
#endif
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
            }
            .onAppear(perform: {
                guard let event = event else { return }
                title = event.title ?? ""
                eventDescription = event.eventDescription ?? ""
                date = event.date ?? Date()
            })
            .alert("An error occurred when adding event", isPresented: $showError, actions: {
                Text("Ok")
            }, message: {
                Text(errorMessage)
            })
        }
        .navigationTitle(event == nil ? "Add event" : "Edit event")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: addItem)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
#if !os(OSX)
        .navigationViewStyle(.stack)
#endif
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
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
    static var previews: some View {
#if !os(OSX)
        NavigationView {
            AddEventView()
        }
        .previewDisplayName("Add event")
        NavigationView {
            AddEventView(event: DateCounterApp_Previews.event)
        }
        .previewDisplayName("Edit event")
#endif
#if os(OSX)
        AddEventView()
        .previewDisplayName("Add event")
        AddEventView(event: DateCounterApp_Previews.event)
        .previewDisplayName("Edit event")
#endif
    }
}
