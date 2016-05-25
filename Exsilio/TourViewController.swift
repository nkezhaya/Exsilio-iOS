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

            let bounds = GMSCoordinateBounds(path: polyline.path!)
            self.mapView?.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 150))
        }

        if let waypoints = self.tour!["waypoints"].array {
            for waypoint in waypoints {
                if let latitude = waypoint["latitude"].float, longitude = waypoint["longitude"].float {
                    let marker = GMSMarker(
                        position: CLLocationCoordinate2D(
                            latitude: Double(latitude),
                            longitude: Double(longitude)))

                    marker.map = self.mapView
                }
            }
        }

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
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