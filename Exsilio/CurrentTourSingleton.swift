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
    var tourActive = false

    func newTour(_ name: String, description: String, successHandler: @escaping ((JSON) -> Void)) {
        self.tour = ["name": name, "description": description, "waypoints": []]
        self.waypoints = []

        let params = ["tour[name]": name, "tour[description]": description]

        Alamofire.request("\(API.URL)\(API.ToursPath)", method: .post, parameters: params, headers: API.authHeaders()).responseJSON { response in
            switch response.result {
            case .success(let jsonString):
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

    func loadTourFromJSON(_ tour: JSON?) {
        guard let tour = tour, let tourDict = tour.dictionaryObject else {
            return self.unloadTour()
        }

        self.tour = tourDict as Tour

        if let waypointsArray = tour["waypoints"].arrayObject {
            self.waypoints = waypointsArray as! [Waypoint]
        }
    }

    func unloadTour() {
        self.tour = [:]
        self.waypoints = []
    }

    func moveWaypointAtIndex(_ sourceIndex: Int, toIndex destinationIndex: Int, completion: (() -> Void)?) {
        let waypoint = self.waypoints[sourceIndex]
        self.waypoints.remove(at: sourceIndex)
        self.waypoints.insert(waypoint, at: destinationIndex)

        var waypointIdsInOrder: [Int] = []

        for waypoint in self.waypoints {
            waypointIdsInOrder.append(waypoint["id"] as! Int)
        }

        Alamofire.request("\(API.URL)\(API.ToursPath)/\(self.tour["id"]!)\(API.WaypointsPath)/reposition", method: .put, parameters: ["waypoints": waypointIdsInOrder], headers: API.authHeaders()).responseJSON { _ in
            completion?()
        }
    }

    func removeWaypointAtIndex(_ index: Int) {
        let id = self.waypoints[index]["id"] as! Int
        self.waypoints.remove(at: index)

        Alamofire.request("\(API.URL)\(API.ToursPath)/\(self.tour["id"]!)\(API.WaypointsPath)/\(id)", method: .delete, headers: API.authHeaders())
    }

    func refreshTour(_ completion: ((JSON?) -> Void)?) {
        Alamofire.request("\(API.URL)\(API.ToursPath)/\(self.tour["id"]!)", method: .get, headers: API.authHeaders()).responseJSON { response in
            switch (response.result) {
            case .success(let jsonResponse):
                let json = JSON(jsonResponse)
                self.tour = json.dictionaryObject! as Tour
                self.waypoints = json["waypoints"].arrayObject as! [Waypoint]

                completion?(json)
            default:
                completion?(nil)
            }
        }
    }

    func save(successHandler: @escaping (() -> Void)) {
        var urlRequest: URLRequest
        do {
            urlRequest = try URLRequest(url: "\(API.URL)\(API.ToursPath)",
                method: .post,
                headers: API.authHeaders())
        } catch { return; }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let tourName = self.tour["name"] as? String {
                    multipartFormData.append(tourName.data(using: String.Encoding.utf8)!, withName: "tour[name]")
                }

                if let tourDescription = self.tour["description"] as? String {
                    multipartFormData.append(tourDescription.data(using: String.Encoding.utf8)!, withName: "tour[description]")
                }

                var position = 0
                for waypoint in self.waypoints {
                    let waypointName = waypoint["name"] as! String
                    let latitude = waypoint["latitude"] as! Double
                    let longitude = waypoint["longitude"] as! Double
                    multipartFormData.append(waypointName.data(using: String.Encoding.utf8)!, withName: "tour[waypoints_attributes][][name]")
                    multipartFormData.append("\(position)".data(using: String.Encoding.utf8)!, withName: "tour[waypoints_attributes][][position]")
                    multipartFormData.append("\(latitude)".data(using: String.Encoding.utf8)!, withName: "tour[waypoints_attributes][][latitude]")
                    multipartFormData.append("\(longitude)".data(using: String.Encoding.utf8)!, withName: "tour[waypoints_attributes][][longitude]")

                    if let description = waypoint["description"] as? String {
                        multipartFormData.append(description.data(using: String.Encoding.utf8)!, withName: "tour[waypoints_attributes][][description]")
                    }

                    if let image = waypoint["photo"] as? UIImage {
                        multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "tour[waypoints_attributes][][image]", fileName: "image.png", mimeType: "image/png")
                    }

                    position += 1
                }
            },
            with: urlRequest,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let json):
                            if let errors = JSON(json)["errors"].string {
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
