//
//  TourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/19/16.
//
//

import UIKit
import CoreLocation
import SwiftyJSON

class TourViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: GMSMapView?

    var locationManager = CLLocationManager()
    var tour: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))

        self.mapView?.mapType = kGMSTypeTerrain
        self.mapView?.delegate = self
        self.mapView?.myLocationEnabled = true

        self.title = self.tour!["name"].string

        if let path = self.tour!["polyline"].string {
            let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: path))
            polyline.strokeWidth = 4.0
            polyline.map = self.mapView
        }

        if let waypoints = self.tour!["waypoints"].array {
            var bounds = GMSCoordinateBounds()

            for waypoint in waypoints {
                if let latitude = waypoint["latitude"].float, longitude = waypoint["longitude"].float {
                    let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                    let marker = GMSMarker(position: coordinate)

                    marker.map = self.mapView

                    bounds = bounds.includingCoordinate(coordinate)
                }
            }

            self.mapView?.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
        }

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
}