//
//  ViewController.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/7/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private let locationManager = CLLocationManager()
    
    @IBOutlet public weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - MapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let regionRadius: CLLocationDistance = 3000
        let coordinate =  userLocation.coordinate
        let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

