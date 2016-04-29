//
//  CreateTourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/28/16.
//
//

import UIKit
import SCLAlertView

class CreateTourViewController: UIViewController {
    @IBOutlet var nameField: UITextField?
    @IBOutlet var descriptionField: UITextField?

    override func viewDidLoad() {
        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        let forwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: #selector(next))

        self.nameField?.becomeFirstResponder()
    }

    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func next() {
        if self.nameField?.text == nil {
            SCLAlertView().showError("Whoops!", subTitle: "You forgot to put a name in.", closeButtonTitle: "OK")
        } else {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateWaypointViewController")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}