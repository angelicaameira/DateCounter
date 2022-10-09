//
//  ContentView.swift
//  DateCounter
//
//  Created by Antonio Germano on 04/10/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    @State private var showingAddAlert = false
    @State private var showError = false
    @State private var errorMessage = "No error"
    
    var body: some View {
        NavigationView {
            List {
                ForEach(events) { event in
                    NavigationLink {
                        DetailView(event: event)
                    } label: {
                        Text(event.title ?? "Unnamed event")
                        Text(event.date?.formatted() ?? Date.now.formatted())
                    }
                    .sheet(isPresented: $showingAddAlert) {
                        AddEventView(event: event)
                    }
                }
                .onDelete(perform: deleteEvents)
            }
#if os(OSX)
            .listStyle(.sidebar)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button {
                        showingAddAlert.toggle()
                    } label: {
                        Label("Add Event", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
            .navigationTitle("Events")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            
            .alert("An error occurred when deleting event", isPresented: $showError, actions: {
                Text("Ok")
            }, message: {
                Text(errorMessage)
            })
        }
    }
    
    private func deleteEvents(offsets: IndexSet) {
        withAnimation {
            offsets.map { events[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
