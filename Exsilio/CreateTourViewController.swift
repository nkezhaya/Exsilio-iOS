//
//  CreateTourViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/28/16.
//
//

import UIKit

class CreateTourViewController: UIViewController {
    @IBOutlet var nameField: UITextField?
    @IBOutlet var descriptionField: UITextField?

    override func viewDidLoad() {
        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        let forwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: nil)

        self.nameField?.becomeFirstResponder()
    }

    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}