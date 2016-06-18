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
    let filtersViewController = FiltersViewController()
    let locationManager = CLLocationManager()

    var tours: JSON?
    var expandedIndexPath: NSIndexPath?
    var query: String = ""
    var currentLocation: CLLocation?

    // Server-side pagination
    var currentPage = 1
    var totalTours: Int?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.tabBarItem.image = UI.BarButtonIcon(.Search)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UI.BarButtonIcon(.Sliders),
                                                                 style: .Plain,
                                                                 target: self,
                                                                 action: #selector(showFilters))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.filtersViewController.searchController = self

        self.tableView.registerNib(UINib(nibName: "TourTableViewCell", bundle: nil), forCellReuseIdentifier: "TourTableViewCell")
        self.tableView.registerNib(UINib(nibName: "ExpandedTourTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpandedTourTableViewCell")

        self.tableView.tableFooterView = UIView()
        self.tableView.opaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        #if DEBUG
        self.query = "Nick"
        self.search()
        #endif

        self.locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tours = self.tours {
            return tours.count
        }

        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.totalTours == indexPath.row - 1 {
            self.fetchNextPage()
        }

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
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TourPreviewViewController") as! TourPreviewViewController
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

    func showFilters() {
        self.presentViewController(self.filtersViewController, animated: true, completion: nil)
    }

    func search() {
        var params: [String: String] = ["query": self.query]

        for filter in self.filtersViewController.form.values() {
            if let value = filter.1 {
                let strValue = "\(value)"
                if !strValue.isEmpty {
                    params[filter.0] = strValue
                }
            }
        }

        if let currentLocation = self.currentLocation {
            params["current_location[latitude]"] = String(currentLocation.coordinate.latitude)
            params["current_location[longitude]"] = String(currentLocation.coordinate.longitude)
        }

        params["page"] = String(self.currentPage)

        Alamofire.request(.GET, "\(API.URL)\(API.SearchPath)", parameters: params, headers: API.authHeaders()).responseJSON { response in
            switch response.result {
            case .Success(let result):
                let jsonResult = JSON(result)
                let newTours = jsonResult["tours"]
                let totalTours = jsonResult["total"].int

                // Is this the first load?
                if self.totalTours == nil && self.tours == nil {
                    self.tours = newTours
                    self.totalTours = totalTours
                }

                // Are we adding to the current set of tours?
                if self.currentPage > 1 {
                    var currentTours = self.tours!.arrayValue
                    currentTours.appendContentsOf(newTours.arrayValue)

                    self.tours = JSON(currentTours)
                }

                self.tableView.reloadData()
                break
            default:
                break
            }
        }
    }

    func fetchNextPage() {
        if let totalTours = self.totalTours {
            if self.tours!.count < totalTours {
                self.currentPage += 1
                self.search()
            }
        }
    }

    func resetSearch() {
        self.tours = nil
        self.totalTours = nil
        self.currentPage = 1
        self.tableView.reloadData()
    }
}

extension SearchTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        if let location = locations.first {
            self.currentLocation = location
        }
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
        if let searchText = searchBar.text {
            searchBar.resignFirstResponder()

            self.resetSearch()
            self.query = searchText
            self.search()
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