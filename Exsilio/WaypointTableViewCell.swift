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

        self.pinImageView?.image = UIImage.fontAwesomeIcon(name: .mapPin, textColor: UIColor(hexString: "#333333"), size: CGSize(width: 64, height: 64))
    }

    func updateWithWaypoint(_ waypoint: Waypoint) {
        self.waypoint = waypoint

        self.nameLabel?.text = waypoint["name"] as? String

        if let address = waypoint["address"] as? String {
            self.descriptionLabel?.text = address
        } else {
            self.descriptionLabel?.text = "Address not available yet."
        }

        if let imageURL = waypoint["image_url"] as? String {
            let urlRequest = URLRequest(url: URL(string: imageURL)!)
            CurrentTourSingleton.sharedInstance.imageDownloader.download(urlRequest) { response in
                if let image = response.result.value {
                    self.photoImageView?.image = image.af_imageRoundedIntoCircle()
                }
            }
        }
    }
}
