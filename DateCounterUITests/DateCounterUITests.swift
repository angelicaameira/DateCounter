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

        let tKey = app/*@START_MENU_TOKEN@*/.keys["T"]/*[[".keyboards.keys[\"T\"]",".keys[\"T\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey.tap()
        let eKey = app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".keyboards.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        eKey.tap()
        let sKey = app/*@START_MENU_TOKEN@*/.keys["s"]/*[[".keyboards.keys[\"s\"]",".keys[\"s\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sKey.tap()
        let tKey2 = app/*@START_MENU_TOKEN@*/.keys["t"]/*[[".keyboards.keys[\"t\"]",".keys[\"t\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey2.tap()
        
        let day26 = app.staticTexts["26"]
        if day26.isHittable {
            day26.tap()
        }

        let saveButton = app.navigationBars["Add event"].buttons["Save"]
        saveButton.tap()
        
        app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test")).firstMatch.tap()
        
        let testNavigationBar = app.navigationBars["Test"]
        testNavigationBar.buttons["Edit this event"].tap()
        app/*@START_MENU_TOKEN@*/.textFields["Event name"]/*[[".cells.textFields[\"Event name\"]",".textFields[\"Event name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        let deleteKey = app/*@START_MENU_TOKEN@*/.keys["delete"]/*[[".keyboards",".keys[\"apagar\"]",".keys[\"delete\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()

        let editEventNavigationBar = app.navigationBars["Edit event"]
        editEventNavigationBar.buttons["Save"].tap()
        app.alerts["An error occurred when adding event"].scrollViews.otherElements.buttons["OK"].tap()
        editEventNavigationBar.buttons["Cancel"].tap()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            testNavigationBar.buttons["Events"].tap()
        }

        XCTAssert(app.cells.containing(NSPredicate(format: "label contains[c] %@", "Test")).firstMatch.exists)
        
        eventsNavigationBar/*@START_MENU_TOKEN@*/.buttons["Edit"]/*[[".otherElements[\"Edit\"].buttons[\"Edit\"]",".buttons[\"Edit\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let deleteLeadingButton = app.cells.buttons["Delete "]
        if deleteLeadingButton.exists {
            deleteLeadingButton.firstMatch.tap() // iOS 15
        } else {
            app.cells.otherElements.containing(.image, identifier:"remove").firstMatch.tap() // iOS 16
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
