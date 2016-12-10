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
}
