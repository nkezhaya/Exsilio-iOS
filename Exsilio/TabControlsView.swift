//
//  TabControlsView.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/27/16.
//
//

import UIKit
import FontAwesome_swift

enum TabState {
    case TourPreview
    case ActiveTour
}

protocol TabControlsDelegate {
    func willChangeTabState(state: TabState)
    func willMoveToNextStep()
    func willMoveToPreviousStep()
    func willDisplayWaypointInfo()
}

class TabControlsView: UIStackView {
    // Tour preview state
    let takeTourButton = UIButton()

    // Active tour state
    let cancelButton = UIButton()
    let backButton = UIButton()
    let forwardButton = UIButton()
    let infoButton = UIButton()

    var delegate: TabControlsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.takeTourButton.backgroundColor = UI.GreenColor
        self.takeTourButton.setImage(UI.ForwardIcon, forState: .Normal)
        self.takeTourButton.addTarget(self, action: #selector(takeTourButtonTapped), forControlEvents: .TouchUpInside)

        self.cancelButton.backgroundColor = UIColor.whiteColor()
        self.cancelButton.setImage(UI.XIcon.imageWithTint(UI.RedColor), forState: .Normal)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), forControlEvents: .TouchUpInside)

        // Disable the back button for the first load
        self.backButton.enabled = false
        self.backButton.backgroundColor = UIColor.whiteColor()
        self.backButton.setImage(UI.BackIcon.imageWithTint(UI.BarButtonColor), forState: .Normal)
        self.backButton.setImage(UI.BackIcon.imageWithTint(UI.BarButtonColorDisabled), forState: .Disabled)
        self.backButton.addTarget(self, action: #selector(backButtonTapped), forControlEvents: .TouchUpInside)

        self.forwardButton.backgroundColor = UIColor.whiteColor()
        self.forwardButton.setImage(UI.ForwardIcon.imageWithTint(UI.BarButtonColor), forState: .Normal)
        self.forwardButton.setImage(UI.ForwardIcon.imageWithTint(UI.BarButtonColorDisabled), forState: .Disabled)
        self.forwardButton.addTarget(self, action: #selector(forwardButtonTapped), forControlEvents: .TouchUpInside)

        let infoImage = UIImage.fontAwesomeIconWithName(.MapMarker, textColor: UI.BlueColor, size: UI.BarButtonSize)
        self.infoButton.backgroundColor = UIColor.whiteColor()
        self.infoButton.setImage(infoImage.imageWithTint(UI.BarButtonColor), forState: .Normal)
        self.infoButton.addTarget(self, action: #selector(infoButtonTapped), forControlEvents: .TouchUpInside)

        self.setState(.TourPreview)
    }

    func setState(state: TabState) {
        self.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if state == .TourPreview {
            self.addArrangedSubview(self.takeTourButton)
        } else if state == .ActiveTour {
            self.addArrangedSubview(self.cancelButton)
            self.addArrangedSubview(self.backButton)
            self.addArrangedSubview(self.forwardButton)
            self.addArrangedSubview(self.infoButton)
        }
    }

    func takeTourButtonTapped() {
        self.setState(.ActiveTour)
        self.delegate?.willChangeTabState(.ActiveTour)
    }

    func cancelButtonTapped() {
        self.setState(.TourPreview)
        self.delegate?.willChangeTabState(.TourPreview)
    }

    func backButtonTapped() {
        self.delegate?.willMoveToPreviousStep()
    }

    func forwardButtonTapped() {
        self.delegate?.willMoveToNextStep()
    }

    func infoButtonTapped() {
        self.delegate?.willDisplayWaypointInfo()
    }

    func updateStepIndex(index: Int, outOf: Int) {
        self.backButton.enabled = true
        self.forwardButton.enabled = true

        if index == 0 {
            self.backButton.enabled = false
        }

        if index + 1 >= outOf {
            self.forwardButton.enabled = false
        }
    }
}