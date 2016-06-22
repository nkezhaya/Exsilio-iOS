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

    let mapMarkerImage = UIImage.fontAwesomeIconWithName(.MapMarker, textColor: UIColor(hexString: "#333333"), size: CGSizeMake(64, 64))
    let lockImage = UIImage.fontAwesomeIconWithName(.Lock, textColor: UIColor(hexString: "#333333"), size: CGSizeMake(64, 64))

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView!.backgroundColor = .whiteColor()
    }

    func addUtilityButtons() {
        if self.rightUtilityButtons != nil && !self.rightUtilityButtons.isEmpty {
            return
        }

        let tourPublished = self.tourJSON?["published"].bool == true

        let buttons = NSMutableArray()
        buttons.sw_addUtilityButtonWithColor(UI.BlueColor, icon: UIImage.fontAwesomeIconWithName(.Edit, textColor: .whiteColor(), size: CGSizeMake(30, 30)))
        buttons.sw_addUtilityButtonWithColor(UI.GreenColor, icon: UIImage.fontAwesomeIconWithName(tourPublished ? .Lock : .UnlockAlt, textColor: .whiteColor(), size: CGSizeMake(30, 30)))
        buttons.sw_addUtilityButtonWithColor(UI.RedColor, icon: UIImage.fontAwesomeIconWithName(.Trash, textColor: .whiteColor(), size: CGSizeMake(30, 30)))

        self.rightUtilityButtons = buttons as [AnyObject]
    }

    func resetUtilityButtons() {
        self.rightUtilityButtons = []
        self.addUtilityButtons()
    }

    func updateWithTour(tour: JSON) {
        self.tourJSON = tour
        self.nameLabel!.text = tour["name"].string

        if tour["published"].bool == true {
            self.descriptionLabel!.text = "\(tour["city_state"].string!) • \(tour["waypoints"].count) Stops • \(tour["duration"].string!)"
            self.pinImage?.image = mapMarkerImage
        } else {
            self.descriptionLabel!.text = "Draft: \(tour["city_state"].string!)"
            self.pinImage?.image = lockImage
        }


        if let imageURL = tour["user"]["picture_url"].string {
            let urlRequest = NSURLRequest(URL: NSURL(string: imageURL)!)
            CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                if let image = response.result.value {
                    self.userImage?.image = image.af_imageRoundedIntoCircle()
                }
            })
        }
    }
}