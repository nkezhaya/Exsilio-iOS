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
        self.mapView?.isMyLocationEnabled = true
        self.mapView?.animate(toZoom: 15)

        if self.startingPoint != nil {
            self.setCoordinate(self.startingPoint!)
        }

        self.locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }

        showNavigation()
    }

    func showNavigation() {
        let navBarHeight = CGFloat(44)
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: navBarHeight + 20))

        navigationBar.backgroundColor = UIColor.white

        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = self.title

        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(done))

        navigationBar.items = [navigationItem]

        self.view.addSubview(navigationBar)
    }

    func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.delegate?.mapView!(self.mapView!, didTapAt: coordinate)
        self.mapView?.animate(toLocation: coordinate)
        self.mapView?.animate(toZoom: 15)
    }

    func done() {
        self.dismiss(animated: true, completion: nil)
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

        if self.startingPoint != nil {
            return
        }

        if let coordinate = locations.first?.coordinate {
            self.setCoordinate(coordinate)
        }
    }
}
