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

class CreateWaypointViewController: UIViewController, FusumaDelegate {
    override func viewDidLoad() {
        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        let forwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: #selector(next))
    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func next() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateWaypointViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func pickImage() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.presentViewController(fusuma, animated: true, completion: nil)
    }

    func fusumaImageSelected(image: UIImage) {

    }

    func fusumaCameraRollUnauthorized() {
        SCLAlertView().showError("Error", subTitle: "We need to access the camera in order to designate a photo for this waypoint.", closeButtonTitle: "OK")
    }
}