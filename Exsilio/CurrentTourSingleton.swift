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
import SCLAlertView

class CurrentTourSingleton {
    static let sharedInstance = CurrentTourSingleton()

    var imageDownloader = ImageDownloader()
    var tour: Tour = [:]
    var waypoints: [Waypoint] = []

    func newTour(name: String, description: String, successHandler: (JSON -> Void)) {
        self.tour = ["name": name, "description": description, "waypoints": []]
        self.waypoints = []

        let params = ["tour[name]": name, "tour[description]": description]

        Alamofire.request(.POST, "\(API.URL)\(API.ToursPath)", parameters: params, headers: API.authHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let jsonString):
                let json = JSON(jsonString)
                if let errors = json["errors"].string {
                    SCLAlertView().showError("Whoops!", subTitle: errors, closeButtonTitle: "OK")
                } else {
                    successHandler(json)
                }
                break
            default:
                break
            }
        }
    }

    func loadTourFromJSON(tour: JSON?) {
        guard let tour = tour, let tourDict = tour.dictionaryObject else {
            return self.unloadTour()
        }

        self.tour = tourDict

        if let waypointsArray = tour["waypoints"].arrayObject {
            self.waypoints = waypointsArray as! [Waypoint]
        }
    }

    func unloadTour() {
        self.tour = [:]
        self.waypoints = []
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

    func save(successHandler successHandler: (Void -> Void)) {
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
                                SCLAlertView().showError("Whoops!", subTitle: errors, closeButtonTitle: "OK")
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