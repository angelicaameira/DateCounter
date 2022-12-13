//
//  ManageEventView.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 06/10/22.
//

import SwiftUI
import CoreData
//#if os(watchOS)
//import WatchDatePicker
//#endif

struct ManageEventView: View {
  // MARK: - Properties
  @Environment(\.managedObjectContext) var viewContext
  @Environment(\.dismiss) var dismiss
  @State private var title = ""
  @State private var eventDescription = ""
  @State private var date = Date()
  @State private var showError = false
  @State private var errorMessage = "No error"
  @State var event: Event?
  @State private var showTimePicker = false
  private var navigationBarTitle: String {
    event == nil ? "Add event" : "Edit event"
  }
  
  // MARK: - Views
  // MARK: Shared
  var body: some View {
#if os(OSX)
    content
      .frame(minWidth: 250, maxWidth: 800)
      .padding()
#else
    NavigationView {
      content
    }
#endif
  }
  
  private var content: some View {
    VStack {
#if os(OSX)
      Text(event == nil ? "Add event" : "Edit event")
        .font(.headline)
        .padding(.top)
#endif
      // swiftlint:disable trailing_closure
      Form {
        formBody
      }
      // swiftlint:enable trailing_closure
      .onAppear(perform: {
        guard
          let event = event,
          title.isEmpty
        else { return }
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
#if !os(watchOS)
    .navigationTitle(navigationBarTitle)
#endif
#if !os(OSX)
    .navigationViewStyle(.stack)
#endif
  }
  
  // MARK: macOS
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
  
  // MARK: iOS
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
  
  // MARK: watchOS
#if os(watchOS)
  private var formBody: some View {
    Group {
      Section {
        TextField("Event name", text: $title)
        TextField("Description", text: $eventDescription)
      }
      Section {
        NavigationLink {
//          DateInputView(selection: $date)
        } label: {
          VStack(alignment: .leading) {
            Text("Date")
            Text(date, style: .date)
              .font(.footnote)
              .foregroundColor(.secondary)
          }
        }
        Button {
          showTimePicker = true
        } label: {
          VStack(alignment: .leading) {
            Text("Time")
            Text(date, style: .time)
              .font(.footnote)
              .foregroundColor(.secondary)
          }
        }
      }
      // sheet or fullScreenCover?
      .sheet(isPresented: $showTimePicker, content: {
//        TimeInputView(selection: $date)
//          .edgesIgnoringSafeArea(.all)
//          .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//              Button("Done") {
//                showTimePicker = false
//              }
//              .foregroundColor(.orange)
//            }
//          }
      })
    }
  }
#endif
  
  // MARK: - Functions
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

// MARK: - Preview
#if !TEST
struct ManageEventView_Previews: PreviewProvider {
  static var addEvent: some View {
    ManageEventView()
  }
  
  static var editEvent: some View {
    ManageEventView(event: TestData.event(period: .past))
  }
  
  @ViewBuilder
  static var shared: some View {
    Color(.white)
      .sheet(isPresented: .constant(true)) {
        addEvent
      }
      .previewDisplayName("Add event")
    Color(.white)
      .sheet(isPresented: .constant(true)) {
        editEvent
      }
      .previewDisplayName("Edit event")
  }
  
  static var previews: some View {
    Group {
#if os(OSX)
      addEvent
        .previewDisplayName("Add event")
      editEvent
        .previewDisplayName("Edit event")
#else
      shared
#endif
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
#endif
