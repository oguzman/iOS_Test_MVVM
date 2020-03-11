//
//  MapViewModel.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/7/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import MapKit

public class MapViewModel {

    // MARK: - Properties
    private var tracks: [TrackInfo] = [TrackInfo]()
    let coreDataManager: CoreDataManagerProtocol
    
    private var cellViewModels: [TrackTableCellViewModel] = [TrackTableCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var reloadTableViewClosure: (()->())?
    var saveTrackClosure: ((Bool)->Void)?
    var removeTrackClosure: ((Bool)->Void)?
    
    // MARK: - Lifecycle
    
    init (coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> TrackTableCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel( track: TrackInfo? ) -> TrackTableCellViewModel? {
        if let trackName = track?.name, let distance = track?.distance, let time = track?.time,
            let trackPath = track?.track {
            let trackDistance = "Distance: \(String(format: "%.2f", distance)) KM"
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .full
            let trackTime = "Duration: \(formatter.string(from: TimeInterval(time))!)"
            return TrackTableCellViewModel(nameText: trackName,
                                           distanceText: trackDistance,
                                           durationText: trackTime,
                                           track: trackPath)
        }
        return nil
    }
    
    func initLoadingTracks() {
        if let loadedTracks = coreDataManager.loadTracks() {
            self.tracks = loadedTracks
            var vms = [TrackTableCellViewModel]()
            for cellTrack in loadedTracks {
                if let createdCell = createCellViewModel(track: cellTrack) {
                    vms.append(createdCell)
                }
            }
            self.cellViewModels = vms
        }
    }
    
    func saveTrack(trackInfo: [CLLocationCoordinate2D], distance: Double, name: String, duration: Double) {
        let saved = coreDataManager.saveTrack(trackInfo: trackInfo,
                                              distance: distance,
                                              name: name,
                                              duration: duration)
        self.saveTrackClosure?(saved)
    }
    
    func removeTrack(index: Int, track: TrackTableCellViewModel) {
        self.tracks.remove(at: index)
        self.cellViewModels.remove(at: index)
        let removed = coreDataManager.removeTrack(trackInfo: track)
        removeTrackClosure?(removed)
    }
}
