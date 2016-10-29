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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .plain, target: self, action: #selector(dismissView))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UI.ForwardIcon, style: .plain, target: self, action: #selector(nextTapped))

        self.nameField?.becomeFirstResponder()
    }

    func dismissView() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func nextTapped() {
        if self.nameField?.text == nil || self.nameField?.text!.isEmpty == true {
            SCLAlertView().showError("Whoops!", subTitle: "You forgot to put a name in.", closeButtonTitle: "OK")
        } else {
            self.view.isUserInteractionEnabled = false
            CurrentTourSingleton.sharedInstance.newTour(self.nameField!.text!, description: self.descriptionField!.text!, successHandler: { tour in
                if let navigationController = self.navigationController as? CreateTourNavigationController {
                    navigationController.dismissAndEditTour(tour)
                }
                self.view.isUserInteractionEnabled = true
            })
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.nameField?.resignFirstResponder()
            self.descriptionField?.becomeFirstResponder()
        } else {
            self.descriptionField?.resignFirstResponder()
        }

        return true
    }
}
