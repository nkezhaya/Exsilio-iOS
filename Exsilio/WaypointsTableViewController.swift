//
//  WaypointsTableViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/26/16.
//
//

import UIKit
import DZNEmptyDataSet
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SCLAlertView

class WaypointsTableViewController: UITableViewController {
    var addBarButtonItem: UIBarButtonItem?
    var editBarButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .Plain, target: self, action: #selector(dismiss))
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UI.PlusIcon, style: .Plain, target: self, action: #selector(addWaypoint)),
            UIBarButtonItem(image: UI.BarButtonIcon(.Edit), style: .Plain, target: self, action: #selector(toggleEditingMode))
        ]

        self.tableView.tableFooterView = UIView()
        self.tableView.opaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.refresh()
    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func addWaypoint() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WaypointViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func toggleEditingMode() {
        self.setEditing(!self.editing, animated: true)
        self.navigationItem.rightBarButtonItems![1].tintColor = self.editing ? UI.BlueColor : UI.BlackColor
    }

    func refresh() {
        CurrentTourSingleton.sharedInstance.refreshTour { _ in
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentTourSingleton.sharedInstance.waypoints.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("WaypointTableViewCell", forIndexPath: indexPath) as! WaypointTableViewCell
        cell.updateWithWaypoint(CurrentTourSingleton.sharedInstance.waypoints[indexPath.row])

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WaypointViewController") as! WaypointViewController
        vc.waypoint = CurrentTourSingleton.sharedInstance.waypoints[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        CurrentTourSingleton.sharedInstance.moveWaypointAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row, completion: {
            self.tableView.reloadData()
        })
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            CurrentTourSingleton.sharedInstance.removeWaypointAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }
}

extension WaypointsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        return CurrentTourSingleton.sharedInstance.waypoints.count == 0
    }

    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIconWithName(.MapPin, textColor: UIColor(hexString: "#AAAAAA"), size: CGSizeMake(80, 80))
    }

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "NO WAYPOINTS"

        let attributes: [String : AnyObject!] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 24)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#AAAAAA"),
            NSKernAttributeName: UI.LabelCharacterSpacing
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add some waypoints before\npublishing your tour!"

        let attributes: [String : AnyObject!] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 18)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#333333")
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -20
    }
}