//
//  EventListRow.swift
//  DateCounter
//
//  Created by Antonio Germano on 22/10/22.
//

import SwiftUI

struct EventListRow: View {
    @ObservedObject
    var event: Event
    
    var body: some View {
        NavigationLink {
            DetailView(event: event)
        } label: {
            HStack {
                Text(event.title ?? "Unnamed event")
                Spacer()
                if let date = event.date {
                    Text(date, style: .relative)
                }
            }
        }
#if os(OSX)
        .onDeleteCommand {
            //TODO: refactor to allow deleting the row here
        }
#endif
    }
}

struct EventListRow_Previews: PreviewProvider {
    
    static var previews: some View {
        EventListRow(event: DateCounterApp_Previews.event(period: nil))
            .previewLayout(.fixed(width: 300, height: 70))
            .previewDisplayName("Single row")
        
        NavigationView {
            List {
                ForEach(0...3, id: \.self) { section in
                    Section {
                        ForEach(0...4, id: \.self) { item in
                            EventListRow(event: DateCounterApp_Previews.event(period: nil))
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
