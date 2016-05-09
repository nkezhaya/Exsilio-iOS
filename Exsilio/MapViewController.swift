//
//  MapViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/5/16.
//
//

import UIKit
import CoreLocation
import FontAwesome_swift

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var mapView: GMSMapView?

    var delegate: GMSMapViewDelegate?
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView?.mapType = kGMSTypeTerrain
        self.mapView?.delegate = self.delegate
        self.mapView?.myLocationEnabled = true
        self.mapView?.animateToZoom(15)

        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.fontAwesomeIconWithName(.Check, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30)),
                                                                 style: .Done,
                                                                 target: self,
                                                                 action: #selector(done))

        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                self.locationManager!.requestWhenInUseAuthorization()
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
            self.delegate?.mapView!(self.mapView!, didTapAtCoordinate: coordinate)
            self.mapView?.animateToLocation(coordinate)
            self.mapView?.animateToZoom(15)
        }
    }

    func done() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}