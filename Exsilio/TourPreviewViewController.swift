//
//  TourPreviewViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/19/16.
//
//

import UIKit
import SwiftyJSON

final class TourPreviewViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var takeTourButton: EXButton!

    var tour: JSON?
    var imagesPresent = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .plain, target: self, action: #selector(dismissModal))

        if let tour = tour {
            nameLabel.text = tour["name"].string

            let numberOfWaypoints = tour["waypoints"].array?.filter { $0["image_url"].string != API.MissingImagePath }.count

            pageControl.numberOfPages = numberOfWaypoints == nil ? 0 : numberOfWaypoints!
        }

        takeTourButton.backgroundColor = UIColor(hexString: "#21C064")

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe))
        swipeLeft.direction = .left

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe))
        swipeRight.direction = .right

        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)

        cacheAllImages()
        updateBackgroundImageForPage()
    }

    func leftSwipe() {
        let currentPage = pageControl.currentPage

        if currentPage == pageControl.numberOfPages - 1 {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage += 1
        }

        updateBackgroundImageForPage()
    }

    func rightSwipe() {
        let currentPage = pageControl.currentPage

        if currentPage == 0 {
            pageControl.currentPage = pageControl.numberOfPages - 1
        } else {
            pageControl.currentPage -= 1
        }

        updateBackgroundImageForPage()
    }

    func cacheAllImages() {
        tour?["waypoints"].array?.forEach({ waypoint in
            if let urlString = waypoint["image_url"].string {
                if urlString != API.MissingImagePath {
                    let urlRequest = URLRequest(url: URL(string: urlString)!)
                    CurrentTourSingleton.sharedInstance.imageDownloader.download(urlRequest, completion: nil)
                    
                    self.imagesPresent = true
                }
            }
        })
    }

    func updateBackgroundImageForPage() {
        if !imagesPresent {
            backgroundImageView?.image = UIImage(named: "LoginBackground")
            backgroundImageView?.alpha = 0.6
            return
        }

        if let currentPage = self.pageControl?.currentPage, let imageURL = self.tour?["waypoints"][currentPage]["image_url"].string {
            let duration = 0.2
            let urlRequest = URLRequest(url: URL(string: imageURL)!)

            UIView.animate(withDuration: duration, animations: {
                self.backgroundImageView?.alpha = 0.0
            }, completion: { _ in
                CurrentTourSingleton.sharedInstance.imageDownloader.download(urlRequest) { response in
                    if let image = response.result.value {
                        self.backgroundImageView?.image = image

                        UIView.animate(withDuration: duration, animations: {
                            self.backgroundImageView?.alpha = 0.75
                        })
                    }
                }
            })
        }
    }

    func dismissModal() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func takeTour() {
        CurrentTourSingleton.sharedInstance.loadTourFromJSON(self.tour)
        let vc = storyboard?.instantiateViewController(withIdentifier: "ActiveTourViewController") as! ActiveTourViewController
        present(vc, animated: true, completion: nil)
    }
}
