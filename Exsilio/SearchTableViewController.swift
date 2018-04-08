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
import CoreLocation

class SearchTableViewController: UITableViewController {
    let filtersViewController = FiltersViewController()
    let locationManager = CLLocationManager()

    var tours: JSON?
    var expandedIndexPath: IndexPath?
    var query: String = ""
    var currentLocation: CLLocation?

    // Server-side pagination
    var currentPage = 1
    var totalTours: Int?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.tabBarItem.image = UI.BarButtonIcon(.search)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UI.BarButtonIcon(.sliders),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(showFilters))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false

        self.filtersViewController.searchController = self

        self.tableView.register(UINib(nibName: "TourTableViewCell", bundle: nil), forCellReuseIdentifier: "TourTableViewCell")
        self.tableView.register(UINib(nibName: "ExpandedTourTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpandedTourTableViewCell")

        self.tableView.tableFooterView = UIView()
        self.tableView.isOpaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        #if DEBUG
        self.query = "Nick"
        self.search()
        #endif

        self.locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tours = self.tours {
            return tours.count
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((indexPath as NSIndexPath).row + 1) % 10 == 0 {
            self.fetchNextPage()
        }

        if self.expandedIndexPath == indexPath {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ExpandedTourTableViewCell", for: indexPath) as! ExpandedTourTableViewCell
            cell.updateWithTour(self.tours![indexPath.row])

            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "TourTableViewCell", for: indexPath) as! TourTableViewCell
            cell.updateWithTour(self.tours![indexPath.row])

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        // If the user taps the same row, proceed to Tour summary.

        if self.expandedIndexPath == indexPath {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TourPreviewTableViewController") as! TourPreviewTableViewController
            vc.tour = self.tours![indexPath.row]

            self.navigationController?.pushViewController(vc, animated: true)
            return
        }

        // Otherwise, figure out which rows are being expanded/collapsed. Only one row can be expanded at a time.

        var pathsToReload: [IndexPath] = []

        if let oldExpandedIndexPath = self.expandedIndexPath {
            pathsToReload.append(oldExpandedIndexPath)
            pathsToReload.append(indexPath)

            self.expandedIndexPath = indexPath
        } else {
            pathsToReload.append(indexPath)
            self.expandedIndexPath = indexPath
        }

        self.tableView.reloadRows(at: pathsToReload, with: .automatic)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.expandedIndexPath == indexPath ? 200.0 : 87.0
    }

    func showFilters() {
        let navigationController = UINavigationController()
        navigationController.pushViewController(self.filtersViewController, animated: false)
        self.present(navigationController, animated: true, completion: nil)
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

        Alamofire.request("\(API.URL)\(API.SearchPath)", method: .get, parameters: params, headers: API.authHeaders()).responseJSON { response in
            switch response.result {
            case .success(let result):
                let jsonResult = JSON(result)
                let newTours = jsonResult["tours"]
                let totalTours = jsonResult["total"].int

                // Is this the first load?
                if self.totalTours == nil && self.tours == nil {
                    self.tours = newTours
                    self.totalTours = totalTours
                    self.tableView.reloadData()
                }

                // Are we adding to the current set of tours?
                if self.currentPage > 1 {
                    var currentTours = self.tours!.arrayValue
                    let initialCount = currentTours.count
                    currentTours.append(contentsOf: newTours.arrayValue)
                    let newCount = currentTours.count

                    self.tours = JSON(currentTours)

                    let indexPaths = (initialCount...newCount - 1).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                }

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
        self.expandedIndexPath = nil
        self.tableView.reloadData()
    }
}

extension SearchTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        if let location = locations.first {
            self.currentLocation = location
        }
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchBar.resignFirstResponder()

            self.resetSearch()
            self.query = searchText
            self.search()
        }
    }
}

extension SearchTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return self.tours?.count == 0
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIcon(name: .search, textColor: UIColor(hexString: "#AAAAAA"), size: CGSize(width: 80, height: 80))
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "NO RESULTS"

        let attributes: [String : Any] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 24)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#AAAAAA"),
            NSKernAttributeName: UI.LabelCharacterSpacing as ImplicitlyUnwrappedOptional<AnyObject>
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Modify your search terms\nand try again!"

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
