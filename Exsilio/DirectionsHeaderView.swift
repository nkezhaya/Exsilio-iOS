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
    
    var activeTourViewController: ActiveTourViewController?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tour = CurrentTourSingleton.sharedInstance.tour
        self.header?.text = tour["name"] as? String
    }

    @IBAction func dismiss() {
        self.activeTourViewController?.dismiss()
    }
}