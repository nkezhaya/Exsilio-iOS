//
//  FlashHelper.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 12/10/16.
//
//

import SwiftMessages

struct FlashHelper {
    static func displayMessage(withTitle title: String, body: String, theme: Theme) {
        let message = MessageView.viewFromNib(layout: .CardView)
        message.configureTheme(theme)
        message.configureContent(title: title, body: body)
        message.button?.isHidden = true
        SwiftMessages.show(view: message)
    }

    static func displayError(_ error: GenericError) {
        switch error {
        case .error(let reason):
            displayMessage(withTitle: "Error", body: reason, theme: .error)
        }
    }

    static func displayError(_ string: String) {
        displayError(GenericError.error(string))
    }

    static func displaySuccess(_ string: String) {
        displayMessage(withTitle: "Success!", body: string, theme: .success)
    }

    static func displayCameraRollUnauthorized() {
        displayError("Whoops! We need to access your camera to upload pictures for the listings you create.")
    }
}
