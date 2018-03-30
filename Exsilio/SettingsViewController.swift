//
//  SettingsViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/8/16.
//
//

import UIKit
import Eureka
import SVProgressHUD
import AVFoundation

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
                row.value = UserDefaults.standard.bool(forKey: Settings.speechKey)
                row.onChange({ row in
                    let value: Bool = row.value == nil ? false : row.value!
                    UserDefaults.standard.set(value, forKey: Settings.speechKey)
                })
            }
            <<< SliderRow() { row in
                row.title = "Narrator Speed"
                let rate = UserDefaults.standard.object(forKey: Settings.speechRateKey) == nil ? AVSpeechUtteranceDefaultSpeechRate : UserDefaults.standard.float(forKey: Settings.speechRateKey)
                row.value = rate
                row.minimumValue = AVSpeechUtteranceMinimumSpeechRate
                row.maximumValue = AVSpeechUtteranceMaximumSpeechRate
                row.onChange({ row in
                    let value: Float = row.value == nil ? 0 : row.value!
                    UserDefaults.standard.set(value, forKey: Settings.speechRateKey)
                })
            }
            +++ Section("Session")
            <<< viewControllerRow(title: "Change Password", builder: { return ChangePasswordViewController() })
            <<< ButtonRow() { row in
                row.title = "Log Out"
                row.onCellSelection({ (_, _) in
                    AuthenticationSingleton.shared.logOut()
                    SVProgressHUD.dismiss()
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
