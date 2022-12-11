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
  
  var body: some View {
    Form {
      Picker("Title", selection: $string) {
        ForEach(options, id: \.self) { string in
          Text(string)
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
