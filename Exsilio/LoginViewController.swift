//
//  LoginViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/11/16.
//
//

import UIKit
import FBSDKLoginKit
import Alamofire

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
    }

    @IBAction func loginButtonClicked() {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { (result, error) in
            if error != nil {
                print("Error with Facebook login")
            } else if (result?.isCancelled)! {
                print("Cancelled!")
            } else {
                let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,first_name,last_name,email,gender"])
                _ = fbRequest?.start { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
                    if error == nil {
                        Alamofire.request("\(API.URL)/\(API.AuthPath)", method: .post, parameters: [ "user[token]": FBSDKAccessToken.current().tokenString ])
                            .responseJSON { _ in
                                (UIApplication.shared.delegate as! AppDelegate).setRootViewController()
                        }
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
