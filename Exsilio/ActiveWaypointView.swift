//
//  ActiveWaypointView.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 7/17/16.
//
//

import UIKit
import SwiftyJSON
import AVFoundation

protocol ActiveWaypointViewDelegate {
    func activeWaypointViewWillBeDismissed()
}

class ActiveWaypointView: UIView {
    @IBOutlet var backButton: UIButton?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var descriptionTextView: UITextView?
    @IBOutlet var imageViewHeight: NSLayoutConstraint?

    var delegate: ActiveWaypointViewDelegate?

    let speechSynthesizer = AVSpeechSynthesizer()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backButton?.setImage(UI.XIcon.imageWithTint(UI.BarButtonColor), forState: .Normal)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

    func updateWaypoint(waypoint: JSON) {
        self.nameLabel?.text = waypoint["name"].string

        if let description = waypoint["description"].string {
            self.descriptionTextView?.text = description

            if NSUserDefaults.standardUserDefaults().boolForKey(Settings.SpeechKey) {
                let utterance = AVSpeechUtterance(string: description)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                self.speechSynthesizer.speakUtterance(utterance)
            }
        } else {
          self.descriptionTextView?.text = ""
      }

        if let imageURL = waypoint["image_url"].string where imageURL != API.MissingImagePath {
            self.imageViewHeight?.constant = self.frame.height / 2
            let urlRequest = NSURLRequest(URL: NSURL(string: imageURL)!)
            CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                if let image = response.result.value {
                    self.imageView?.image = image
                }
            })
        } else {
            self.imageViewHeight?.constant = 0
        }

        self.layoutIfNeeded()
    }

    func imageTapped() {
        // TODO
    }

    @IBAction func dismiss() {
        self.speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        self.delegate?.activeWaypointViewWillBeDismissed()
    }
}