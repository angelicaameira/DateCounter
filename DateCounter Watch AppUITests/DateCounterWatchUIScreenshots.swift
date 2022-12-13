//
//  DateCounterUIScreenshots.swift
//  DateCounterUITests
//
//  Created by Antonio Germano on 13/12/22.
//

import XCTest
@testable import DateCounter_Watch_App

final class DateCounterWatchUIScreenshots: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testScreenshots() {
    let app = XCUIApplication()
    app.launch()
    
    // MARK: Onboarding
    attachScreenshot(name: "onboarding-or-new-version")
    
    app.buttons["Continue"].tap()
    
    // MARK: Event list
    attachScreenshot(name: "event-list")
    
    if let screenshots = ProcessInfo.processInfo.environment["APPSTORE_SCREENSHOTS"],
       screenshots == "1" {
      print("Environment funcionou no TEST")
    }
    
    // Detail event
    let eventTitle = "Vacation"
    let cellsContainingTest = app.cells.containing(NSPredicate(format: "label contains[c] %@", eventTitle))
    XCTAssert(cellsContainingTest.firstMatch.exists, "Failed to find Vacation event. Is the app running on preview mode?")
    cellsContainingTest.firstMatch.tap()
    attachScreenshot(name: "event-detail")
    
    // Add event
    let eventsNavigationBar = app.navigationBars["Events"]
    eventsNavigationBar.buttons["Add Event"].tap()
    
    let eventNameTextField = app.textViews.firstMatch
    eventNameTextField.tap()
    eventNameTextField.typeText("Disney trip")
    
    let day26 = app.staticTexts["26"]
    if day26.isHittable {
      day26.tap()
    }
    attachScreenshot(name: "event-add")
    
    let editEventNavigationBar = app.navigationBars["Add event"]
    editEventNavigationBar.buttons["Cancel"].tap()
  }
}

extension XCTestCase {
  func attachScreenshot(name: String) {
    let app = XCUIApplication()

    let screenshot = app.windows.firstMatch.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
