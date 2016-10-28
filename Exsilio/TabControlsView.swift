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
    case tourPreview
    case activeTour
}

protocol TabControlsDelegate {
    func willChangeTabState(_ state: TabState)
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
        self.takeTourButton.setImage(UI.ForwardIcon, for: UIControlState())
        self.takeTourButton.addTarget(self, action: #selector(takeTourButtonTapped), for: .touchUpInside)

        self.cancelButton.backgroundColor = UIColor.white
        self.cancelButton.setImage(UI.XIcon.imageWithTint(UI.RedColor), for: UIControlState())
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        // Disable the back button for the first load
        self.backButton.isEnabled = false
        self.backButton.backgroundColor = UIColor.white
        self.backButton.setImage(UI.BackIcon.imageWithTint(UI.BarButtonColor), for: UIControlState())
        self.backButton.setImage(UI.BackIcon.imageWithTint(UI.BarButtonColorDisabled), for: .disabled)
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        self.forwardButton.backgroundColor = UIColor.white
        self.forwardButton.setImage(UI.ForwardIcon.imageWithTint(UI.BarButtonColor), for: UIControlState())
        self.forwardButton.setImage(UI.ForwardIcon.imageWithTint(UI.BarButtonColorDisabled), for: .disabled)
        self.forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)

        let infoImage = UIImage.fontAwesomeIcon(name: .mapMarker, textColor: UI.BlueColor, size: UI.BarButtonSize)
        self.infoButton.backgroundColor = UIColor.white
        self.infoButton.setImage(infoImage.imageWithTint(UI.BarButtonColor), for: .normal)
        self.infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)

        self.setState(.tourPreview)
    }

    func setState(_ state: TabState) {
        self.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if state == .tourPreview {
            self.addArrangedSubview(self.takeTourButton)
        } else if state == .activeTour {
            self.addArrangedSubview(self.cancelButton)
            self.addArrangedSubview(self.backButton)
            self.addArrangedSubview(self.forwardButton)
            self.addArrangedSubview(self.infoButton)
        }
    }

    func takeTourButtonTapped() {
        self.setState(.activeTour)
        self.delegate?.willChangeTabState(.activeTour)
    }

    func cancelButtonTapped() {
        self.setState(.tourPreview)
        self.delegate?.willChangeTabState(.tourPreview)
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

    func updateStepIndex(_ index: Int, outOf: Int) {
        self.backButton.isEnabled = true
        self.forwardButton.isEnabled = true

        if index == 0 {
            self.backButton.isEnabled = false
        }

        if index + 1 >= outOf {
            self.forwardButton.isEnabled = false
        }
    }
}
