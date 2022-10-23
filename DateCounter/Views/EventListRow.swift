//
//  EventListRow.swift
//  DateCounter
//
//  Created by Antonio Germano on 22/10/22.
//

import SwiftUI

struct EventListRow: View {
    let event: Event
    
    var body: some View {
        NavigationLink {
            DetailView(event: event)
        } label: {
            HStack {
                Text(event.title ?? "Unnamed event")
                Spacer()
                Text(event.date?.formatted() ?? Date.now.formatted())
            }
        }
    }
}

struct EventListRow_Previews: PreviewProvider {
    static var previews: some View {
        EventListRow(event: DateCounterApp_Previews.event)
            .previewLayout(.fixed(width: 300, height: 70))
            .previewDisplayName("Row")
        List {
            ForEach(0...15, id: \.self) { item in
                EventListRow(event: DateCounterApp_Previews.event)
            }
        }
    }
}
