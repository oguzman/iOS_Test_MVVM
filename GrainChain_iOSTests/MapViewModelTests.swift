//
//  MapViewModelTests.swift
//  GrainChain_iOSTests
//
//  Created by Guzmán, Omar (Cognizant) on 3/11/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation

@testable import GrainChain_iOS

class MapViewModelTests: XCTestCase {
    
    var sut: MapViewModel!
    var mockDataService: CoreDataManagerProtocol!

    override func setUp() {
        super.setUp()
        mockDataService = CoreDataManager.shared
        sut = MapViewModel(coreDataManager: mockDataService)
    }

    override func tearDown() {
        sut = nil
        mockDataService = nil
        super.tearDown()
    }

    func test_fetch_tracks() {
        
        let tracks = mockDataService.loadTracks()
        sut.initLoadingTracks()
        XCTAssert(tracks != nil)
    }

    func test_create_cell_view_model() {
        let tracks = StubGenerator().stubTracks()
        sut.initLoadingTracks()
        
        var localTracks = [TrackTableCellViewModel]()
        for track in tracks {
            if let cellModel = sut?.createCellViewModel(track: track) {
                localTracks.append(cellModel)
            }
        }
        
        XCTAssertEqual(tracks.count, localTracks.count)
        XCTAssertNotNil(tracks)
        XCTAssertNotNil(localTracks)
    }
    
    func test_cell_view_model() {
        let tracks = StubGenerator().stubTracks()
        let cellViewModel = sut!.createCellViewModel(track: tracks.first)
        
        if let firstTrack = tracks.first, let cellViewModel = cellViewModel {
            XCTAssertEqual(firstTrack.name, cellViewModel.nameText)
        } else {
            XCTFail()
        }
        
    }
}

class StubGenerator {
    
    func stubTracks() ->  [TrackInfo] {
        //hawaii
        let hCoordStart = CLLocationCoordinate2D(latitude: 19.741755, longitude: -155.844437)
        let hCoordEnd = CLLocationCoordinate2D(latitude: 19.7558, longitude: -155.833437)
        let trackInfoOne = TrackInfo(track: [hCoordStart, hCoordEnd], distance: 10.0, name: "Walk-Hawaii", time: 10.0)
        //france
        let fCoordStart = CLLocationCoordinate2D(latitude: 48.864716, longitude: 2.349014)
        let fCoordEnd = CLLocationCoordinate2D(latitude: 48.87216, longitude: 2.349333)
        let trackInfoTwo = TrackInfo(track: [fCoordStart, fCoordEnd], distance: 10.0, name: "Walk-France", time: 10.0)
        return [trackInfoOne, trackInfoTwo]
    }
}
