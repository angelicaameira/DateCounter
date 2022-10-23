//
//  EventListRow.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 22/10/22.
//

import SwiftUI

struct Preferences: View {
    @AppStorage("My.preference")
    private var string = "Ops"
    private var options = ["Test", "Two", "Oops"]
//    private var zoom: MapView.Zoom = .medium

    var body: some View {
        Form {
            Picker("Title", selection: $string) {
                ForEach(options, id: \.self) { string in
                    Text(string)
                }
            }
            .pickerStyle(.inline)
        }
        .frame(width: 300)
        .navigationTitle("Settings")
        .padding(80)
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}
