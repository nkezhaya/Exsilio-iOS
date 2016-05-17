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
import FontAwesome_swift

class CreateWaypointViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var nameField: UITextField?

    @IBOutlet var openMapButton: EXButton?
    @IBOutlet var pickImageButton: EXButton?

    var selectedImage: UIImage?
    var selectedPoint: CLLocationCoordinate2D?

    override func viewDidLoad() {
        CurrentTourSingleton.sharedInstance.currentWaypointIndex += 1
        
        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        let forwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: #selector(next))

        self.title = "Waypoint \(CurrentTourSingleton.sharedInstance.currentWaypointIndex + 1)"

        self.openMapButton?.darkBorderStyle()
        self.pickImageButton?.darkBorderStyle()

        self.openMapButton?.setIcon(.Map)
        self.pickImageButton?.setIcon(.Camera)

        self.nameField?.becomeFirstResponder()
    }

    func dismiss() {
        CurrentTourSingleton.sharedInstance.currentWaypointIndex -= 1
        self.navigationController?.popViewControllerAnimated(true)
    }

    func next() {
        if self.nameField?.text == nil || self.nameField!.text!.isEmpty {
            SCLAlertView().showError("Whoops!", subTitle: "You forgot to put a name in.", closeButtonTitle: "OK")
            return
        }

        if self.selectedPoint == nil {
            SCLAlertView().showError("Whoops!", subTitle: "You forgot to select a point on the map.", closeButtonTitle: "OK")
            return
        }

        let alertVC = UIAlertController(title: "What next?", message: "Select from the options below.", preferredStyle: .ActionSheet)
        alertVC.addAction(UIAlertAction(title: "New Waypoint", style: .Default, handler: { _ in
            self.saveWaypoint()
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateWaypointViewController")
            self.navigationController?.pushViewController(vc!, animated: true)
        }))
        alertVC.addAction(UIAlertAction(title: "Save & Publish Tour", style: .Default, handler: { _ in
            self.saveWaypoint()
            CurrentTourSingleton.sharedInstance.save()
            self.navigationController?.dismissViewControllerAnimated(true, completion: {
                CurrentTourSingleton.sharedInstance.currentWaypointIndex = -1
            })
        }))

        self.presentViewController(alertVC, animated: true, completion: nil)
    }

    func saveWaypoint() {
        var data: [String: AnyObject] = [:]

        if let name = self.nameField?.text {
            data["name"] = name
        }

        if let coords = self.selectedPoint {
            data["coords"] = "\(coords.latitude), \(coords.longitude)"
        }

        if let image = self.selectedImage {
            data["photo"] = image
        }

        CurrentTourSingleton.sharedInstance.saveWaypoint(data)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameField {
            nameField?.resignFirstResponder()
        }

        return true
    }
}

extension CreateWaypointViewController: FusumaDelegate {
    @IBAction func pickImage() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.presentViewController(fusuma, animated: true, completion: nil)
    }

    func fusumaImageSelected(image: UIImage) {
        self.selectedImage = image
        self.pickImageButton?.layer.borderWidth = 0
        self.pickImageButton?.backgroundColor = Constants.GreenColor
        self.pickImageButton?.setIcon(.Check)
        self.pickImageButton?.updateText("PHOTO SELECTED!", withColor: .whiteColor())
    }

    func fusumaCameraRollUnauthorized() {
        SCLAlertView().showError("Error", subTitle: "We need to access the camera in order to designate a photo for this waypoint.", closeButtonTitle: "OK")
    }
}

extension CreateWaypointViewController: GMSMapViewDelegate {
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

        self.selectedPoint = coordinate

        self.openMapButton?.layer.borderWidth = 0
        self.openMapButton?.backgroundColor = Constants.GreenColor
        self.openMapButton?.setIcon(.Check)
        self.openMapButton?.updateText("LOCATION SELECTED!", withColor: .whiteColor())
    }
}