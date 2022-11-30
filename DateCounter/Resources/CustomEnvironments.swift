//
//  CustomEnvironments.swift
//  TheDateCounter
//
//  Created by Antonio Germano on 30/11/22.
//

import Foundation
import SwiftUI

private struct EventListCount: EnvironmentKey {
    static let defaultValue = 0
}

extension EnvironmentValues {
    var eventListCount: Int {
        get { self[EventListCount.self] }
        set { self[EventListCount.self] = newValue }
    }
}
