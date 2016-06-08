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
        FBSDKLoginManager().logInWithReadPermissions(["public_profile", "email"], fromViewController: self, handler: { (result, error) in
            if error != nil {
                print("Error with Facebook login")
            } else if result.isCancelled {
                print("Cancelled!")
            } else {
                let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,first_name,last_name,email,gender"])
                fbRequest.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) in
                    if error == nil {
                        Alamofire.request(.POST, "\(API.URL)/\(API.AuthPath)", parameters: [ "user[token]": FBSDKAccessToken.currentAccessToken().tokenString ])
                            .responseJSON { _ in
                                (UIApplication.sharedApplication().delegate as! AppDelegate).setRootViewController()
                            }
                    } else {
                        print("Error: \(error)")
                    }
                })
            }
        })
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}