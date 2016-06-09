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

        self.tabBarItem.image = UI.BarButtonIcon(.Cog)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section("Session")
            <<< ButtonRow() { row in
                row.title = "Log Out"
                row.onCellSelection({ (_, _) in
                    (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
                })
            }
    }
}