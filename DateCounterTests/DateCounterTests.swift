//
//  DateCounterTests.swift
//  DateCounterTests
//
//  Created by Antonio Germano on 04/10/22.
//

import XCTest
@testable import TheDateCounter

final class DateCounterTests: XCTestCase {
    
    let contentView = ContentView()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testRemainingTime() {
        let detailView = DetailView(event: TestData.event(period: .month))
        let remainingTime = detailView.remainingTime(forComponent: .second)
        guard let remainingTime = remainingTime else {
            XCTFail("remainingTime could not be generated")
            return
        }
        XCTAssert(remainingTime.distance(to: 150000) <= 1)
    }
    
    func testFutureDateMonth() {
        print("MONTH")
        let finalDate = contentView.monthForFuture(period: .month)
        print(finalDate.formatted())
        
        let components = DateComponents(month: 1)
        
        XCTAssert(finalDate.distance(to: Calendar.current.date(byAdding: components, to: Date.now)!) < 1)
    }
    
    func testFutureDateSemester() {
        print("SEMESTER")
        let finalDate = contentView.monthForFuture(period: .semester)
        print(finalDate.formatted())
        
        let components = DateComponents(month: 6)
        XCTAssert(finalDate.distance(to: Calendar.current.date(byAdding: components, to: Date.now)!) < 1)
    }
    
    func testFutureDateYear() {
        print("YEAR")
        let finalDate = contentView.monthForFuture(period: .year)
        print(finalDate.formatted())
        
        let components = DateComponents(year: 1)
        XCTAssert(finalDate.distance(to: Calendar.current.date(byAdding: components, to: Date.now)!) < 1)
    }
    
    func testFutureDateDecade() {
        print("DECADE")
        let finalDate = contentView.monthForFuture(period: .decade)
        print(finalDate.formatted())
        
        let components = DateComponents(year: 10)
        XCTAssert(finalDate.distance(to: Calendar.current.date(byAdding: components, to: Date.now)!) < 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
