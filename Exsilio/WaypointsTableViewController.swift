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
    var waypoints: [Waypoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let backIcon = UIImage(named: "BackIcon")!.scaledTo(1.5)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(dismiss))

        self.tableView.tableFooterView = UIView()
        self.tableView.opaque = false
        self.tableView.backgroundView = nil

        self.waypoints = CurrentTourSingleton.sharedInstance.waypoints
    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func refresh() {

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.waypoints.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("WaypointTableViewCell", forIndexPath: indexPath) as! WaypointTableViewCell
        cell.updateWithWaypoint(self.waypoints[indexPath.row])

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WaypointViewController") as! WaypointViewController
        vc.waypoint = self.waypoints[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}