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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.navigationItem.title = self.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section("Session")
            <<< ButtonRow() {
                $0.title = "Log Out"
                $0.onCellSelection({ (_, _) in
                    (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
                })
            }
    }
}