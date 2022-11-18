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

    func testEvenHasRequiredTitleField_CancelEditing() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let eventsNavigationBar = app.navigationBars["Events"]
        eventsNavigationBar.buttons["Add Event"].tap()
        
        let tablesQuery = app.tables
        let eventNameTextField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Event name"]/*[[".cells[\"Event name\"].textFields[\"Event name\"]",".textFields[\"Event name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        eventNameTextField.tap()

        let tKey = app/*@START_MENU_TOKEN@*/.keys["T"]/*[[".keyboards.keys[\"T\"]",".keys[\"T\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey.tap()
        let eKey = app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".keyboards.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        eKey.tap()
        let sKey = app/*@START_MENU_TOKEN@*/.keys["s"]/*[[".keyboards.keys[\"s\"]",".keys[\"s\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sKey.tap()
        let tKey2 = app/*@START_MENU_TOKEN@*/.keys["t"]/*[[".keyboards.keys[\"t\"]",".keys[\"t\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey2.tap()
        eKey.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.datePickers["Date"].collectionViews.staticTexts["26"]/*[[".cells[\"Month, Show year picker, novembro de 2022, Previous Month, Next Month, SEG., TER., QUA., QUI., SEX., SÁB., DOM., terça-feira, 1 de novembro, 1, quarta-feira, 2 de novembro, 2, quinta-feira, 3 de novembro, 3, sexta-feira, 4 de novembro, 4, sábado, 5 de novembro, 5, domingo, 6 de novembro, 6, segunda-feira, 7 de novembro, 7, terça-feira, 8 de novembro, 8, quarta-feira, 9 de novembro, 9, quinta-feira, 10 de novembro, 10, sexta-feira, 11 de novembro, 11, sábado, 12 de novembro, 12, domingo, 13 de novembro, 13, segunda-feira, 14 de novembro, 14, terça-feira, 15 de novembro, 15, quarta-feira, 16 de novembro, 16, quinta-feira, 17 de novembro, 17, Today, sexta-feira, 18 de novembro, 18, sábado, 19 de novembro, 19, domingo, 20 de novembro, 20, segunda-feira, 21 de novembro, 21, terça-feira, 22 de novembro, 22, quarta-feira, 23 de novembro, 23, quinta-feira, 24 de novembro, 24, sexta-feira, 25 de novembro, 25, sábado, 26 de novembro, 26, domingo, 27 de novembro, 27, segunda-feira, 28 de novembro, 28, terça-feira, 29 de novembro, 29, quarta-feira, 30 de novembro, 30, segunda-feira, 28 de novembro, terça-feira, 29 de novembro, 07:59, 07:59\"].datePickers[\"Date\"].collectionViews",".buttons[\"sábado, 26 de novembro\"].staticTexts[\"26\"]",".staticTexts[\"26\"]",".datePickers[\"Date\"].collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()

        let saveButton = app.navigationBars["Add event"].buttons["Save"]
        saveButton.tap()
        
        app.tables.cells.firstMatch.tap()
        
        let testeNavigationBar = app.navigationBars["Teste"]
        testeNavigationBar.buttons["Edit this event"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Event name"]/*[[".cells.textFields[\"Event name\"]",".textFields[\"Event name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
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
        testeNavigationBar.buttons["Events"].tap()
        
        XCTAssert(app.tables.cells.firstMatch.exists)
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
