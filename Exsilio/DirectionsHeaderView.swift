//
//  DirectionsHeaderView.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/25/16.
//
//

import UIKit
import SwiftyJSON

protocol DirectionsHeaderDelegate {
    func willDismissFromHeader()
}

class DirectionsHeaderView: UIView {
    @IBOutlet var backButton: UIButton?
    @IBOutlet var header: UILabel?
    @IBOutlet var subheader: UILabel?
    
    var delegate: DirectionsHeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tour = CurrentTourSingleton.sharedInstance.tour
        self.header?.text = tour["name"] as? String

        let fontSize = CGFloat(18)
        let description = NSMutableAttributedString()
        description.append(NSAttributedString(
            string: String.fontAwesomeIcon(name: .clockO),
            attributes: [
                NSFontAttributeName: UIFont.fontAwesome(ofSize: fontSize)
            ]))
        description.append(NSAttributedString(string: " "))

        description.append(NSAttributedString(
            string: tour["duration"] as! String,
            attributes: [
                NSFontAttributeName: UIFont(name: "OpenSans-Light", size: fontSize)!
            ]))

        description.append(NSAttributedString(string: "\n"))

        description.append(NSAttributedString(
            string: String.fontAwesomeIcon(name: .mapMarker),
            attributes: [
                NSFontAttributeName: UIFont.fontAwesome(ofSize: fontSize)
            ]))
        description.append(NSAttributedString(string: " "))

        description.append(NSAttributedString(
            string: "\(tour["waypoints_count"]!) waypoints",
            attributes: [
                NSFontAttributeName: UIFont(name: "OpenSans-Light", size: fontSize)!
            ]))

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 5
        paragraph.lineBreakMode = .byWordWrapping

        description.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSRange(location: 0, length: description.string.characters.count))

        self.subheader?.attributedText = description
    }

    func updateStep(_ step: JSON) {
        if let distance = step["distance"]["text"].string {
            self.header?.text = distance
        }

        if let htmlInstructions = step["html_instructions"].string {
            guard let regex = try? NSRegularExpression(pattern: "<.*?>", options: .caseInsensitive) else {
                return
            }

            let range = NSMakeRange(0, htmlInstructions.characters.count)
            let instructions = regex.stringByReplacingMatches(in: htmlInstructions, options: NSRegularExpression.MatchingOptions(), range: range, withTemplate: "")

            self.subheader?.text = instructions
        }
    }

    @IBAction func dismiss() {
        self.delegate?.willDismissFromHeader()
    }
}
