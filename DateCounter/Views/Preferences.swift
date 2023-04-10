//
//  EventListRow.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 22/10/22.
//

import SwiftUI

struct Preferences: View {
  @AppStorage("My.preference")
  private var string = "Oops"
  private var options: [(id: UUID, key: LocalizedStringKey)] = [
    (id: UUID(), key: "Test"),
    (id: UUID(), key: "Two"),
    (id: UUID(), key: "Oops")
  ]
  
  var body: some View {
    Form {
      Picker(NSLocalizedString("title", comment: ""), selection: $string) {
        ForEach(options, id: \.id) { string in
          Text(string.key)
        }
      }
      .pickerStyle(.inline)
    }
    .navigationTitle("Settings")
    .frame(width: 300)
    .padding(80)
  }
}

#if !TEST
struct Preferences_Previews: PreviewProvider {
  static var previews: some View {
#if os(OSX)
    Preferences()
#else
    Text("Unsupported platform\n(maybe this will change!)")
      .multilineTextAlignment(.center)
#endif
  }
}
#endif
