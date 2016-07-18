//
//  ActiveWaypointView.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 7/17/16.
//
//

import UIKit
import SwiftyJSON

protocol ActiveWaypointViewDelegate {
    func activeWaypointViewWillBeDismissed()
}

class ActiveWaypointView: UIView {
    @IBOutlet var backButton: UIButton?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var descriptionTextView: UITextView?

    var delegate: ActiveWaypointViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backButton?.setImage(UI.XIcon.imageWithTint(.whiteColor()), forState: .Normal)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

    func updateWaypoint(waypoint: JSON) {
        self.nameLabel?.text = waypoint["name"].string
        self.descriptionTextView?.text = waypoint["description"].string

        if let imageURL = waypoint["image_url"].string {
            let urlRequest = NSURLRequest(URL: NSURL(string: imageURL)!)
            CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                if let image = response.result.value {
                    self.imageView?.image = image
                }
            })
        }
    }

    func imageTapped() {
        // TODO
    }

    @IBAction func dismiss() {
        self.delegate?.activeWaypointViewWillBeDismissed()
    }
}