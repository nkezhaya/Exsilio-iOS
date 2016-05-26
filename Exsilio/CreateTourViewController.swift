//
//  CreateTourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/28/16.
//
//

import UIKit
import SCLAlertView

class CreateTourViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var nameField: UITextField?
    @IBOutlet var descriptionField: UITextField?

    override func viewDidLoad() {
        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        let forwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))

        if CurrentTourSingleton.sharedInstance.editingExistingTour {
            if let name = CurrentTourSingleton.sharedInstance.tour["name"] as? String {
                self.nameField?.text = name
            }

            if let description = CurrentTourSingleton.sharedInstance.tour["description"] as? String {
                self.descriptionField?.text = description
            }

            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UI.BarButtonIcon(.MapPin), style: .Plain, target: self, action: #selector(editWaypoints)),
                UIBarButtonItem(image: UI.BarButtonIcon(.Save), style: .Plain, target: self, action: #selector(save))
            ]
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: #selector(next))
        }

        self.nameField?.becomeFirstResponder()
    }

    func editWaypoints() {

    }

    func save() {

    }

    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func next() {
        if self.nameField?.text == nil || self.nameField?.text!.isEmpty == true {
            SCLAlertView().showError("Whoops!", subTitle: "You forgot to put a name in.", closeButtonTitle: "OK")
        } else {
            CurrentTourSingleton.sharedInstance.newTour(self.nameField!.text!, description: self.descriptionField!.text!)

            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WaypointViewController")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.nameField?.resignFirstResponder()
            self.descriptionField?.becomeFirstResponder()
        } else {
            self.descriptionField?.resignFirstResponder()
        }

        return true
    }
}