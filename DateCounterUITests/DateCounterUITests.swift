//
//  DateCounterUITests.swift
//  DateCounterUITests
//
//  Created by Antonio Germano on 04/10/22.
//

import XCTest
@testable import TheDateCounter

final class DateCounterUITests: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
#if os(iOS)
  func testEventHasRequiredTitleField_CancelEditing() throws {
    let app = XCUIApplication()
    app.launch()
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      XCUIDevice.shared.orientation = .landscapeLeft
    } else {
      XCUIDevice.shared.orientation = .portrait
    }
    
    app.buttons["Continue"].tap()
    
    let eventsNavigationBar = app.navigationBars["Events"]
    eventsNavigationBar.buttons["Add Event"].tap()
    
    let eventNameTextField = app.textViews.firstMatch
    eventNameTextField.tap()
    
    eventNameTextField.typeText("Test")
    
    let day26 = app.staticTexts["26"]
    if day26.isHittable {
      day26.tap()
    }
    
    let saveButton = app.navigationBars["Add event"].buttons["Save"]
    saveButton.tap()
    
    app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test")).firstMatch.tap()
    
    let testNavigationBar = app.navigationBars["Test"]
    testNavigationBar.buttons["Edit this event"].tap()
    let eventTitleTextField = app.textViews.firstMatch
    
    eventTitleTextField.tap()
    continueAfterFailure = true
    eventTitleTextField.clearText()
    continueAfterFailure = false
    
    let editEventNavigationBar = app.navigationBars["Edit event"]
    editEventNavigationBar.buttons["Save"].tap()
    app.alerts["An error occurred when adding event"].scrollViews.otherElements.buttons["OK"].tap()
    editEventNavigationBar.buttons["Cancel"].tap()
    
    if UIDevice.current.userInterfaceIdiom == .phone {
      testNavigationBar.buttons["Events"].tap()
    }
    
    let cellsContainingTest = app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test"))
    XCTAssert(cellsContainingTest.firstMatch.exists)
    
    eventsNavigationBar.buttons["Edit"].tap()
    let deleteLeadingButton = cellsContainingTest.buttons["Delete "]
    if deleteLeadingButton.exists {
      deleteLeadingButton.firstMatch.tap() // iOS 15
    } else {
      cellsContainingTest.otherElements.containing(.image, identifier: "remove").firstMatch.tap() // iOS 16
    }
    app.buttons["Delete"].tap()
    eventsNavigationBar.buttons["Done"].tap()
    
    XCTAssert(app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test")).firstMatch.exists == false)
  }
  
  func testEventHasRequiredTitleField_FixName() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launch()
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      XCUIDevice.shared.orientation = .landscapeLeft
    } else {
      XCUIDevice.shared.orientation = .portrait
    }
    
    // Add event
    let eventsNavigationBar = app.navigationBars["Events"]
    eventsNavigationBar.buttons["Add Event"].tap()
    
    let eventNameTextField = app.textViews.firstMatch
    eventNameTextField.tap()
    
    eventNameTextField.typeText("Test")
    
    let day26 = app.staticTexts["26"]
    if day26.isHittable {
      day26.tap()
    }
    
    let saveButton = app.navigationBars["Add event"].buttons["Save"]
    saveButton.tap()
    
    // List event
    app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test")).firstMatch.tap()
    
    // Edit event
    let testNavigationBar = app.navigationBars["Test"]
    testNavigationBar.buttons["Edit this event"].tap()
    let eventTitleTextField = app.textViews.firstMatch
    
    eventTitleTextField.tap()
    continueAfterFailure = true
    eventTitleTextField.clearText()
    continueAfterFailure = false
    
    let editEventNavigationBar = app.navigationBars["Edit event"]
    editEventNavigationBar.buttons["Save"].tap()
    
    // Error: title is required
    app.alerts["An error occurred when adding event"].scrollViews.otherElements.buttons["OK"].tap()
    eventTitleTextField.tap()
    eventTitleTextField.typeText("New name")
    editEventNavigationBar.buttons["Save"].tap()
    
    // Detail edited event
    let barContainingNewName = app.navigationBars.containing(NSPredicate(format: "label contains[c] %@", "New name"))
    XCTAssert(barContainingNewName.firstMatch.exists)
    
    if UIDevice.current.userInterfaceIdiom == .phone {
      app.navigationBars["New name"].buttons["Events"].tap()
    }
    
    let cellsContainingNewName = app.cells.containing(NSPredicate(format: "label contains[c] %@", "New name"))
    XCTAssert(cellsContainingNewName.firstMatch.exists)
    cellsContainingNewName.firstMatch.tap()
    
    // Delete event
    let newNameNavigationBar = app.navigationBars["New name"]
    newNameNavigationBar.buttons["Delete this event"].tap()
    app.buttons["Delete"].tap()
    
    sleep(3)
    XCTAssert(app.navigationBars["New name"].firstMatch.exists == false) // tests removal on iPad
    XCTAssert(app.cells.containing(NSPredicate(format: "label contains[c] %@", "New name")).firstMatch.exists == false)
  }
#endif
  
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}

extension XCUIElement {
  /**
   Removes any current text in the field before typing in the new value
   - Parameter text: the text to enter into the field
   */
  func clearText() {
    guard let stringValue = self.value as? String else {
      XCTFail("Tried to clear text of a non string value")
      return
    }
    self.tap()
    let app = XCUIApplication()
    app.staticTexts["Select All"].tap()
    app.staticTexts["Cut"].tap()
    
    let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
    self.typeText(deleteString)
  }
}
