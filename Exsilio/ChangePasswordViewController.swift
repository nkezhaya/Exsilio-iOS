//
//  ChangePasswordViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 1/20/18.
//

import UIKit
import Eureka

final class ChangePasswordViewController: FormViewController {
    private var parameters: [String: String] {
        var ps = [String: String]()

        form.values().forEach { (k, v) in
            ps[k] = v as? String ?? ""
        }

        return ps
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change Password"

        form +++ Section("")
            <<< PasswordRow("password") { row in
                row.title = "New Password"
            }
            <<< PasswordRow("password_confirmation") { row in
                row.title = "Confirm Password"
            }
            +++ Section(footer: "")
            <<< ButtonRow() { row in
                row.title = "Change Password"
                row.onCellSelection({ (_, _) in
                    AuthenticationSingleton.shared.changePassword(params: self.parameters,
                                                                  success: {
                                                                    FlashHelper.displaySuccess("Your password was successfully changed.")
                                                                    self.navigationController?.popViewController(animated: true)
                    })
                })
            }
    }
}
