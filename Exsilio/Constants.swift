//
//  Constants.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/13/16.
//
//

import Foundation
import FBSDKLoginKit
import FontAwesome_swift

struct UI {
    static let LabelCharacterSpacing = 1.2
    static let GreenColor = UIColor(hexString: "#21C064")
    static let BarButtonColor = UIColor(hexString: "#333333")
    static let BarButtonSize = CGSizeMake(32, 32)

    static func BarButtonIcon(name: FontAwesome) -> UIImage {
        return UIImage.fontAwesomeIconWithName(name, textColor: BarButtonColor, size: BarButtonSize)
    }
}

struct API {
    #if DEBUG
    static let URL = "http://192.168.1.3:3000"
    #else
    static let URL = "https://exsilio.herokuapp.com"
    #endif

    static let TokenHeader = "X-Token"

    static let AuthPath = "/users"
    static let ToursPath = "/tours"

    static func googleMapsKey() -> String {
        let plist = NSBundle.mainBundle().pathForResource("Configuration", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: plist)!

        return config.objectForKey("GoogleMapsAPI")!.objectForKey("Key") as! String
    }

    static func currentToken() -> String {
        return FBSDKAccessToken.currentAccessToken().tokenString
    }

    static func authHeaders() -> [String: String] {
        return [
            TokenHeader: self.currentToken()
        ]
    }
}