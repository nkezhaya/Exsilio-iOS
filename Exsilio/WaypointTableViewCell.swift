//
//  WaypointTableViewCell.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/26/16.
//
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class WaypointTableViewCell: UITableViewCell {
    var waypoint: Waypoint?

    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var photoImageView: UIImageView?
    @IBOutlet var pinImageView: UIImageView?
    @IBOutlet var descriptionLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.pinImageView?.image = UIImage.fontAwesomeIconWithName(.MapPin, textColor: UIColor(hexString: "#333333"), size: CGSizeMake(64, 64))
    }

    func updateWithWaypoint(waypoint: Waypoint) {
        self.waypoint = waypoint

        self.nameLabel?.text = waypoint["name"] as? String
        self.descriptionLabel?.text = "\(waypoint["address"]!)"

        if let imageURL = waypoint["image_url"] as? String {
            let urlRequest = NSURLRequest(URL: NSURL(string: "\(API.URL)\(imageURL)")!)
            CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                if let image = response.result.value {
                    self.photoImageView?.image = image.af_imageRoundedIntoCircle()
                }
            })
        }
    }
}