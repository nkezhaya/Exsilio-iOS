//
//  TourTableViewCell.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/18/16.
//
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import SWTableViewCell

class TourTableViewCell: SWTableViewCell {
    var tourJSON: JSON?

    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var pinImage: UIImageView?
    @IBOutlet var userImage: UIImageView?

    override func awakeFromNib() {
        self.pinImage?.image = UIImage.fontAwesomeIconWithName(.MapMarker, textColor: UIColor(hexString: "#333333"), size: CGSizeMake(64, 64))

        let buttons = NSMutableArray()
        buttons.sw_addUtilityButtonWithColor(UIColor(hexString: "#1c56ff"), icon: UIImage.fontAwesomeIconWithName(.Edit, textColor: .whiteColor(), size: CGSizeMake(30, 30)))
        buttons.sw_addUtilityButtonWithColor(UIColor(hexString: "#e04940"), icon: UIImage.fontAwesomeIconWithName(.Trash, textColor: .whiteColor(), size: CGSizeMake(30, 30)))

        self.rightUtilityButtons = buttons as [AnyObject]
    }

    func updateWithTour(tour: JSON) {
        self.tourJSON = tour
        self.nameLabel!.text = tour["name"].string
        self.descriptionLabel!.text = "Austin, TX • \(tour["waypoints"].count) Stops • \(tour["duration"].string!)"

        if let imageURL = tour["user"]["picture_url"].string {
            Alamofire.request(.GET, "\(API.URL)\(imageURL)").responseImage { response in
                if let image = response.result.value {
                    self.userImage?.image = image.af_imageRoundedIntoCircle()
                }
            }
        }
    }
}