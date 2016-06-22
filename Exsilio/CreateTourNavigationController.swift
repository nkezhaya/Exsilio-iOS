//
//  CreateTourNavigationController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

import UIKit
import SwiftyJSON

class CreateTourNavigationController: UINavigationController {
    var toursTableViewController: ToursTableViewController?

    func dismissAndEditTour(tour: JSON) {
        self.toursTableViewController?.refresh()

        self.dismissViewControllerAnimated(true, completion: {
            CurrentTourSingleton.sharedInstance.editTour(tour)
            let waypointsTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WaypointsTableViewController")
            self.toursTableViewController?.navigationController?.pushViewController(waypointsTableViewController, animated: true)
        })
    }
}