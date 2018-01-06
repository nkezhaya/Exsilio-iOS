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

typealias Tour = [String: Any]
typealias Waypoint = [String: Any]

struct UI {
    static let LabelCharacterSpacing = 1.2
    static let GreenColor = UIColor(hexString: "#21c064")
    static let BlueColor = UIColor(hexString: "#1c56ff")
    static let RedColor = UIColor(hexString: "#e04940")
    static let BlackColor = UIColor.black
    static let BarButtonColor = UIColor(hexString: "#333333")
    static let BarButtonColorDisabled = UIColor(hexString: "#c1c1c1")
    static let BarButtonSize = CGSize(width: 32, height: 32)

    static func BarButtonIcon(_ name: FontAwesome, withColor color: UIColor) -> UIImage {
        return UIImage.fontAwesomeIcon(name: name, textColor: color, size: BarButtonSize)
    }

    static func BarButtonIcon(_ name: FontAwesome) -> UIImage {
        return UI.BarButtonIcon(name, withColor: UI.BarButtonColor)
    }

    static let PlusIcon = UIImage(named: "PlusIcon")!.scaledTo(1.5)
    static let ForwardIcon = UIImage(named: "ForwardIcon")!.scaledTo(1.5)
    static let BackIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
    static let XIcon = UIImage(named: "XIcon")!.scaledTo(1.5)
}

struct API {
    #if DEBUG
    static let URL = "http://192.168.1.35:3000"
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
        let plist = Bundle.main.path(forResource: "Configuration", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: plist)!

        return (config.object(forKey: "GoogleMapsAPI")! as AnyObject).object(forKey: "Key") as! String
    }

    static func currentFacebookToken() -> String? {
        return FBSDKAccessToken.current().tokenString
    }

    static func authHeaders() -> Headers {
        if FBSDKAccessToken.current() != nil {
            return ["X-FB-Token": FBSDKAccessToken.current().tokenString]
        }

        var headers = Headers()

        if AuthenticationSingleton.shared.currentUser == nil {
            return headers
        }

        if let userEmail = AuthenticationSingleton.shared.currentUser?["email"].string {
            headers["X-User-Email"] = userEmail
        }

        if let accessToken = AuthenticationSingleton.shared.accessToken {
            headers["X-User-Token"] = accessToken
        }

        return headers
    }
}

struct Settings {
    static let speechKey = "AllowsSpeech"
    static let accessTokenKey = "AccessTokenKey"
}

extension Notification.Name {
    static let userLoggedIn = Notification.Name("userLoggedIn")
    static let userLoggedOut = Notification.Name("userLoggedOut")
}

typealias Parameters = [String: Any]
typealias MultipartParameters = [String: Data]
typealias Headers = [String: String]

enum GenericError: Error {
    case error(String)

    static let incompleteForm = "Please fill out all form fields and try again."
}
