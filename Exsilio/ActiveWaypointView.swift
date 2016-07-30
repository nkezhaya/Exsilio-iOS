//
//  ActiveWaypointView.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 7/17/16.
//
//

import UIKit
import SwiftyJSON
import FontAwesome_swift
import AVFoundation

protocol ActiveWaypointViewDelegate {
    func activeWaypointViewWillBeDismissed()
}

class ActiveWaypointView: UIView {
    @IBOutlet var backButton: UIButton?
    @IBOutlet var volumeButton: UIButton?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var descriptionTextView: UITextView?
    @IBOutlet var imageViewHeight: NSLayoutConstraint?

    var delegate: ActiveWaypointViewDelegate?
    var volume: Bool = true
    var descriptionText: String?

    let speechSynthesizer = AVSpeechSynthesizer()
    let volumeOnIcon = UIImage.fontAwesomeIconWithName(.VolumeUp, textColor: UI.BarButtonColor, size: UI.BarButtonSize)
    let volumeOffIcon = UIImage.fontAwesomeIconWithName(.VolumeOff, textColor: UI.BarButtonColor, size: UI.BarButtonSize)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backButton?.setImage(UI.XIcon.imageWithTint(UI.BarButtonColor), forState: .Normal)
        self.volumeButton?.setImage(volumeOnIcon, forState: .Normal)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

    func updateWaypoint(waypoint: JSON) {
        self.nameLabel?.text = waypoint["name"].string

        if let description = waypoint["description"].string {
            self.descriptionTextView?.text = description

            if NSUserDefaults.standardUserDefaults().boolForKey(Settings.SpeechKey) {
                speak()
            } else {
                self.volumeButton?.hidden = true
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

    func speak() {
        if let text = self.descriptionTextView?.text {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.speechSynthesizer.speakUtterance(utterance)
        }
    }

    @IBAction func toggleVolume() {
        self.volume = !volume

        if self.volume == true {
            speak()
            self.volumeButton?.setImage(volumeOnIcon, forState: .Normal)
        } else {
            self.speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
            self.volumeButton?.setImage(volumeOffIcon, forState: .Normal)
        }
    }

    @IBAction func dismiss() {
        self.speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        self.delegate?.activeWaypointViewWillBeDismissed()
    }
}