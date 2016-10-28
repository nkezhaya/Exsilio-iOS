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

    func dismissAndEditTour(_ tour: JSON) {
        self.toursTableViewController?.refresh()

        self.dismiss(animated: true, completion: {
            CurrentTourSingleton.sharedInstance.loadTourFromJSON(tour)
            let waypointsTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "WaypointsTableViewController")
            self.toursTableViewController?.navigationController?.pushViewController(waypointsTableViewController, animated: true)
        })
    }
}
