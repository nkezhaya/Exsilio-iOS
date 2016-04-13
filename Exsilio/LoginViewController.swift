//
//  LoginViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/11/16.
//
//

import UIKit
import FBSDKLoginKit
import PKRevealController

class LoginViewController: UIViewController {

    var pkRevealController: PKRevealController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func loginButtonClicked() {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self, handler: { (result, error) in
            if error != nil {
                print("Error with Facebook login")
            } else if result.isCancelled {
                print("Cancelled!")
            } else {
                let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,first_name,last_name,email,gender"])
                fbRequest.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) in
                    if error == nil {
                        print("Info: \(result)")
                        (UIApplication.sharedApplication().delegate as! AppDelegate).setRootViewController()
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

    func startPresentationMode() {
        self.pkRevealController.enterPresentationModeAnimated(true, completion: nil)
    }
}