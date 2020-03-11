//
//  DetailViewController.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/10/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet private weak var lblName: UILabel!
    @IBOutlet private weak var lblDistance: UILabel!
    @IBOutlet private weak var lblDuration: UILabel!
    @IBOutlet public weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = false
            mapView.userTrackingMode = .none
            mapView.delegate = self
            drawTrack()
        }
    }
    
    var trackDetail: TrackTableCellViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Track Detail"
        updateUI()
    }
    
    private func updateUI() {
        if let trackDetail = trackDetail {
            lblName.text = trackDetail.nameText
            lblDistance.text = trackDetail.distanceText
            lblDuration.text = trackDetail.durationText
        }
    }
    
    private func drawTrack() {
        DispatchQueue.main.async {
            if let tracks = self.trackDetail?.track {
                let polyline = MKPolyline(coordinates: tracks, count: tracks.count)
                self.mapView.addOverlay(polyline)
            }
        }
    }

}

extension DetailViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let regionRadius: CLLocationDistance = 400
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
