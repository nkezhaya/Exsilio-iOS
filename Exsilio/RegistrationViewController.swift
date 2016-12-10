//
//  RegistrationViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 12/10/16.
//
//

import UIKit

class RegistrationViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    var params: Parameters {
        get {
            let ps: [String: String?] = [
                "email": emailTextField.text,
                "first_name": firstNameTextField.text,
                "last_name": lastNameTextField.text,
                "password": passwordTextField.text
            ]

            var filtered: Parameters = [:]

            ps.forEach { (k, v) in
                if let v = v , !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    filtered[k] = v
                }
            }

            return filtered
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignFirstResponder)))

        emailTextField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        emailTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        return true
    }

    @IBAction func createAccountButtonTapped() {
        AuthenticationSingleton.shared.register(with: params,
                                                success: registrationSuccess,
                                                failure: FlashHelper.displayError)
    }

    fileprivate func registrationSuccess() {
        dismiss(animated: true, completion: nil)
    }
}
