//
//  ToursTableViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

import UIKit
import DZNEmptyDataSet

class ToursTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    var tours: [AnyObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.opaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showPlusIcon()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hidePlusIcon()
    }

    func showPlusIcon() {
        let plusIcon = UIImage(named: "PlusIcon")?.scaledTo(1.5)

        self.revealController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: plusIcon,
                                                                                   style: .Plain,
                                                                                   target: self,
                                                                                   action: #selector(newTour))
    }

    func hidePlusIcon() {
        self.revealController?.navigationItem.rightBarButtonItem = nil
    }

    func newTour() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateTourNavigationController")

        self.presentViewController(vc!, animated: true, completion: nil)
    }

    func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        return true
    }

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "NO TOURS YET"

        let attributes: [String : AnyObject!] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 24)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#AAAAAA"),
            NSKernAttributeName: Constants.LabelCharacterSpacing
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Create a tour and\nshare it with others!"

        let attributes: [String : AnyObject!] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 18)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#333333")
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }
}