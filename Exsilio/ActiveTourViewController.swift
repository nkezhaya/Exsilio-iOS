//
//  ActiveTourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/23/16.
//
//

import UIKit
import SwiftyJSON

class ActiveTourViewController: UIViewController {
    @IBOutlet var navView: DirectionsHeaderView?
    @IBOutlet var mapView: GMSMapView?
    @IBOutlet var tabView: TabControlsView?

    var delegate: GMSMapViewDelegate?
    var startingPoint: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()
        self.drawTour()

        self.navView?.activeTourViewController = self
        self.tabView?.activeTourViewController = self
        self.mapView?.myLocationEnabled = true

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .Plain, target: self, action: #selector(dismiss))
    }

    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func startTour(completion: (Void -> Void)?) {
        completion?()
    }

    func drawTour() {
        let tour = CurrentTourSingleton.sharedInstance.tour

        if let path = tour["polyline"] as? String {
            let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: path))
            polyline.strokeWidth = 4.0
            polyline.map = self.mapView
        }

        if let waypoints = tour["waypoints"] as? [Waypoint] {
            var bounds = GMSCoordinateBounds()

            for waypoint in waypoints {
                if let latitude = waypoint["latitude"] as? Float, longitude = waypoint["longitude"] as? Float {
                    let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                    let marker = GMSMarker(position: coordinate)

                    marker.map = self.mapView

                    bounds = bounds.includingCoordinate(coordinate)
                }
            }

            self.mapView?.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 200))
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
