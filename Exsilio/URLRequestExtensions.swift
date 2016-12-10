//
//  URLRequestExtensions.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 12/10/16.
//
//

import Foundation

extension URLRequest {
    mutating func addAuthHeader() {
        let headers = API.authHeaders()

        for (key, value) in headers {
            setValue(value, forHTTPHeaderField: key)
        }
    }
}
