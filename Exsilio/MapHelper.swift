//
//  MapHelper.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/7/18.
//

import Mapbox
import SwiftyJSON

struct MapHelper {
    static func drawTour(_ tour: JSON, mapView: MGLMapView) {
        drawPath(from: tour["directions"], withColor: UI.BlueColor, mapView: mapView)

        tour["waypoints"].array?.forEach { waypoint in
            if let latitude = waypoint["latitude"].float, let longitude = waypoint["longitude"].float {
                let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                let annotation = MGLPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            }
        }
    }

    static func drawPath(from json: JSON, withColor color: UIColor, mapView: MGLMapView) {
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
                    mapView.addAnnotation(polyline)

                    identifier += 1
                }
            }
        }
    }

    static func setMapBounds(for tour: JSON, mapView: MGLMapView) {
        if
            let minLatitude = tour["waypoints"].array?.map({ $0["latitude"].floatValue }).min(),
            let minLongitude = tour["waypoints"].array?.map({ $0["longitude"].floatValue }).min(),
            let maxLatitude = tour["waypoints"].array?.map({ $0["latitude"].floatValue }).max(),
            let maxLongitude = tour["waypoints"].array?.map({ $0["longitude"].floatValue }).max()
        {
            let bounds = MGLCoordinateBounds(sw: CLLocationCoordinate2D(latitude: Double(minLatitude), longitude: Double(minLongitude)),
                                             ne: CLLocationCoordinate2D(latitude: Double(maxLatitude), longitude: Double(maxLongitude)))

            mapView.setVisibleCoordinateBounds(bounds, edgePadding: UIEdgeInsetsMake(30, 30, 30, 30), animated: true)
        }
    }
}
