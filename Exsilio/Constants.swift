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

typealias Tour = [String: AnyObject]
typealias Waypoint = [String: AnyObject]

struct UI {
    static let LabelCharacterSpacing = 1.2
    static let GreenColor = UIColor(hexString: "#21c064")
    static let BlueColor = UIColor(hexString: "#1c56ff")
    static let RedColor = UIColor(hexString: "#e04940")
    static let BlackColor = UIColor.blackColor()
    static let BarButtonColor = UIColor(hexString: "#333333")
    static let BarButtonSize = CGSizeMake(32, 32)

    static func BarButtonIcon(name: FontAwesome, withColor color: UIColor) -> UIImage {
        return UIImage.fontAwesomeIconWithName(name, textColor: color, size: BarButtonSize)
    }

    static func BarButtonIcon(name: FontAwesome) -> UIImage {
        return UI.BarButtonIcon(name, withColor: UI.BarButtonColor)
    }

    static let PlusIcon = UIImage(named: "PlusIcon")!.scaledTo(1.5)
    static let ForwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)
    static let BackIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
    static let XIcon = UIImage(named: "XIcon")!.scaledTo(1.5)
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
    static let WaypointsPath = "/waypoints"
    static let SearchPath = "\(API.ToursPath)/search"
    static let MissingImagePath = "/images/original/missing.png"

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