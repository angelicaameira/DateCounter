//
//  LunarEclipses.swift
//  TheDateCounter
//
//  Created by Angélica Andrade de Meira on 26/11/22.
//

import Foundation

struct LunarEclipse {
  enum EclipseType: String {
    case partial = "Partial"
    case total = "Total"
    case penumbral = "Penumbral"
    
    var stringValue: String { rawValue }
  }
  
  let date: Date?
  let visibility: String
  let type: EclipseType
}

let lunarEclipseDates: [LunarEclipse] = [
  LunarEclipse(date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2023, month: 5, day: 5, hour: 17, minute: 24).date, visibility: "Africa, Asia, Australia", type: .penumbral),
  LunarEclipse(date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2023, month: 10, day: 28, hour: 20, minute: 15).date, visibility: "East Americas, Europe, Africa, Asia, Australia", type: .partial),
  LunarEclipse(date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2024, month: 3, day: 25, hour: 7, minute: 13).date, visibility: "Americas", type: .penumbral),
  LunarEclipse(date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2024, month: 9, day: 18, hour: 2, minute: 45).date, visibility: "Americas, Europe, Africa", type: .partial),
  LunarEclipse(date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 3, day: 14, hour: 20, minute: 15).date, visibility: "Pacific, Americas, Western Europe, Western Africa", type: .total),
  LunarEclipse(date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 9, day: 7, hour: 18, minute: 12).date, visibility: "Europe, Africa, Asia, Australia", type: .total)
]
