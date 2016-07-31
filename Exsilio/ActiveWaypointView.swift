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
import ImageViewer

protocol ActiveWaypointViewDelegate {
    func activeWaypointViewWillBeDismissed()
    func willPresentImageViewer(imageViewer: ImageViewer)
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

    let speechSynthesizer = AVSpeechSynthesizer()
    var closeIcon = UI.XIcon.imageWithTint(UI.BarButtonColor)
    var volumeOnIcon = UIImage.fontAwesomeIconWithName(.VolumeUp, textColor: UI.BarButtonColor, size: UI.BarButtonSize)
    var volumeOffIcon = UIImage.fontAwesomeIconWithName(.VolumeOff, textColor: UI.BarButtonColor, size: UI.BarButtonSize)

    override func awakeFromNib() {
        super.awakeFromNib()

        self.updateNavIconColor(UI.BarButtonColor)

        self.backButton?.imageView?.contentMode = .ScaleAspectFill
        self.volumeButton?.imageView?.contentMode = .ScaleAspectFill

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapRecognizer.numberOfTapsRequired = 1
        self.imageView?.addGestureRecognizer(tapRecognizer)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

    func updateNavIconColor(color: UIColor) {
        closeIcon = closeIcon.imageWithTint(color)
        volumeOnIcon = volumeOnIcon.imageWithTint(color)
        volumeOffIcon = volumeOffIcon.imageWithTint(color)

        self.backButton?.setImage(closeIcon, forState: .Normal)
        self.updateVolumeButtonImage()
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
                    self.updateNavIconColor(.whiteColor())
                }
            })
        } else {
            self.imageViewHeight?.constant = 0
            self.updateNavIconColor(UI.BarButtonColor)
        }

        self.layoutIfNeeded()
    }

    func speak() {
        if let text = self.descriptionTextView?.text {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.speechSynthesizer.speakUtterance(utterance)
        }
    }

    func imageTapped() {
        let imageProvider = SomeImageProvider()
        imageProvider.image = self.imageView!.image

        let closeButton = UI.XIcon.imageWithTint(.whiteColor())
        let buttonAssets = CloseButtonAssets(normal: closeButton, highlighted: closeButton)
        let configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets)
        let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, displacedView: self.imageView!)

        self.delegate?.willPresentImageViewer(imageViewer)
    }

    func updateVolumeButtonImage() {
        if self.volume == true {
            self.volumeButton?.setImage(volumeOnIcon, forState: .Normal)
        } else {
            self.volumeButton?.setImage(volumeOffIcon, forState: .Normal)
        }
    }

    @IBAction func toggleVolume() {
        self.volume = !volume

        if self.volume == true {
            speak()
        } else {
            self.speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        }

        self.updateVolumeButtonImage()
    }

    @IBAction func dismiss() {
        self.sticky = false
        self.speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        self.delegate?.activeWaypointViewWillBeDismissed()
    }
}

class SomeImageProvider: ImageProvider {
    var image: UIImage!

    func provideImage(completion: UIImage? -> Void) {
        completion(image)
    }

    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        completion(image)
    }
}