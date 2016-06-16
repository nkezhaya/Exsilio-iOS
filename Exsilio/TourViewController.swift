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
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var backgroundImageView: UIImageView?
    @IBOutlet var pageControl: UIPageControl?
    @IBOutlet var viewMapButton: EXButton?
    @IBOutlet var takeTourButton: EXButton?

    var locationManager = CLLocationManager()
    var tour: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .Plain, target: self, action: #selector(dismiss))

        if let tour = self.tour {
            self.nameLabel?.text = tour["name"].string

            if let numberOfWaypoints = tour["waypoints_count"].int {
                self.pageControl?.numberOfPages = numberOfWaypoints
            }
        }

        self.viewMapButton?.lightBorderStyle()
        self.takeTourButton?.backgroundColor = UIColor(hexString: "#21C064")

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe))
        swipeLeft.direction = .Left

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe))
        swipeRight.direction = .Right

        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)

        self.updateBackgroundImageForPage()
    }

    func leftSwipe() {
        if let pageControl = self.pageControl {
            let currentPage = pageControl.currentPage

            if currentPage == pageControl.numberOfPages - 1 {
                pageControl.currentPage = 0
            } else {
                pageControl.currentPage += 1
            }
        }

        self.updateBackgroundImageForPage()
    }

    func rightSwipe() {
        if let pageControl = self.pageControl {
            let currentPage = pageControl.currentPage

            if currentPage == 0 {
                pageControl.currentPage = pageControl.numberOfPages - 1
            } else {
                pageControl.currentPage -= 1
            }
        }

        self.updateBackgroundImageForPage()
    }

    func updateBackgroundImageForPage() {
        if let currentPage = self.pageControl?.currentPage {
            if let imageURL = self.tour?["waypoints"][currentPage]["image_url"].string {
                let duration = 0.2
                let urlRequest = NSURLRequest(URL: NSURL(string: imageURL)!)

                UIView.animateWithDuration(duration, animations: {
                    self.backgroundImageView?.alpha = 0.0
                }, completion: { _ in
                    CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: { response in
                        if let image = response.result.value {
                            self.backgroundImageView?.image = image

                            UIView.animateWithDuration(duration, animations: {
                                self.backgroundImageView?.alpha = 0.75
                            })
                        }
                    })
                })
            }
        }
    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func openMap() {
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        mapVC.tour = self.tour!

        self.presentViewController(mapVC, animated: true, completion: nil)
    }

    @IBAction func takeTour() {
        
    }
}