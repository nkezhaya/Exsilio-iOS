//
//  CurrentTourSingleton.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/5/16.
//
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class CurrentTourSingleton {
    static let sharedInstance = CurrentTourSingleton()

    var imageDownloader = ImageDownloader()

    var currentWaypointIndex = -1
    var tour: Tour = [:]
    var waypoints: [Waypoint] = []
    var editingExistingTour = false

    func newTour(name: String, description: String) {
        self.editingExistingTour = false
        self.tour = ["name": name, "description": description, "waypoints": []]
        self.waypoints = []
    }

    func editTour(tour: JSON) {
        if let tourDict = tour.dictionaryObject {
            self.tour = tourDict

            if let waypointsArray = tour["waypoints"].arrayObject {
                self.waypoints = waypointsArray as! [Waypoint]
            }
        } else {
            self.tour = [:]
            self.waypoints = []
        }

        self.editingExistingTour = true
        self.currentWaypointIndex = -1
    }

    func moveWaypointAtIndex(sourceIndex: Int, toIndex destinationIndex: Int, completion: (Void -> Void)?) {
        let waypoint = self.waypoints[sourceIndex]
        self.waypoints.removeAtIndex(sourceIndex)
        self.waypoints.insert(waypoint, atIndex: destinationIndex)

        var waypointIdsInOrder: [Int] = []

        for waypoint in self.waypoints {
            waypointIdsInOrder.append(waypoint["id"] as! Int)
        }

        Alamofire.request(.PUT, "\(API.URL)\(API.ToursPath)/\(self.tour["id"]!)\(API.WaypointsPath)/reposition", parameters: ["waypoints": waypointIdsInOrder], headers: API.authHeaders()).responseJSON { _ in
            completion?()
        }
    }

    func removeWaypointAtIndex(index: Int) {
        let id = self.waypoints[index]["id"] as! Int
        self.waypoints.removeAtIndex(index)

        Alamofire.request(.DELETE, "\(API.URL)\(API.ToursPath)/\(self.tour["id"]!)\(API.WaypointsPath)/\(id)", headers: API.authHeaders())
    }

    func refreshTour(completion: (Void -> Void)) {
        Alamofire.request(.GET, "\(API.URL)\(API.ToursPath)/\(self.tour["id"]!)", headers: API.authHeaders()).responseJSON { response in
            switch (response.result) {
            case .Success(let jsonResponse):
                let json = JSON(jsonResponse)
                self.tour = json.dictionaryObject!
                self.waypoints = json["waypoints"].arrayObject as! [Waypoint]

                completion()
                break
            default:
                break
            }
        }
    }

    func updateWaypoint(waypoint: Waypoint) {
        if let id = waypoint["id"] as? Int, tourId = waypoint["tour_id"] as? Int {
            Alamofire.upload(
                .PUT,
                "\(API.URL)\(API.ToursPath)/\(tourId)\(API.WaypointsPath)/\(id)",
                headers: API.authHeaders(),
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: waypoint["name"]!.dataUsingEncoding(NSUTF8StringEncoding)!, name: "waypoint[name]")
                    multipartFormData.appendBodyPart(data: "\(waypoint["latitude"]!)".dataUsingEncoding(NSUTF8StringEncoding)!, name: "waypoint[latitude]")
                    multipartFormData.appendBodyPart(data: "\(waypoint["longitude"]!)".dataUsingEncoding(NSUTF8StringEncoding)!, name: "waypoint[longitude]")

                    if let image = waypoint["photo"] as? UIImage {
                        multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(image)!, name: "waypoint[image]", fileName: "image.png", mimeType: "image/png")
                    }
                },
                encodingCompletion: { encodingResult in

                }
            )
        }
    }

    func saveWaypoint(waypoint: Waypoint) {
        if self.currentWaypointIndex == self.waypoints.count {
            self.waypoints.append(waypoint)
        } else {
            self.waypoints[self.currentWaypointIndex] = waypoint
        }
    }

    func save(successHandler successHandler: (Void -> Void), errorHandler: (String -> Void)) {
        Alamofire.upload(
            .POST,
            "\(API.URL)\(API.ToursPath)",
            headers: API.authHeaders(),
            multipartFormData: { multipartFormData in
                if let name = self.tour["name"] {
                    multipartFormData.appendBodyPart(data: name.dataUsingEncoding(NSUTF8StringEncoding)!, name: "tour[name]")
                }

                if let description = self.tour["description"] {
                    multipartFormData.appendBodyPart(data: description.dataUsingEncoding(NSUTF8StringEncoding)!, name: "tour[description]")
                }

                var position = 0
                for waypoint in self.waypoints {
                    multipartFormData.appendBodyPart(data: waypoint["name"]!.dataUsingEncoding(NSUTF8StringEncoding)!, name: "tour[waypoints_attributes][][name]")
                    multipartFormData.appendBodyPart(data: "\(position)".dataUsingEncoding(NSUTF8StringEncoding)!, name: "tour[waypoints_attributes][][position]")
                    multipartFormData.appendBodyPart(data: "\(waypoint["latitude"]!)".dataUsingEncoding(NSUTF8StringEncoding)!, name: "tour[waypoints_attributes][][latitude]")
                    multipartFormData.appendBodyPart(data: "\(waypoint["longitude"]!)".dataUsingEncoding(NSUTF8StringEncoding)!, name: "tour[waypoints_attributes][][longitude]")

                    if let image = waypoint["photo"] as? UIImage {
                        multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(image)!, name: "tour[waypoints_attributes][][image]", fileName: "image.png", mimeType: "image/png")
                    }

                    position += 1
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .Success(let json):
                            if let errors = json["errors"] as? String {
                                errorHandler(errors)
                            } else {
                                successHandler()
                            }

                            break
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            }
        )
    }
}