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
    private var coreDataManager = CoreDataManager.shared
    var isRecording = false
    var startWalk: Date?

    lazy var viewModel: MapViewModel = {
        return MapViewModel()
    }()

    // A track is created using an array of points
    private var track: [CLLocationCoordinate2D]!

    @IBOutlet public weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .none
            mapView.delegate = self
        }
    }

    @IBOutlet private weak var tracksTable: UITableView!
    let cellIdentifier = "TrackCell"
    let cellHeight: CGFloat = 115.0

    @IBOutlet private weak var btnRecord: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Walk Tracker"
        initVM()
    }

    private func initVM() {
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                if self?.viewModel.numberOfCells != 0 {
                    self?.tracksTable.isHidden = false
                }
                self?.tracksTable.reloadData()
            }
        }
        viewModel.saveTrackClosure = { [weak self] (_ success: Bool) in
            if success {
                let alert = UIAlertController(title: "Thanks!",
                                              message: "Your walk has been saved",
                                              preferredStyle: .alert)
                let alertOkAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                    self?.viewModel.initLoadingTracks()
                }
                alert.addAction(alertOkAction)
                self?.present(alert, animated: false, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error",
                                              message: "Error saving track",
                                              preferredStyle: .alert)
                let alertOkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertOkAction)
                self?.present(alert, animated: false, completion: nil)
            }
        }
        viewModel.removeTrackClosure = { [weak self] (_ success: Bool) in
            if success {
                let alert = UIAlertController(title: "Cool!",
                                              message: "That track has been removed",
                                              preferredStyle: .alert)
                let alertOkAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                    self?.viewModel.initLoadingTracks()
                }
                alert.addAction(alertOkAction)
                self?.present(alert, animated: false, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error",
                                              message: "Error removing track",
                                              preferredStyle: .alert)
                let alertOkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertOkAction)
                self?.present(alert, animated: false, completion: nil)
            }
        }
        setup()
        viewModel.initLoadingTracks()
    }

    private func setup() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        checkLocationPermissionStatus()
        track = [CLLocationCoordinate2D]()
        self.tracksTable.register(UINib(nibName: "TrackTableViewCell",
                                        bundle: Bundle.main),
                                  forCellReuseIdentifier: self.cellIdentifier)
        tracksTable.delegate = self
        tracksTable.dataSource = self
    }

    @IBAction private func trackRecord() {
        isRecording = !isRecording
        mapView.removeAnnotations(mapView.annotations)
        self.btnRecord.setTitle(isRecording ? "Stop Recording" : "Start Recording", for: .normal)
        let marker = MKPointAnnotation()
        if let coord = locationManager.location?.coordinate {
            marker.coordinate = coord
        }
        marker.title = isRecording ? "Start" : "End"
        mapView.addAnnotation(marker)
        if isRecording {
            track = [CLLocationCoordinate2D]()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            startWalk = Date()
        } else {
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            var walkDuration = 0.0
            if let startWalkDuration = startWalk?.timeIntervalSinceNow {
                walkDuration = startWalkDuration * -1
            }
            if let startPoint = track.first, let endPoint = track.last {
                let start = CLLocation(coordinate: startPoint,
                                       altitude: 0,
                                       horizontalAccuracy: 0,
                                       verticalAccuracy: 0,
                                       timestamp: Date())
                let end = CLLocation(coordinate: endPoint,
                                     altitude: 0,
                                     horizontalAccuracy: 0,
                                     verticalAccuracy: 0,
                                     timestamp: Date())
                let distance = start.distance(from: end) / 1000
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM/d/yyyy, hh:mm:ss"
                let today = dateFormatter.string(from: Date())
                let trackName = "Walk-\(today)"
                self.viewModel.saveTrack(trackInfo: track,
                                         distance: distance,
                                         name: trackName,
                                         duration: walkDuration)
            }
        }
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
    }
}

// MARK: - TableViewDelegate
extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellVM = viewModel.getCellViewModel( at: indexPath )
        tableView.deselectRow(at: indexPath, animated: false)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(
            withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.trackDetail = cellVM
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeTrack(index: indexPath.row,
                                  track: viewModel.getCellViewModel(at: indexPath))
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - TableViewDataSource
extension MapViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: self.cellIdentifier,
            for: indexPath) as? TrackTableViewCell else {
            fatalError("Cell does not exist in storyboard")
        }
        let cellVM = viewModel.getCellViewModel( at: indexPath )
        cell.trackCellViewModel = cellVM
        return cell
    }
}

// MARK: - MapViewDelegate
extension MapViewController: MKMapViewDelegate {

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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let location = lastLocation.coordinate
            track.append(location)
            let polyline = MKPolyline(coordinates: track, count: track.count)
            mapView.addOverlay(polyline)
        }
    }
}
