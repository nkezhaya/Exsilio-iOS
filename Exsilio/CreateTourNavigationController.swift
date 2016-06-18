//
//  CreateTourNavigationController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

import UIKit

class CreateTourNavigationController: UINavigationController {
    var toursTableViewController: ToursTableViewController?

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.toursTableViewController?.refresh()
    }
}