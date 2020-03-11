//
//  CoreLocationTests.swift
//  GrainChain_iOSTests
//
//  Created by Guzmán, Omar (Cognizant) on 3/11/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import GrainChain_iOS

class CoreLocationTests: XCTestCase {

    var sut: CoreDataManager?
    
    override func setUp() {
        super.setUp()
        sut = CoreDataManager.shared
        sut?.storeType = NSInMemoryStoreType
        //save model and test
        let coordStartMock = CLLocationCoordinate2D(latitude: 19.741755, longitude: -155.844437)
        let coordEndMock = CLLocationCoordinate2D(latitude: 19.7558, longitude: -155.833437)
        let trackInfoMock = [coordStartMock, coordEndMock]
        let mockDistance = 100.0
        let mockName = "Walk-In-Hawaii"
        let mockDuration = 10.0
        let result = sut?.saveTrack(trackInfo: trackInfoMock, distance: mockDistance, name: mockName, duration: mockDuration)
        if let result = result {
            if result == false {
                XCTFail()
            }
        }
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testExample() {
        let sut = self.sut!
        
        let tracks = sut.loadTracks()
        XCTAssertNotNil(tracks)
    }
    
    func testInsertTrack() {
        let coordStartMock = CLLocationCoordinate2D(latitude: 19.741755, longitude: -155.844437)
        let coordEndMock = CLLocationCoordinate2D(latitude: 19.7558, longitude: -155.833437)
        let trackInfoMock = [coordStartMock, coordEndMock]
        let mockDistance = 100.0
        let mockName = "Walk-In-Hawaii"
        let mockDuration = 10.0
        let result = sut?.saveTrack(trackInfo: trackInfoMock, distance: mockDistance, name: mockName, duration: mockDuration)
        XCTAssertTrue(result!)
    }

}
