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
    @IBOutlet var backgroundImageView: UIImageView?
    @IBOutlet var viewMapButton: EXButton?

    var locationManager = CLLocationManager()
    var tour: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .Plain, target: self, action: #selector(dismiss))

        if let tour = self.tour {
            if let backgroundImageURL = tour["display_image_url"].string {
                let urlRequest = NSURLRequest(URL: NSURL(string: backgroundImageURL)!)
                CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                    if let image = response.result.value {
                        self.backgroundImageView?.image = image
                    }
                })
            }
        }

        self.viewMapButton?.lightBorderStyle()
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