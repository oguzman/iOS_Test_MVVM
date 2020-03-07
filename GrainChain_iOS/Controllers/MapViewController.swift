//
//  ViewController.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/7/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var locationManager: CLLocationManager!
    
    // A track is created using an array of points
    private var track: [CLLocationCoordinate2D]!
    
    @IBOutlet public weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    @IBOutlet private weak var btnRecord: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        checkLocationPermissionStatus()
        track = [CLLocationCoordinate2D]()
    }
    
    @IBAction private func trackRecord() {
        
    }
    
    private func checkLocationPermissionStatus() {
        // user activated automatic authorization info mode
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay)
        pr.strokeColor = .red
        pr.lineWidth = 5
        return pr
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let location = lastLocation.coordinate
            print("new location - lat: \(location.latitude), lng: \(location.longitude)")
            track.append(location)
            let polyline = MKPolyline(coordinates: track, count: track.count)
            mapView.addOverlay(polyline)
        }
    }
}

