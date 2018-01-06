//
//  ActiveTourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/23/16.
//
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SCLAlertView

class ActiveTourViewController: UIViewController {
    @IBOutlet var navView: DirectionsHeaderView?
    @IBOutlet var tabView: TabControlsView?
    @IBOutlet var mapView: GMSMapView?
    @IBOutlet var activeWaypointView: ActiveWaypointView?

    @IBOutlet var navTop: NSLayoutConstraint?
    @IBOutlet var tabBottom: NSLayoutConstraint?
    @IBOutlet var activeWaypointTop: NSLayoutConstraint?

    var tourActive = false
    var currentStepIndex = 0
    var shownWaypointIds: [Int] = []
    var waypointInfoViewVisible = false

    var startingPoint: CLLocationCoordinate2D?
    var allStepsCache: [JSON]?
    var tourJSON: JSON?
    var directionsJSON: JSON?
    var directionsPolylines: [GMSPolyline] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()
        self.view.isUserInteractionEnabled = false

        SVProgressHUD.show()
        CurrentTourSingleton.sharedInstance.refreshTour { json in
            self.tourJSON = json
            self.drawTour()
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
        }

        self.navView?.delegate = self
        self.tabView?.delegate = self
        self.activeWaypointView?.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.mapView?.isBuildingsEnabled = true
        self.mapView?.isIndoorEnabled = true
        self.mapView?.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .plain, target: self, action: #selector(dismissModal))

