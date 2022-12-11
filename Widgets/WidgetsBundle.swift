//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Antonio Germano on 08/11/22.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
  var body: some Widget {
    SingleEventWidgets()
    if #available(iOSApplicationExtension 16.1, *) {
#if !os(OSX)
      WidgetsLiveActivity()
#endif
    }
  }
}
