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
                    } else {
                        print("Error: \(error)")
                    }
                }
            }
        })
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