        self.activeWaypointTop?.constant = self.view.frame.height
        self.activeWaypointView?.layoutIfNeeded()
    }

    deinit {
        self.mapView?.removeObserver(self, forKeyPath: "myLocation")
    }

    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }

    func startTour(_ completion: (() -> Void)?) {
        if let location = self.mapView?.myLocation {
            SVProgressHUD.show()

            let params = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
            let id = self.tourJSON!["id"].int!
            Alamofire.request("\(API.URL)\(API.ToursPath)/\(id)/start", method: .get, parameters: params, headers: API.authHeaders()).responseJSON { response in
                switch response.result {
                case .success(let jsonObj):
                    let json = JSON(jsonObj)
                    self.directionsJSON = json
                    self.drawPathFromJSON(json, withColor: UI.RedColor)
                    self.shownWaypointIds = []
                    self.cacheAllSteps()

                    fallthrough
                default:
                    SVProgressHUD.dismiss()
                    completion?()
                }
            }
        } else {
            completion?()
        }
    }

    func updateUIForCurrentStep() {
        if let currentStep = self.currentStep(), let allStepsCache = self.allStepsCache {
            self.navView?.updateStep(currentStep)
            self.tabView?.updateStepIndex(self.currentStepIndex, outOf: allStepsCache.count)
        }
    }

    func currentStep() -> JSON? {
        guard let allStepsCache = self.allStepsCache , allStepsCache.count > self.currentStepIndex else { return nil }

        return allStepsCache[self.currentStepIndex]
    }

    func currentWaypoint() -> JSON? {
        let distanceToLocation: ((CLLocation) -> Double?) = { location in
            if let myLocation = self.mapView?.myLocation {
                return myLocation.distance(from: location)
            }

            return nil
        }


        if let waypoints = self.tourJSON?["waypoints"].array {
            let sorted = waypoints.sorted { (a, b) in
                let latitudeA = a["latitude"].floatValue
                let latitudeB = b["latitude"].floatValue
                let longitudeA = a["longitude"].floatValue
                let longitudeB = b["longitude"].floatValue
                let locationA = CLLocation(latitude: Double(latitudeA), longitude: Double(longitudeA))
                let locationB = CLLocation(latitude: Double(latitudeB), longitude: Double(longitudeB))

                return distanceToLocation(locationA) ?? 0.0 < distanceToLocation(locationB) ?? 0.0
            }

            return sorted.first
        }

        return nil
    }

    func animateToMyLocation() {
        if let location = self.mapView?.myLocation?.coordinate {
            self.mapView?.animate(with: GMSCameraUpdate.setTarget(location, zoom: 18))
            self.mapView?.animate(toViewingAngle: 45)
        } else {
            if let waypoint = self.tourJSON!["waypoints"].array?.first {
                self.animateToWaypoint(waypoint)
            }
        }
    }

    func animateToWaypoint(_ waypoint: JSON) {
        if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
            let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
            self.mapView?.animate(with: GMSCameraUpdate.setTarget(coordinate, zoom: 18))
        }
    }

    func animateToTourPreview() {
        var bounds = GMSCoordinateBounds()

        self.tourJSON!["waypoints"].array?.forEach { waypoint in
            if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
                let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                bounds = bounds.includingCoordinate(coordinate)
            }
        }

        if let location = self.mapView?.myLocation {
            bounds = bounds.includingCoordinate(location.coordinate)
        }

        self.mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30))
    }

    func drawTour() {
        self.drawPathFromJSON(self.tourJSON!["directions"], withColor: UI.BlueColor)

        self.tourJSON!["waypoints"].array?.forEach { waypoint in
            if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
                let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                let marker = GMSMarker(position: coordinate)
                marker.map = self.mapView
            }
        }

        self.animateToTourPreview()
    }

    func drawPathFromJSON(_ json: JSON, withColor color: UIColor) {
        json["routes"][0]["legs"].array?.forEach { leg in
            leg["steps"].array?.forEach { step in
                if let encodedPath = step["polyline"]["points"].string {
                    let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: encodedPath))
                    polyline.strokeWidth = 4.0
                    polyline.strokeColor = color
                    polyline.map = self.mapView
                }
            }
        }
    }

    @discardableResult func cacheAllSteps() -> [JSON] {
        if let cache = self.allStepsCache {
            return cache
        }

        var steps: [JSON] = []

        let appendToSteps: ((JSON?) -> Void) = { json in
            guard let json = json else { return }
            json["routes"][0]["legs"].array?.forEach { leg in
                leg["steps"].array?.forEach { steps.append($0) }
            }
        }

        appendToSteps(self.directionsJSON)
        appendToSteps(self.tourJSON)

        self.allStepsCache = steps
        return steps
    }

    func toggleWaypointInfoView() {
        if let waypoint = self.currentWaypoint() {
            self.navView?.layoutIfNeeded()
            self.tabView?.layoutIfNeeded()
            self.activeWaypointView?.layoutIfNeeded()

            if !self.waypointInfoViewVisible {
                self.activeWaypointView?.updateWaypoint(waypoint)
            }

            UIView.animate(withDuration: 0.5, animations: {
                if self.waypointInfoViewVisible {
                    self.navTop?.constant = 0
                    self.tabBottom?.constant = 0
                    self.activeWaypointTop?.constant = self.view.frame.height
                    self.waypointInfoViewVisible = false
                } else {
                    self.navTop?.constant = -self.navView!.frame.height
                    self.tabBottom?.constant = self.navView!.frame.height
                    self.activeWaypointTop?.constant = 30
                    self.waypointInfoViewVisible = true
                }

                self.navView?.layoutIfNeeded()
                self.tabView?.layoutIfNeeded()
                self.activeWaypointView?.layoutIfNeeded()
                self.mapView?.layoutIfNeeded()
            })
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath , keyPath == "myLocation" && tourActive == true else { return }

        if let location = self.mapView?.myLocation {
            if let step = self.currentStep(), let latitude = step["end_location"]["lat"].float, let longitude = step["end_location"]["lng"].float {
                let endLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
                let distanceMeters = location.distance(from: endLocation)

                if distanceMeters < 10 {
                    self.tabView?.forwardButtonTapped()
                }
            }

            // Are we close to a waypoint?
            if let waypoints = self.tourJSON?["waypoints"].array {
                for waypoint in waypoints {
                    if self.shownWaypointIds.contains(waypoint["id"].intValue) {
                        continue
                    }

                    if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
                        let waypointLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
                        let distanceMeters = location.distance(from: waypointLocation)

                        if (distanceMeters < 15 && !self.waypointInfoViewVisible) || (distanceMeters > 30 && self.waypointInfoViewVisible && self.activeWaypointView?.sticky != true) {
                            self.shownWaypointIds.append(waypoint["id"].intValue)
                            self.willDisplayWaypointInfo()
                            return
                        }
                    }
                }
            }
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension ActiveTourViewController: TabControlsDelegate {
    func willChangeTabState(_ state: TabState) {
        if state == .activeTour {
            self.startTour() {
                self.tourActive = true
                self.animateToMyLocation()
                self.updateUIForCurrentStep()
            }
        } else if state == .tourPreview {
            self.tourActive = false
            self.animateToTourPreview()
            self.mapView?.clear()
            self.allStepsCache = nil
            self.drawTour()
        }
    }

    func willMoveToNextStep() {
        if self.allStepsCache == nil || self.currentStepIndex == self.allStepsCache!.count {
            return
        }

        self.currentStepIndex += 1
        self.updateUIForCurrentStep()
    }

    func willMoveToPreviousStep() {
        if self.currentStepIndex == 0 {
            return
        }

        self.currentStepIndex -= 1
        self.updateUIForCurrentStep()
    }

    func willDisplayWaypointInfo() {
        self.activeWaypointView?.sticky = true
        self.toggleWaypointInfoView()
    }
}

extension ActiveTourViewController: ActiveWaypointViewDelegate {
    func activeWaypointViewWillBeDismissed() {
        self.toggleWaypointInfoView()
    }
}

extension ActiveTourViewController: DirectionsHeaderDelegate {
    func willDismissFromHeader() {
        self.dismissModal()
    }
}
