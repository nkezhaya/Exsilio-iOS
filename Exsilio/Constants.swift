//
//  Constants.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/13/16.
//
//

import Foundation
import FBSDKLoginKit

struct Constants {
    static let LabelCharacterSpacing = 1.2
    static let GreenColor = UIColor(hexString: "#21C064")
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