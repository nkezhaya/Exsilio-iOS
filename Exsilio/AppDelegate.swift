//
//  AppDelegate.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/11/16.
//
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        GMSServices.provideAPIKey(API.googleMapsKey())

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        setRootViewController()
        setAesthetics()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func setRootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController: UIViewController

        if FBSDKAccessToken.currentAccessToken() != nil {
            let mainTabBarController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController")
            let navigationController: UINavigationController

            navigationController = UINavigationController(rootViewController: mainTabBarController)
            navigationController.navigationBar.translucent = false

            initialViewController = navigationController
        } else {
            initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        }

        UIView.transitionWithView(self.window!,
                                  duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft,
                                  animations: { self.window?.rootViewController = initialViewController },
                                  completion: nil)

        self.window?.makeKeyAndVisible()
    }

    func logOut() {
        FBSDKLoginManager().logOut()
        self.setRootViewController()
    }

    func setAesthetics() {
        let color = UIColor(hexString: "#333333")
        UINavigationBar.appearance().tintColor = color
        UINavigationBar.appearance().barTintColor = .whiteColor()

        let attributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 20)!,
            NSForegroundColorAttributeName: color
        ]

        UINavigationBar.appearance().titleTextAttributes = attributes
    }
}