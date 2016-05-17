//
//  CurrentTourSingleton.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/5/16.
//
//

import Foundation
import Alamofire

class CurrentTourSingleton {
    static let sharedInstance = CurrentTourSingleton()

    var currentWaypointIndex = -1
    var tour: [String: AnyObject] = [:]
    var waypoints: [[String: AnyObject]] = []

    func newTour(name: String, description: String) {
        CurrentTourSingleton.sharedInstance.tour = ["name": name, "description": description, "waypoints": []]
        CurrentTourSingleton.sharedInstance.waypoints = []
    }

    func saveWaypoint(waypoint: [String: AnyObject]) {
        if self.currentWaypointIndex == self.waypoints.count {
            self.waypoints.append(waypoint)
        } else {
            self.waypoints[self.currentWaypointIndex] = waypoint
        }
    }

    func save() {
        var params: [String: AnyObject] = [
            "tour[name]": self.tour["name"]!,
            "tour[waypoints]": self.waypoints
        ]

        if let description = self.tour["description"] {
            params["tour[description]"] = description
        }

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

                    if let image = waypoint["photo"] as? UIImage {
                        multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(image)!, name: "tour[waypoints_attributes][][image]", fileName: "image.png", mimeType: "image/png")
                    }

                    position += 1
                }
            },
            encodingCompletion: { encodingResult in

            }
        )
    }
}