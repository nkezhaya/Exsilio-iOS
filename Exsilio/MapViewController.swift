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

class MapViewController: UIViewController {
    @IBOutlet var mapView: GMSMapView?

    var delegate: GMSMapViewDelegate?
    var startingPoint: CLLocationCoordinate2D?

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView?.mapType = kGMSTypeTerrain
        self.mapView?.delegate = self.delegate
        self.mapView?.myLocationEnabled = true
        self.mapView?.animateToZoom(15)

        if self.startingPoint != nil {
            self.setCoordinate(self.startingPoint!)
        }

        self.locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }

        showNavigation()
    }

    func showNavigation() {
        let navBarHeight = CGFloat(44)
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, navBarHeight + 20))

        navigationBar.backgroundColor = UIColor.whiteColor()

        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = self.title

        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .Done,
                                                            target: self,
                                                            action: #selector(done))

        navigationBar.items = [navigationItem]

        self.view.addSubview(navigationBar)
    }

    func setCoordinate(coordinate: CLLocationCoordinate2D) {
        self.delegate?.mapView!(self.mapView!, didTapAtCoordinate: coordinate)
        self.mapView?.animateToLocation(coordinate)
        self.mapView?.animateToZoom(15)
    }

    func done() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        if self.startingPoint != nil {
            return
        }

        if let coordinate = locations.first?.coordinate {
            self.setCoordinate(coordinate)
        }
    }
}