//
//  ExpandedTourTableViewCell.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/6/16.
//
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import SWTableViewCell
import FontAwesome_swift

class ExpandedTourTableViewCell: UITableViewCell {
    var tourJSON: JSON?

    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var waypointsLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var durationLabel: UILabel?
    @IBOutlet var backgroundImage: UIImageView?
    @IBOutlet var userImage: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView!.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)

        self.distanceLabel!.layer.masksToBounds = true
        self.distanceLabel!.layer.cornerRadius = 4.0

        self.waypointsLabel!.layer.masksToBounds = true
        self.waypointsLabel!.layer.cornerRadius = 4.0

        self.backgroundImage!.alpha = 0.8
    }

    func updateWithTour(tour: JSON) {
        self.tourJSON = tour

        // Name, distance
        self.distanceLabel!.text = tour["distance"].string

        if let name = tour["name"].string {
            self.nameLabel!.attributedText = NSAttributedString(string: name,
                                                                attributes: [
                                                                    NSForegroundColorAttributeName: UIColor.whiteColor(),
                                                                    NSKernAttributeName: UI.LabelCharacterSpacing,
                                                                    NSFontAttributeName: UIFont(name: "OpenSans-Light", size: 18.0)!
                                                                    ])
        }

        // Duration
        let duration = "\(String.fontAwesomeIconWithName(.ClockO)) "
        let mutableAttributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: duration,
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont.fontAwesomeOfSize(17.0)
            ]))

        mutableAttributedString.appendAttributedString(NSAttributedString(string: tour["duration_short"].string!,
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont(name: "OpenSans", size: 17.0)!
            ]))

        self.durationLabel!.attributedText = mutableAttributedString

        // Waypoints
        let pin = "\(String.fontAwesomeIconWithName(.MapMarker)) "
        let pinMutableAttributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: pin,
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont.fontAwesomeOfSize(17.0)
            ]))

        pinMutableAttributedString.appendAttributedString(NSAttributedString(string: "\(tour["waypoints"].count)",
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont(name: "OpenSans", size: 17.0)!
            ]))

        self.waypointsLabel!.attributedText = pinMutableAttributedString
        self.waypointsLabel!.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)

        // Background image
        if let backgroundImageURL = tour["display_image_url"].string {
            let urlRequest = NSURLRequest(URL: NSURL(string: backgroundImageURL)!)
            CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                if let image = response.result.value {
                    self.backgroundImage?.image = image
                }
            })
        }

        // User image
        if let userImageURL = tour["user"]["picture_url"].string {
            let urlRequest = NSURLRequest(URL: NSURL(string: userImageURL)!)
            CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                if let image = response.result.value {
                    self.userImage?.image = image.af_imageRoundedIntoCircle()
                    self.userImage!.layer.cornerRadius = self.userImage!.frame.width / 2
                    self.userImage!.layer.borderWidth = 2
                    self.userImage!.layer.borderColor = UIColor.whiteColor().CGColor
                    self.userImage!.layer.masksToBounds = true
                }
            })
        }
    }
}