//
//  TourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/19/16.
//
//

import UIKit
import CoreLocation
import SwiftyJSON

class TourViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: GMSMapView?

    var locationManager = CLLocationManager()
    var tour: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .Plain, target: self, action: #selector(dismiss))
    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func openMap() {
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        mapVC.tour = self.tour!

        self.presentViewController(mapVC, animated: true, completion: nil)
    }
}