//
//  MainTabBarController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/8/16.
//
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        if let firstVC = self.viewControllers?[0] {
            self.setAttributesFromViewController(firstVC)
        }

        // Sets the default color of the icon of the selected UITabBarItem and Title
        UITabBar.appearance().tintColor = UIColor.blackColor()

        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor = UIColor(hexString: "#1c1c1c")

        // Sets the background color of the selected UITabBarItem
        let size = CGSizeMake(self.tabBar.frame.width / CGFloat(self.tabBar.items!.count), self.tabBar.frame.height)
        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor.whiteColor(), size: size)

        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithTint(UIColor.whiteColor()).imageWithRenderingMode(.AlwaysOriginal)
                item.selectedImage = image.imageWithTint(UIColor.blackColor()).imageWithRenderingMode(.AlwaysOriginal)
                item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            }
        }
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.setAttributesFromViewController(viewController)
    }

    func setAttributesFromViewController(viewController: UIViewController) {
        self.title = viewController.title
        self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem
    }
}