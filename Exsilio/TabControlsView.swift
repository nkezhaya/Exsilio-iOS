//
//  TabControlsView.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/27/16.
//
//

import UIKit

enum TabState {
    case TourPreview
    case ActiveTour
}

protocol TabControlsDelegate {
    func willChangeTabState(state: TabState)
    func willMoveToNextStep()
    func willMoveToPreviousStep()
}

class TabControlsView: UIStackView {
    // Tour preview state
    let takeTourButton = UIButton()

    // Active tour state
    let cancelButton = UIButton()
    let backButton = UIButton()
    let forwardButton = UIButton()

    var delegate: TabControlsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.takeTourButton.backgroundColor = UI.GreenColor
        self.takeTourButton.setImage(UI.ForwardIcon, forState: .Normal)
        self.takeTourButton.addTarget(self, action: #selector(takeTourButtonTapped), forControlEvents: .TouchUpInside)

        self.cancelButton.backgroundColor = UIColor.whiteColor()
        self.cancelButton.setImage(UI.XIcon.imageWithTint(UI.RedColor), forState: .Normal)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), forControlEvents: .TouchUpInside)

        self.backButton.backgroundColor = UIColor.whiteColor()
        self.backButton.setImage(UI.BackIcon.imageWithTint(UI.BarButtonColor), forState: .Normal)
        self.backButton.addTarget(self, action: #selector(backButtonTapped), forControlEvents: .TouchUpInside)

        self.forwardButton.backgroundColor = UIColor.whiteColor()
        self.forwardButton.setImage(UI.ForwardIcon.imageWithTint(UI.BarButtonColor), forState: .Normal)
        self.forwardButton.addTarget(self, action: #selector(forwardButtonTapped), forControlEvents: .TouchUpInside)

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

    func updateStepIndex(index: Int, outOf: Int) {
        self.backButton.enabled = true
        self.forwardButton.enabled = true

        if index == 0 {
            self.backButton.enabled = false
        }

        if index == outOf {
            self.forwardButton.enabled = false
        }
    }
}