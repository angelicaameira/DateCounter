//
//  EventListRow.swift
//  DateCounter
//
//  Created by Antonio Germano on 22/10/22.
//

import SwiftUI

struct EventListRow: View {
  @ObservedObject var event: Event
  
  var body: some View {
    NavigationLink {
      DetailView(event: event)
      // iPadOS needs this to work
        .blankWithoutContext(event) {
          DefaultDetailView(showError: .constant(false), errorMessage: .constant(""))
            .navigationTitle("")
        }
    } label: {
      HStack {
        Text(event.title ?? "Unnamed event")
        Spacer()
        if let date = event.date {
          Text(date, style: .relative)
        }
      }
    }
  }
}

#if !TEST
struct EventListRow_Previews: PreviewProvider {
  static var previews: some View {
    EventListRow(event: TestData.event(period: nil))
      .previewLayout(.fixed(width: 300, height: 70))
      .previewDisplayName("Single row")
    
    NavigationView {
      List {
        ForEach(0...3, id: \.self) { section in
          Section {
            ForEach(0...4, id: \.self) { _ in
              EventListRow(event: TestData.event(period: nil))
            }
          } header: {
            Text("Section \(section)")
          }
        }
      }
      .navigationTitle("EventListRow")
    }
    .previewDisplayName("Multiple rows")
  }
}
#endif
