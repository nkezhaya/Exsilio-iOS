//
//  NavigationControllerExtensions.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 12/10/16.
//
//

import UIKit

extension UINavigationController {
    func setTransparent(_ transparent: Bool) {
        if transparent {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.isTranslucent = true
            navigationBar.shadowImage = UIImage()
            setNavigationBarHidden(false, animated: true)
        } else {
            setNavigationBarHidden(true, animated: false)
            let appearance = UINavigationBar.appearance()
            navigationBar.setBackgroundImage(appearance.backgroundImage(for: .default), for: .default)
            navigationBar.isTranslucent = appearance.isTranslucent
            navigationBar.shadowImage = appearance.shadowImage
        }
    }
}
