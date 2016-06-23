//
//  TourPreviewViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/19/16.
//
//

import UIKit
import CoreLocation
import SwiftyJSON

class TourPreviewViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var backgroundImageView: UIImageView?
    @IBOutlet var pageControl: UIPageControl?
    @IBOutlet var viewMapButton: EXButton?
    @IBOutlet var takeTourButton: EXButton?

    var locationManager = CLLocationManager()
    var tour: JSON?
    var imagesPresent = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .Plain, target: self, action: #selector(dismiss))

        if let tour = self.tour {
            self.nameLabel?.text = tour["name"].string

            let numberOfWaypoints = tour["waypoints"].array?.filter { $0["image_url"].string != API.MissingImagePath }.count

            self.pageControl?.numberOfPages = numberOfWaypoints == nil ? 0 : numberOfWaypoints!
        }

        self.viewMapButton?.lightBorderStyle()
        self.takeTourButton?.backgroundColor = UIColor(hexString: "#21C064")

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe))
        swipeLeft.direction = .Left

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe))
        swipeRight.direction = .Right

        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)

        self.cacheAllImages()
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

    func cacheAllImages() {
        self.tour?["waypoints"].array?.forEach({ waypoint in
            if let urlString = waypoint["image_url"].string {
                if urlString != API.MissingImagePath {
                    let urlRequest = NSURLRequest(URL: NSURL(string: urlString)!)
                    CurrentTourSingleton.sharedInstance.imageDownloader.downloadImage(URLRequest: urlRequest, completion: nil)
                    self.imagesPresent = true
                }
            }
        })
    }

    func updateBackgroundImageForPage() {
        if !self.imagesPresent {
            self.backgroundImageView?.image = UIImage(named: "LoginBackground")
            self.backgroundImageView?.alpha = 0.6
            return
        }

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