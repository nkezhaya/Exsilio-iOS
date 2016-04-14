//
//  MenuTableViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/13/16.
//
//

import UIKit
import FBSDKLoginKit

class MenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()

        self.tableView.backgroundColor = UIColor(hexString: "#1c1c1c")
        self.tableView.opaque = false
        self.tableView.backgroundView = nil
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "MenuTableViewCell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! MenuTableViewCell

        switch indexPath.row {
        case 0:
            cell.setString("SEARCH TOURS")
        case 1:
            cell.setString("MY TOURS")
        case 2:
            cell.setString("LOG OUT")
        default:
            break
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            break
        case 2:
            FBSDKLoginManager().logOut()
            (UIApplication.sharedApplication().delegate as! AppDelegate).setRootViewController()
        default:
            break
        }

        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

class MenuTableViewCell: UITableViewCell {
    @IBOutlet var itemLabel: UILabel?

    override func awakeFromNib() {
        setString(self.itemLabel!.text!)

        let bgView = UIView()
        bgView.backgroundColor = UIColor(hexString: "#131313")
        self.selectedBackgroundView = bgView

        super.awakeFromNib()
    }

    func setString(string: String) {
        self.itemLabel?.attributedText = NSAttributedString(string: string, attributes: [NSKernAttributeName: Constants.LabelCharacterSpacing])
    }
}