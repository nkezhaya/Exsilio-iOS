//
//  MapViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/5/16.
//
//

import UIKit
import CoreLocation
import SwiftyJSON
import FontAwesome_swift
import Mapbox

protocol MapViewDelegate {
    func mapView(_ mapView: MGLMapView, didTapAt: CLLocationCoordinate2D)
}

class MapViewController: UIViewController {
    @IBOutlet var mapView: MGLMapView?

    var delegate: MapViewDelegate?
    var startingPoint: CLLocationCoordinate2D?

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        mapView?.addGestureRecognizer(tapGestureRecognizer)

        if let startingPoint = startingPoint {
            setCoordinate(startingPoint)
        }

        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(done))
    }

    func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let mapView = mapView, let delegate = delegate else { return }
        delegate.mapView(mapView, didTapAt: coordinate)
        mapView.setCenter(coordinate, zoomLevel: 15, animated: true)
    }

    func done() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc private func mapViewTapped(gestureRecognizer: UITapGestureRecognizer) {
        guard let mapView = mapView, let delegate = delegate else { return }
        let coordinate = mapView.convert(gestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
        delegate.mapView(mapView, didTapAt: coordinate)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        if startingPoint != nil {
            return
        }

        if let coordinate = locations.first?.coordinate {
            setCoordinate(coordinate)
        }
    }
}
