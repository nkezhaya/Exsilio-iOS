//
//  WaypointsTableViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 5/26/16.
//
//

import UIKit
import DZNEmptyDataSet
import SwiftyJSON

class WaypointsTableViewController: UITableViewController {
    var editBarButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))

        if self.editBarButtonItem == nil {
            self.editBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(enterEditingMode))
        }

        self.navigationItem.rightBarButtonItem = self.editBarButtonItem

        self.tableView.tableFooterView = UIView()
        self.tableView.opaque = false
        self.tableView.backgroundView = nil

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

    func enterEditingMode() {
        self.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(exitEditingMode))
    }

    func exitEditingMode() {
        self.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem = self.editBarButtonItem
    }

    func refresh() {
        CurrentTourSingleton.sharedInstance.refreshTour({
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
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
}