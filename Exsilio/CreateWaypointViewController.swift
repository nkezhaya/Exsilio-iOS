//
//  CreateWaypointViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/29/16.
//
//

import UIKit
import Fusuma
import SCLAlertView

class CreateWaypointViewController: UIViewController, FusumaDelegate, GMSMapViewDelegate {
    @IBOutlet var coordsLabel: UILabel?
    @IBOutlet var photo: UIImageView?

    override func viewDidLoad() {
        CurrentTourSingleton.sharedInstance.currentWaypointIndex += 1
        
        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        let forwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: #selector(next))

        self.title = "Waypoint \(CurrentTourSingleton.sharedInstance.currentWaypointIndex + 1)"
    }

    func dismiss() {
        CurrentTourSingleton.sharedInstance.currentWaypointIndex -= 1
        self.navigationController?.popViewControllerAnimated(true)
    }

    func next() {
        let alertVC = UIAlertController(title: "Title", message: "Message", preferredStyle: .ActionSheet)
        alertVC.addAction(UIAlertAction(title: "New Waypoint", style: .Default, handler: { _ in
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateWaypointViewController")
            self.navigationController?.pushViewController(vc!, animated: true)
        }))
        alertVC.addAction(UIAlertAction(title: "Review & Save", style: .Default, handler: { _ in

        }))

        self.presentViewController(alertVC, animated: true, completion: nil)
    }

    @IBAction func pickImage() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.presentViewController(fusuma, animated: true, completion: nil)
    }

    func fusumaImageSelected(image: UIImage) {
        self.photo?.image = image
    }

    func fusumaCameraRollUnauthorized() {
        SCLAlertView().showError("Error", subTitle: "We need to access the camera in order to designate a photo for this waypoint.", closeButtonTitle: "OK")
    }

    @IBAction func openMap() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        vc.delegate = self

        self.navigationController?.pushViewController(vc, animated: true)
    }

    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.clear()

        let marker = GMSMarker(position: coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView

        self.coordsLabel?.text = "\(coordinate.latitude), \(coordinate.longitude)"
    }
}