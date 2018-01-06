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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UI.BackIcon, style: .plain, target: self, action: #selector(dismissModal))
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UI.PlusIcon, style: .plain, target: self, action: #selector(addWaypoint)),
            UIBarButtonItem(image: UI.BarButtonIcon(.edit), style: .plain, target: self, action: #selector(toggleEditingMode))
        ]

        self.tableView.tableFooterView = UIView()
        self.tableView.isOpaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.refresh()
    }

    func dismissModal() {
        self.navigationController?.popViewController(animated: true)
    }

    func addWaypoint() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "WaypointViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func toggleEditingMode() {
        self.setEditing(!self.isEditing, animated: true)
        self.navigationItem.rightBarButtonItems![1].tintColor = self.isEditing ? UI.BlueColor : UI.BlackColor
    }

    func refresh() {
        CurrentTourSingleton.sharedInstance.refreshTour { _ in
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentTourSingleton.sharedInstance.waypoints.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WaypointTableViewCell", for: indexPath) as! WaypointTableViewCell
        cell.updateWithWaypoint(CurrentTourSingleton.sharedInstance.waypoints[(indexPath as NSIndexPath).row])

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WaypointViewController") as! WaypointViewController
        vc.waypoint = CurrentTourSingleton.sharedInstance.waypoints[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        CurrentTourSingleton.sharedInstance.moveWaypointAtIndex((sourceIndexPath as NSIndexPath).row, toIndex: (destinationIndexPath as NSIndexPath).row, completion: {
            self.tableView.reloadData()
        })
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CurrentTourSingleton.sharedInstance.removeWaypointAtIndex((indexPath as NSIndexPath).row)
            self.tableView.reloadData()
        }
    }
}

extension WaypointsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return CurrentTourSingleton.sharedInstance.waypoints.count == 0
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIcon(name: .mapPin, textColor: UIColor(hexString: "#AAAAAA"), size: CGSize(width: 80, height: 80))
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "NO WAYPOINTS"

        let attributes: [String : Any] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 24)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#AAAAAA"),
            NSKernAttributeName: UI.LabelCharacterSpacing as ImplicitlyUnwrappedOptional<AnyObject>
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add some waypoints before\npublishing your tour!"

        let attributes: [String : Any] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 18)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#333333")
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -20
    }
}
