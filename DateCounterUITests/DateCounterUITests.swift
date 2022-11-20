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
    func testEvenHasRequiredTitleField_CancelEditing() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeRight
        }
        
        let eventsNavigationBar = app.navigationBars["Events"]
        eventsNavigationBar.buttons["Add Event"].tap()

        let eventNameTextField = app/*@START_MENU_TOKEN@*/.textFields["Event name"]/*[[".cells[\"Event name\"].textFields[\"Event name\"]",".textFields[\"Event name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
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
        let eventTitleTextField = app/*@START_MENU_TOKEN@*/.textFields["Event name"]/*[[".cells.textFields[\"Event name\"]",".textFields[\"Event name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        eventTitleTextField.tap()
        eventTitleTextField.clearText()

        let editEventNavigationBar = app.navigationBars["Edit event"]
        editEventNavigationBar.buttons["Save"].tap()
        app.alerts["An error occurred when adding event"].scrollViews.otherElements.buttons["OK"].tap()
        editEventNavigationBar.buttons["Cancel"].tap()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            testNavigationBar.buttons["Events"].tap()
        }

        let cellsContainingTest = app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test"))
        XCTAssert(cellsContainingTest.firstMatch.exists)
        
        eventsNavigationBar/*@START_MENU_TOKEN@*/.buttons["Edit"]/*[[".otherElements[\"Edit\"].buttons[\"Edit\"]",".buttons[\"Edit\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let deleteLeadingButton = cellsContainingTest.buttons["Delete "]
        if deleteLeadingButton.exists {
            deleteLeadingButton.firstMatch.tap() // iOS 15
        } else {
            cellsContainingTest.otherElements.containing(.image, identifier:"remove").firstMatch.tap() // iOS 16
        }
        app.buttons["Delete"].tap()
        eventsNavigationBar/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements[\"Done\"].buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssert(app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test")).firstMatch.exists == false)
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
