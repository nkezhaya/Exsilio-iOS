//
//  ToursTableViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

import UIKit
import Alamofire
import DZNEmptyDataSet
import SwiftyJSON
import SWTableViewCell

class ToursTableViewController: UITableViewController {
    var tours: JSON = JSON([])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)

        self.tableView.tableFooterView = UIView()
        self.tableView.opaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showPlusIcon()
        refresh()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hidePlusIcon()
    }

    func refresh() {
        Alamofire.request(.GET, "\(API.URL)\(API.ToursPath)", headers: API.authHeaders()).responseJSON { response in
            self.refreshControl?.endRefreshing()

            switch response.result {
            case .Success(let json):
                self.tours = JSON(json)
                self.tableView.reloadData()
                break
            default:
                break
            }
        }
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tours.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TourTableViewCell", forIndexPath: indexPath) as! TourTableViewCell
        cell.delegate = self
        cell.updateWithTour(self.tours[indexPath.row])

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TourViewController") as! TourViewController
        vc.tour = self.tours[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ToursTableViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        let indexPath = self.tableView.indexPathForCell(cell)!

        switch index {
        case 0:
            print("edit")
        case 1:
            if let id = self.tours[indexPath.row]["id"].int {
                Alamofire.request(.DELETE, "\(API.URL)\(API.ToursPath)/\(id)", headers: API.authHeaders())

                self.tours.arrayObject?.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        default:
            break
        }
    }

    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
}

extension ToursTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        return self.tours.count == 0
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