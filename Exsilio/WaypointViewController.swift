//
//  WaypointViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/29/16.
//
//

import UIKit
import Fusuma
import SwiftyJSON
import Alamofire
import SCLAlertView
import FontAwesome_swift

class WaypointViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var nameField: UITextField?

    @IBOutlet var openMapButton: EXButton?
    @IBOutlet var pickImageButton: EXButton?

    var fusumaViewController = FusumaViewController()
    var selectedImage: UIImage?
    var selectedPoint: CLLocationCoordinate2D?

    var waypoint: Waypoint?

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

        if let waypoint = self.waypoint {
            if let name = waypoint["name"] as? String {
                self.nameField?.text = name
            }

            if let latitude = waypoint["latitude"] as? Double, longitude = waypoint["longitude"] as? Double {
                self.pointSelected(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }

            if let imageURL = waypoint["image_url"] as? String {
                if imageURL != API.MissingImagePath {
                    Alamofire.request(.GET, "\(API.URL)\(imageURL)").responseImage { response in
                        if let image = response.result.value {
                            self.fusumaImageSelected(image)
                        }
                    }
                }
            }

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: #selector(saveWaypoint))
        }

        self.nameField?.becomeFirstResponder()
    }

    func dismiss() {
        CurrentTourSingleton.sharedInstance.currentWaypointIndex -= 1
        self.navigationController?.popViewControllerAnimated(true)
    }

    func validateMessage() -> String? {
        if self.nameField?.text == nil || self.nameField!.text!.isEmpty {
            return "You forgot to put a name in."
        }

        if self.selectedPoint == nil {
            return "You forgot to select a point on the map."
        }

        return nil
    }

    func next() {
        if let invalidMessage = self.validateMessage() {
            SCLAlertView().showError("Whoops!", subTitle: invalidMessage, closeButtonTitle: "OK")
            return
        }

        let alertVC = UIAlertController(title: "What next?", message: "Select from the options below.", preferredStyle: .ActionSheet)
        alertVC.addAction(UIAlertAction(title: "New Waypoint", style: .Default, handler: { _ in
            self.saveWaypoint()
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WaypointViewController")
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
        if let invalidMessage = self.validateMessage() {
            SCLAlertView().showError("Whoops!", subTitle: invalidMessage, closeButtonTitle: "OK")
            return
        }

        var waypoint: Waypoint = self.waypoint == nil ? [:] : self.waypoint!

        if let name = self.nameField?.text {
            waypoint["name"] = name
        }

        if let coords = self.selectedPoint {
            waypoint["latitude"] = coords.latitude
            waypoint["longitude"] = coords.longitude
        }

        if let image = self.selectedImage {
            if waypoint["photo"] == nil || (waypoint["photo"] as! UIImage) != image {
                waypoint["photo"] = image
            }
        }

        if CurrentTourSingleton.sharedInstance.editingExistingTour {
            CurrentTourSingleton.sharedInstance.updateWaypoint(waypoint)
            self.dismiss()
        } else {
            CurrentTourSingleton.sharedInstance.saveWaypoint(waypoint)
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameField {
            nameField?.resignFirstResponder()
        }

        return true
    }
}

extension WaypointViewController: FusumaDelegate {
    @IBAction func pickImage() {
        self.fusumaViewController.delegate = self
        self.presentViewController(self.fusumaViewController, animated: true, completion: nil)
    }

    func fusumaImageSelected(image: UIImage) {
        self.selectedImage = image
        self.pickImageButton?.layer.borderWidth = 0
        self.pickImageButton?.backgroundColor = UI.GreenColor
        self.pickImageButton?.tintColor = .whiteColor()
        self.pickImageButton?.setIcon(.Check)
        self.pickImageButton?.updateText("PHOTO SELECTED!", withColor: .whiteColor())
    }

    func fusumaCameraRollUnauthorized() {
        SCLAlertView().showError("Error", subTitle: "We need to access the camera in order to designate a photo for this waypoint.", closeButtonTitle: "OK")
    }
}

extension WaypointViewController: GMSMapViewDelegate {
    @IBAction func openMap() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        vc.delegate = self
        vc.startingPoint = self.selectedPoint

        self.navigationController?.pushViewController(vc, animated: true)
    }

    func pointSelected(coordinate: CLLocationCoordinate2D) {
        self.selectedPoint = coordinate

        self.openMapButton?.layer.borderWidth = 0
        self.openMapButton?.backgroundColor = UI.GreenColor
        self.openMapButton?.tintColor = .whiteColor()
        self.openMapButton?.setIcon(.Check)
        self.openMapButton?.updateText("LOCATION SELECTED!", withColor: .whiteColor())
    }

    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.clear()

        let marker = GMSMarker(position: coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView

        self.pointSelected(coordinate)
    }
}