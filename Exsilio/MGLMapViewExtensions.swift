//
//  MGLMapViewExtensions.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 3/29/18.
//

import Mapbox

extension MGLMapView {
    func clear() {
        if let annotations = annotations {
            removeAnnotations(annotations)
        }
    }
}
