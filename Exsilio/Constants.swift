//
//  Constants.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/13/16.
//
//

import Foundation

struct Constants {
    static let LabelCharacterSpacing = 1.2
}

struct API {
    #if DEBUG
    static let URL = "http://192.168.1.3:3000"
    #else
    static let URL = "https://exsilio.herokuapp.com"
    #endif

    static let AuthPath = "/users"

    static func googleMapsKey() -> String {
        let plist = NSBundle.mainBundle().pathForResource("Configuration", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: plist)!

        return config.objectForKey("GoogleMapsAPI")!.objectForKey("Key") as! String
    }
}