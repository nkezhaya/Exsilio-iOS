//
//  WaypointPreviewViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/8/18.
//

import UIKit

final class WaypointPreviewViewController: UIViewController {
    @IBOutlet private weak var descriptionLabel: UILabel!

    var waypointDescription: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if waypointDescription == nil || waypointDescription?.isEmpty == true {
            descriptionLabel.text = "No description available."
        } else {
            descriptionLabel.text = waypointDescription
        }
    }
}
