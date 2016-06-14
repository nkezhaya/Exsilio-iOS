//
//  EXButton.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/11/16.
//
//

import UIKit
import FontAwesome_swift

class EXButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        modifyAesthetics()
    }

    func darkBorderStyle() {
        self.borderStyle(.blackColor())
    }

    func lightBorderStyle() {
        self.borderStyle(.whiteColor())
    }

    func borderStyle(color: UIColor) {
        self.layer.borderWidth = 2
        self.layer.borderColor = color.CGColor
        self.backgroundColor = UIColor.clearColor()
        self.tintColor = color
        self.updateText(titleLabel!.text!, withColor: color)
    }

    func modifyAesthetics() {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        self.layer.cornerRadius = 20

        if self.titleLabel?.text != nil {
            self.updateText(self.titleLabel!.text!, withColor: .whiteColor())
        }
    }

    func setIcon(icon: FontAwesome) {
        let icon = UIImage.fontAwesomeIconWithName(icon, textColor: self.tintColor, size: CGSizeMake(24, 24)).imageWithTint(self.tintColor)
        self.setImage(icon, forState: .Normal)
        self.setImage(icon, forState: .Highlighted)
    }

    func updateText(text: String, withColor color: UIColor?) {
        var attributes: [String: AnyObject] = [NSKernAttributeName: UI.LabelCharacterSpacing]

        if color != nil {
            attributes[NSForegroundColorAttributeName] = color!
            self.tintColor = color
        }

        let attributedText = NSAttributedString(string: text,
                                                attributes: attributes)

        self.setAttributedTitle(attributedText, forState: .Normal)
        self.setAttributedTitle(attributedText, forState: .Highlighted)
    }
}