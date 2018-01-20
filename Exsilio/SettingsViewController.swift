//
//  SettingsViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/8/16.
//
//

import UIKit
import Eureka

class SettingsViewController: FormViewController {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.tabBarItem.image = UI.BarButtonIcon(.cog)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form
            +++ Section("Profile")
            <<< viewControllerRow(title: "Change Password", builder: { return ChangePasswordViewController() })
            +++ Section("Voice")
            <<< SwitchRow() { row in
                row.title = "Speak Descriptions"
                row.onChange({ row in
                    let value: Bool = row.value == nil ? false : row.value!
                    UserDefaults.standard.set(value, forKey: Settings.speechKey)
                })
            }
            +++ Section("Session")
            <<< ButtonRow() { row in
                row.title = "Log Out"
                row.onCellSelection({ (_, _) in
                    AuthenticationSingleton.shared.logOut()
                })
            }
    }

    private func viewControllerRow(title: String, builder: @escaping () -> UIViewController) -> ButtonRow {
        return ButtonRow() { row in
            row.title = title
            row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: {
                return builder()
            }), onDismiss: { vc in
                vc.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
    }
}
