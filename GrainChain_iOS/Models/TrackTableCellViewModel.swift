//
//  TrackTableCellViewModel.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/10/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import CoreLocation

struct TrackTableCellViewModel {
    let nameText: String
    let distanceText: String
    let durationText: String
    let track: [CLLocationCoordinate2D]
}
