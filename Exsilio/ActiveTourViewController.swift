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
import CoreLocation
import Mapbox

class ActiveTourViewController: UIViewController {
    @IBOutlet var navView: DirectionsHeaderView?
    @IBOutlet var tabView: TabControlsView?
    @IBOutlet var mapView: MGLMapView?
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

        navView?.delegate = self
        tabView?.delegate = self
        activeWaypointView?.delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .plain, target: self, action: #selector(dismissModal))

        activeWaypointTop?.constant = self.view.frame.height
        activeWaypointView?.layoutIfNeeded()
    }

    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }

    func startTour(_ completion: (() -> Void)?) {
        if let location = self.mapView?.userLocation {
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
            if let userLocationCoordinate = self.mapView?.userLocation?.coordinate {
                let userLocation = CLLocation(latitude: userLocationCoordinate.latitude,
                                              longitude: userLocationCoordinate.longitude)

                return userLocation.distance(from: location)
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

    func animateToUserLocation() {
        if self.mapView?.userLocation == nil {
            if let waypoint = self.tourJSON!["waypoints"].array?.first {
                self.animateToWaypoint(waypoint)
            }
        }
    }

    func animateToWaypoint(_ waypoint: JSON) {
        if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
            let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
            mapView?.setCenter(coordinate, zoomLevel: 18, animated: true)
        }
    }

    func animateToTourPreview() {
        if
            let minLatitude = tourJSON!["waypoints"].array?.map({ $0["latitude"].floatValue }).min(),
            let minLongitude = tourJSON!["waypoints"].array?.map({ $0["longitude"].floatValue }).min(),
            let maxLatitude = tourJSON!["waypoints"].array?.map({ $0["latitude"].floatValue }).max(),
            let maxLongitude = tourJSON!["waypoints"].array?.map({ $0["longitude"].floatValue }).max()
        {
            let bounds = MGLCoordinateBounds(sw: CLLocationCoordinate2D(latitude: Double(minLatitude), longitude: Double(minLongitude)),
                                             ne: CLLocationCoordinate2D(latitude: Double(maxLatitude), longitude: Double(maxLongitude)))

            mapView?.setVisibleCoordinateBounds(bounds, edgePadding: UIEdgeInsetsMake(30, 30, 30, 30), animated: true)
        }
    }

    func drawTour() {
        drawPathFromJSON(tourJSON!["directions"], withColor: UI.BlueColor)

        tourJSON!["waypoints"].array?.forEach { waypoint in
            if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
                let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                let annotation = MGLPointAnnotation()
                annotation.coordinate = coordinate
                mapView?.addAnnotation(annotation)
            }
        }

        animateToTourPreview()
    }

    func drawPathFromJSON(_ json: JSON, withColor color: UIColor) {
        var identifier = 0

        json["routes"][0]["legs"].array?.forEach { leg in
            leg["steps"].array?.forEach { step in
                if
                    let startLat = step["start_location"]["lat"].float,
                    let startLng = step["start_location"]["lng"].float,
                    let endLat = step["end_location"]["lat"].float,
                    let endLng = step["end_location"]["lng"].float
                {
                    let startCoordinate = CLLocationCoordinate2D(latitude: Double(startLat), longitude: Double(startLng))
                    let endCoordinate = CLLocationCoordinate2D(latitude: Double(endLat), longitude: Double(endLng))
                    let polyline = MGLPolyline(coordinates: [startCoordinate, endCoordinate], count: UInt(2))
                    mapView?.addAnnotation(polyline)

                    identifier += 1
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
            navView?.layoutIfNeeded()
            tabView?.layoutIfNeeded()
            activeWaypointView?.layoutIfNeeded()

            if !waypointInfoViewVisible {
                activeWaypointView?.updateWaypoint(waypoint)
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

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
}

extension ActiveTourViewController: TabControlsDelegate {
    func willChangeTabState(_ state: TabState) {
        if state == .activeTour {
            startTour() {
                self.tourActive = true
                self.updateUIForCurrentStep()
                self.mapView?.setUserTrackingMode(.followWithCourse, animated: true)
            }
        } else if state == .tourPreview {
            tourActive = false
            animateToTourPreview()
            mapView?.clear()
            allStepsCache = nil
            drawTour()
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

extension ActiveTourViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let userLocation = userLocation else { return }

        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)

        if let step = currentStep(), let latitude = step["end_location"]["lat"].float, let longitude = step["end_location"]["lng"].float {
            let endLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
            let distanceMeters = location.distance(from: endLocation)

            if distanceMeters < 10 {
                self.tabView?.forwardButtonTapped()
            }
        }

        // Are we close to a waypoint?
        if let waypoints = self.tourJSON?["waypoints"].array {
            for waypoint in waypoints {
                //if self.shownWaypointIds.contains(waypoint["id"].intValue) {
                //continue
                //}

                if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
                    let waypointLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
                    let distanceMeters = location.distance(from: waypointLocation)

                    if (distanceMeters < 15 && !waypointInfoViewVisible) || (distanceMeters > 30 && waypointInfoViewVisible && activeWaypointView?.sticky != true) {
                        shownWaypointIds.append(waypoint["id"].intValue)
                        willDisplayWaypointInfo()
                        return
                    }
                }
            }
        }
    }
}
