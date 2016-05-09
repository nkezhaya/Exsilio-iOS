//
//  CurrentTourSingleton.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/5/16.
//
//

import Foundation

class CurrentTourSingleton {
    static let sharedInstance = CurrentTourSingleton()

    var currentWaypointIndex = -1
    var tour: [String: AnyObject] = [:]
}