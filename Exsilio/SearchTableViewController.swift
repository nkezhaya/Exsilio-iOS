//
//  SearchTableViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet
import FontAwesome_swift

class SearchTableViewController: UITableViewController {
    var tours: JSON?
    var expandedIndexPath: NSIndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.tabBarItem.image = UI.BarButtonIcon(.Search)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.navigationItem.title = self.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "TourTableViewCell", bundle: nil), forCellReuseIdentifier: "TourTableViewCell")
        self.tableView.registerNib(UINib(nibName: "ExpandedTourTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpandedTourTableViewCell")

        self.tableView.tableFooterView = UIView()
        self.tableView.opaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tours = self.tours {
            return tours.count
        }

        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.expandedIndexPath == indexPath {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("ExpandedTourTableViewCell", forIndexPath: indexPath) as! ExpandedTourTableViewCell
            cell.updateWithTour(self.tours![indexPath.row])

            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("TourTableViewCell", forIndexPath: indexPath) as! TourTableViewCell
            cell.updateWithTour(self.tours![indexPath.row])

            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // If the user taps the same row, proceed to Tour summary.

        if self.expandedIndexPath == indexPath {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TourViewController") as! TourViewController
            vc.tour = self.tours![indexPath.row]

            self.navigationController?.pushViewController(vc, animated: true)
            return
        }

        // Otherwise, figure out which rows are being expanded/collapsed. Only one row can be expanded at a time.

        var pathsToReload: [NSIndexPath] = []

        if let oldExpandedIndexPath = self.expandedIndexPath {
            pathsToReload.append(oldExpandedIndexPath)
            pathsToReload.append(indexPath)

            self.expandedIndexPath = indexPath
        } else {
            pathsToReload.append(indexPath)
            self.expandedIndexPath = indexPath
        }

        self.tableView.reloadRowsAtIndexPaths(pathsToReload, withRowAnimation: .Automatic)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.expandedIndexPath == indexPath ? 200.0 : 87.0
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let query = searchBar.text {
            searchBar.resignFirstResponder()

            Alamofire.request(.GET, "\(API.URL)\(API.SearchPath)?query=\(query)", headers: API.authHeaders()).responseJSON { response in
                switch response.result {
                case .Success(let result):
                    self.tours = JSON(result)["tours"]
                    self.tableView.reloadData()
                    break
                default:
                    break
                }
            }
        }
    }
}

extension SearchTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        return self.tours?.count == 0
    }

    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIconWithName(.Search, textColor: UIColor(hexString: "#AAAAAA"), size: CGSizeMake(80, 80))
    }

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "NO RESULTS"

        let attributes: [String : AnyObject!] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 24)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#AAAAAA"),
            NSKernAttributeName: UI.LabelCharacterSpacing
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Modify your search terms\nand try again!"

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