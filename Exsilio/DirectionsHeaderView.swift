//
//  DirectionsHeaderView.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/25/16.
//
//

import UIKit

class DirectionsHeaderView: UIView {
    @IBOutlet var backButton: UIButton?
    @IBOutlet var header: UILabel?
    @IBOutlet var subheader: UILabel?
    
    var activeTourViewController: ActiveTourViewController?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tour = CurrentTourSingleton.sharedInstance.tour
        self.header?.text = tour["name"] as? String

        let fontSize = CGFloat(18)

        let description = NSMutableAttributedString()
        description.appendAttributedString(NSAttributedString(
            string: String.fontAwesomeIconWithName(.ClockO),
            attributes: [
                NSFontAttributeName: UIFont.fontAwesomeOfSize(fontSize)
            ]))
        description.appendAttributedString(NSAttributedString(string: " "))

        description.appendAttributedString(NSAttributedString(
            string: tour["duration"] as! String,
            attributes: [
                NSFontAttributeName: UIFont(name: "OpenSans-Light", size: fontSize)!
            ]))

        description.appendAttributedString(NSAttributedString(string: "\n"))

        description.appendAttributedString(NSAttributedString(
            string: String.fontAwesomeIconWithName(.MapMarker),
            attributes: [
                NSFontAttributeName: UIFont.fontAwesomeOfSize(fontSize)
            ]))
        description.appendAttributedString(NSAttributedString(string: " "))

        description.appendAttributedString(NSAttributedString(
            string: "\(tour["waypoints_count"]!) waypoints",
            attributes: [
                NSFontAttributeName: UIFont(name: "OpenSans-Light", size: fontSize)!
            ]))

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.lineBreakMode = .ByWordWrapping

        description.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSRangeFromString(description.string))

        self.subheader?.attributedText = description
    }

    @IBAction func dismiss() {
        self.activeTourViewController?.dismiss()
    }
}