//
//  UISplitViewController+Appearance.swift
//  TheDateCounter
//
//  Created by Antonio Germano on 30/11/22.
//

import Foundation
import SwiftUI
import CoreData

#if !os(OSX) && !os(watchOS)
extension UISplitViewController {
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredDisplayMode = .oneBesideSecondary
    self.preferredSplitBehavior = .displace
  }
}
#endif

extension View {
  @ViewBuilder
  public func blankWithoutContext<BlankView>(_ object: NSManagedObject, blankView: () -> BlankView) -> some View where BlankView: View {
    if object.managedObjectContext != nil {
      self
    } else {
      blankView()
    }
  }
}
