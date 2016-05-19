//
//  TourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/19/16.
//
//

import UIKit
import CoreLocation

class TourViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: GMSMapView?

    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView?.mapType = kGMSTypeTerrain
        self.mapView?.delegate = self
        self.mapView?.myLocationEnabled = true
        self.mapView?.animateToZoom(15)

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        if let coordinate = locations.first?.coordinate {
            self.mapView?.animateToLocation(coordinate)
            self.mapView?.animateToZoom(15)
        }
    }
}