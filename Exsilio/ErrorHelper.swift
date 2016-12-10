//
//  ErrorHelper.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 12/10/16.
//
//

import Alamofire
import SwiftyJSON
import SVProgressHUD

struct ErrorHelper {
    static func handle(serverError: Error, response: DataResponse<Any>) {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }

        if let data = response.data {
            let json = JSON(data: data)
            let error: String = json["error"].string
                ?? json["errors"].string
                ?? serverError.localizedDescription

            FlashHelper.displayError(error)
        }
    }
}
