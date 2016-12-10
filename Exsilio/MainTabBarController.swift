//
//  MainTabBarController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/8/16.
//
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    var authentication: AuthenticationSingleton { return AuthenticationSingleton.shared }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        if let firstVC = self.viewControllers?[0] {
            self.setAttributesFromViewController(firstVC)
        }

        updateAppearance()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didLogIn), name: .userLoggedIn, object: nil)
        center.addObserver(self, selector: #selector(didLogOut), name: .userLoggedOut, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
        if let items = self.tabBar.items {
            for item in items {
                item.title = ""

                if let image = item.image {
                    item.image = image.imageWithTint(UIColor.white).withRenderingMode(.alwaysOriginal)
                    item.selectedImage = image.imageWithTint(UIColor.black).withRenderingMode(.alwaysOriginal)
                    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !authentication.isLoggedIn() {
            displayAuthentication(animated: false)
        }
    }

    func didLogIn() {
        selectedIndex = 0
    }

    func didLogOut() {
        displayAuthentication(animated: true) {
            self.selectedIndex = 0
        }
    }

    func displayAuthentication(animated: Bool, completion: ((Void) -> Void)? = nil) {
        let authStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        present(authStoryboard.instantiateInitialViewController()!, animated: true, completion: completion)
    }

    private func updateAppearance() {
        // Sets the default color of the icon of the selected UITabBarItem and Title
        UITabBar.appearance().tintColor = UIColor.black

        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor = UIColor(hexString: "#1c1c1c")

        // Sets the background color of the selected UITabBarItem
        let size = CGSize(width: self.tabBar.frame.width / CGFloat(self.tabBar.items!.count), height: self.tabBar.frame.height)
        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor.white, size: size)

        // Back button title label position
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -99999, vertical: 0), for: .default)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.setAttributesFromViewController(viewController)
    }

    func setAttributesFromViewController(_ viewController: UIViewController) {
        self.title = viewController.title
        self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem
    }
}
