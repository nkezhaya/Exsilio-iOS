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
        self.borderStyle(.black())
    }

    func lightBorderStyle() {
        self.borderStyle(.white())
    }

    func borderStyle(_ color: UIColor) {
        self.layer.borderWidth = 2
        self.layer.borderColor = color.cgColor
        self.backgroundColor = UIColor.clear
        self.tintColor = color
        self.updateText(titleLabel!.text!, withColor: color)
    }

    func modifyAesthetics() {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        self.layer.cornerRadius = 20

        if self.titleLabel?.text != nil {
            self.updateText(self.titleLabel!.text!, withColor: .white())
        }
    }

    func setIcon(_ icon: FontAwesome) {
        let icon = UIImage.fontAwesomeIconWithName(icon, textColor: self.tintColor, size: CGSize(width: 24, height: 24)).imageWithTint(self.tintColor)
        self.setImage(icon, forState: .Normal)
        self.setImage(icon, forState: .Highlighted)
    }

    func updateText(_ text: String, withColor color: UIColor?) {
        var attributes: [String: AnyObject] = [NSKernAttributeName: UI.LabelCharacterSpacing as AnyObject]

        if color != nil {
            attributes[NSForegroundColorAttributeName] = color!
            self.tintColor = color
        }

        let attributedText = NSAttributedString(string: text,
                                                attributes: attributes)

        self.setAttributedTitle(attributedText, for: UIControlState())
        self.setAttributedTitle(attributedText, for: .highlighted)
    }
}
