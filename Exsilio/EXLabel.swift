//
//  EXLabel.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/29/16.
//
//

import UIKit

class EXLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        modifyAesthetics()
    }

    func modifyAesthetics() {
        self.attributedText = NSAttributedString(string: (self.text)!,
                                                 attributes: [NSKernAttributeName: Constants.LabelCharacterSpacing])
    }
}