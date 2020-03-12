//
//  DetailViewController.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/10/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics

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
            let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
            self.navigationItem.rightBarButtonItem = shareButton
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

    @objc
    private func share() {
        if let trackDetail = trackDetail {
            let shareText = "I've had a \(trackDetail.nameText) of \(trackDetail.distanceText) for \(trackDetail.durationText) using Walk Tracker App"
            let shareImage: UIImage?
            var shareContent: [Any] = [shareText]
            if let getShareImage = getImage() {
                shareImage = getShareImage
                shareContent.append(shareImage!)
            }
            let shareActivity = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
            self.present(shareActivity, animated: true, completion: nil)
        }
    }

    private func getImage() -> UIImage? {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.mapView.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        self.mapView.drawHierarchy(in: self.mapView.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
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
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 5
        return renderer
    }
}
