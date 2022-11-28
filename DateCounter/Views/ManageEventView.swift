//
//  ManageEventView.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 06/10/22.
//

import SwiftUI
import CoreData

struct ManageEventView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var eventDescription = ""
    @State private var date = Date()
    @State private var showError = false
    @State private var errorMessage = "No error"
    @State var event: Event? = nil
    private var navigationBarTitle: String {
        event == nil ? "Add event" : "Edit event"
    }
    
    var body: some View {
#if !os(OSX)
        NavigationView {
            content
        }
#endif
#if os(OSX)
        content
            .frame(minWidth: 250, maxWidth: 800)
            .padding()
#endif
    }
    
    //MARK: macOS
#if os(OSX)
    private var formBody: some View {
        Group {
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
    }
#endif
    
    //MARK: iOS
#if os(iOS)
    private var formBody: some View {
        Group {
            Section {
                TextEditor(text: $title)
            } header: {
                Text("Title")
            }
            Section {
                TextEditor(text: $eventDescription)
            } header: {
                Text("Description")
            }
            Section {
                DatePicker("Date", selection: $date)
                    .datePickerStyle(.graphical)
            } header: {
                Text("Date")
            }
        }
    }
#endif
    
    //MARK: watchOS
#if os(watchOS)
    private var formBody: some View {
        Group {
            Section {
                TextField("Event name", text: $title)
            }
            Section {
                TextField("Description", text: $eventDescription)
            }
        }
    }
#endif
    
    private var content: some View {
        VStack {
#if os(OSX)
            Text(event == nil ? "Add event" : "Edit event")
                .font(.headline)
                .padding(.top)
#endif
            Form {
                formBody
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
#if !os(watchOS)
        .navigationTitle(navigationBarTitle)
#endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: saveItem)
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
    
    private func saveItem() {
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
                viewContext.rollback()
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct ManageEventView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ManageEventView()
                .previewDisplayName("Add event")
            ManageEventView(event: DateCounterApp_Previews.event(period: .past))
                .previewDisplayName("Edit event")
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
