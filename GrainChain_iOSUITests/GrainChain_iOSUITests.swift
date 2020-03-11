//
//  GrainChain_iOSUITests.swift
//  GrainChain_iOSUITests
//
//  Created by Guzmán, Omar (Cognizant) on 3/7/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import XCTest

class GrainChain_iOSUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateTrack() {
        let app = XCUIApplication()
        if app.buttons["Start Recording"].exists {
            app.buttons["Start Recording"].tap()
        }
        if app.buttons["Stop Recording"].exists {
            app.buttons["Stop Recording"].tap()
        }
        if app.alerts["Thanks!"].exists {
            app.alerts["Thanks!"].buttons["Ok"].tap()
        }
    }

}
