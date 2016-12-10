//
//  LoginViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 12/10/16.
//
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    var isValid: Bool {
        var foundEmpty = false

        [emailTextField, passwordTextField].forEach {
            if let value = $0?.text {
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    foundEmpty = true
                }
            }
        }

        return !foundEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.attributedText = NSAttributedString(string: headerLabel.text!,
                                                        attributes: [
                                                            NSKernAttributeName: 15.0,
                                                            NSFontAttributeName: headerLabel.font
                                                        ])
    }

    @IBAction func loginButtonTapped() {
        guard isValid else {
            FlashHelper.displayError(GenericError.incompleteForm)
            return
        }

        let email = emailTextField.text!
        let password = passwordTextField.text!


        AuthenticationSingleton.shared.login(email: email,
                                             password: password,
                                             success: loginSuccess,
                                             failure: FlashHelper.displayError)
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        return true
    }

    fileprivate func loginSuccess() {
        dismiss(animated: true) {
            FlashHelper.displaySuccess("You are now logged in!")
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }

        return true
    }
}
