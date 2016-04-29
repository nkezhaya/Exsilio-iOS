//
//  EXButton.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/11/16.
//
//

import UIKit

class EXButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        modifyAesthetics()
    }

    func modifyAesthetics() {
        layer.cornerRadius = 20
        titleLabel?.attributedText = NSAttributedString(string: (titleLabel?.text)!,
                                                        attributes: [NSKernAttributeName: Constants.LabelCharacterSpacing])
    }
}