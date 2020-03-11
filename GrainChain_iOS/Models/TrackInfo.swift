//
//  TrackInfoModel.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/7/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import CoreLocation

struct TrackInfo {
    var track: [CLLocationCoordinate2D]?
    var distance: Double?
    var name: String?
    var time: Double?
}
