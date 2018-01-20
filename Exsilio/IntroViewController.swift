//
//  IntroViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/11/16.
//
//

import UIKit
import FBSDKLoginKit
import Alamofire

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setTransparent(true)
    }

    @IBAction func loginWithFacebookTapped() {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { (result, error) in
            if error != nil {
                print("Error with Facebook login")
            } else if (result?.isCancelled)! {
                print("Cancelled!")
            } else {
                let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,first_name,last_name,email,gender"])
                _ = fbRequest?.start { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
                    if error == nil {
                        AuthenticationSingleton.shared.loggedInWithFacebook()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }

    @IBAction func forgotPasswordTapped() {
        var inputTextField: UITextField?
        let alertController = UIAlertController(title: "Forgot your password?",
                                                message: "Enter your email and we'll send you a new one.",
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let email = inputTextField?.text else { return }

            AuthenticationSingleton.shared.forgotPassword(email: email) {
                let alertController = UIAlertController(title: "Temporary Password Sent", message: "Check your email for your temporary password, and change it once you log in.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }))

        alertController.addTextField(configurationHandler: { (textField: UITextField!) in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            inputTextField = textField
        })

        present(alertController, animated: true, completion: nil)
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
