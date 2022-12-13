//
//  DateCounterCommands.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 20/10/22.
//

#if !os(watchOS)
import SwiftUI

struct DateCounterCommands: Commands {
  var body: some Commands {
    SidebarCommands()
  }
}
#endif
