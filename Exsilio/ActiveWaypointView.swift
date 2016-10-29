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
    var sticky: Bool = false
    var descriptionText: String?

    var speechSynthesizer: AVSpeechSynthesizer?
    var closeIcon = UI.XIcon.imageWithTint(UI.BarButtonColor)
    var volumeOnIcon = UIImage.fontAwesomeIcon(name: .volumeUp, textColor: UI.BarButtonColor, size: UI.BarButtonSize)
    var volumeOffIcon = UIImage.fontAwesomeIcon(name: .volumeOff, textColor: UI.BarButtonColor, size: UI.BarButtonSize)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.updateNavIconColor(UI.BarButtonColor)

        self.backButton?.imageView?.contentMode = .scaleAspectFill
        self.volumeButton?.imageView?.contentMode = .scaleAspectFill
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

    func updateNavIconColor(_ color: UIColor) {
        closeIcon = closeIcon.imageWithTint(color)
        volumeOnIcon = volumeOnIcon.imageWithTint(color)
        volumeOffIcon = volumeOffIcon.imageWithTint(color)

        self.backButton?.setImage(closeIcon, for: UIControlState())
        self.updateVolumeButtonImage()
    }

    func updateWaypoint(_ waypoint: JSON) {
        self.nameLabel?.text = waypoint["name"].string

        if let description = waypoint["description"].string {
            self.descriptionTextView?.text = description

            if UserDefaults.standard.bool(forKey: Settings.SpeechKey) {
                speak()
            } else {
                self.volumeButton?.isHidden = true
            }
        } else {
            self.descriptionTextView?.text = ""
        }

        if let imageURL = waypoint["image_url"].string , imageURL != API.MissingImagePath {
            self.imageViewHeight?.constant = self.frame.height / 2
            let urlRequest = URLRequest(url: URL(string: imageURL)!)
            CurrentTourSingleton.sharedInstance.imageDownloader.download(urlRequest) { response in
                if let image = response.result.value {
                    self.imageView?.image = image
                    self.updateNavIconColor(.white)
                }
            }
        } else {
            self.imageViewHeight?.constant = 0
            self.updateNavIconColor(UI.BarButtonColor)
        }

        self.layoutIfNeeded()
    }

    func speak() {
        if let text = self.descriptionTextView?.text {
            enableSound()
            self.speechSynthesizer = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.speechSynthesizer?.speak(utterance)
        }
    }

    func enableSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {

        }
    }

    func updateVolumeButtonImage() {
        if self.volume == true {
            self.volumeButton?.setImage(volumeOnIcon, for: .normal)
        } else {
            self.volumeButton?.setImage(volumeOffIcon, for: .normal)
        }
    }

    @IBAction func toggleVolume() {
        self.volume = !volume

        if self.volume == true {
            speak()
        } else {
            self.speechSynthesizer?.stopSpeaking(at: AVSpeechBoundary.immediate)
        }

        self.updateVolumeButtonImage()
    }

    @IBAction func dismiss() {
        self.sticky = false
        self.speechSynthesizer?.stopSpeaking(at: AVSpeechBoundary.immediate)
        self.delegate?.activeWaypointViewWillBeDismissed()
    }
}
