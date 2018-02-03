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
import SCLAlertView
import SVProgressHUD

class ToursTableViewController: UITableViewController {
    var tours: JSON = JSON([])

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tabBarItem.image = UI.BarButtonIcon(.mapO)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UI.PlusIcon,
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(newTour))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        self.tableView.register(UINib(nibName: "TourTableViewCell", bundle: nil), forCellReuseIdentifier: "TourTableViewCell")

        self.tableView.tableFooterView = UIView()
        self.tableView.isOpaque = false
        self.tableView.backgroundView = nil

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func refresh() {
        SVProgressHUD.show()

        Alamofire.request("\(API.URL)\(API.ToursPath)", method: .get, headers: API.authHeaders()).responseJSON { response in
            self.refreshControl?.endRefreshing()
            SVProgressHUD.dismiss()

            switch response.result {
            case .success(let json):
                self.tours = JSON(json)
                self.tableView.reloadData()
                break
            default:
                break
            }
        }
    }

    func newTour() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateTourNavigationController") as! CreateTourNavigationController
        vc.toursTableViewController = self

        self.present(vc, animated: true, completion: nil)
    }

    func editTourAtIndexPath(_ indexPath: IndexPath) {
        CurrentTourSingleton.sharedInstance.loadTourFromJSON(self.tours[indexPath.row])

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WaypointsTableViewController") as! WaypointsTableViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tours.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TourTableViewCell", for: indexPath) as! TourTableViewCell
        cell.updateWithTour(self.tours[indexPath.row])

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        let tour = self.tours[indexPath.row]

        let alertController = UIAlertController(title: "Manage Tour", message: "What would you like to do with this tour?", preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Open Tour", style: .default, handler: { _ in self.previewTour(tour: tour) }))
        alertController.addAction(UIAlertAction(title: "Edit Tour", style: .default, handler: { _ in self.editTourAtIndexPath(indexPath) }))

        let published = self.tours[indexPath.row]["published"].boolValue
        let publishedTitle = published ? "Unpublish Tour" : "Publish Tour"
        alertController.addAction(UIAlertAction(title: publishedTitle, style: .default, handler: { _ in self.publishTourAtIndexPath(indexPath) }))

        alertController.addAction(UIAlertAction(title: "Clone Tour", style: .default, handler: { _ in self.cloneTourAtIndexPath(indexPath) }))
        alertController.addAction(UIAlertAction(title: "Delete Tour", style: .destructive, handler: { _ in self.deleteTourAtIndexPath(indexPath) }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func previewTour(tour: JSON) {
        if tour["waypoints_count"].int! < 2 {
            SCLAlertView().showError("Error", subTitle: "Whoops! This tour does not have enough waypoints to preview yet. Swipe right to edit.")
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TourPreviewViewController") as! TourPreviewViewController
            vc.tour = tour
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func publishTourAtIndexPath(_ indexPath: IndexPath) {
        let tour = self.tours[indexPath.row]
        if let id = tour["id"].int {
            let published = !(tour["published"].bool == true)
            let params = ["tour[published]": "\(published)"]

            Alamofire.request("\(API.URL)\(API.ToursPath)/\(id)", method: .put, parameters: params, headers: API.authHeaders()).responseJSON { response in
                switch response.result {
                case .success(let jsonString):
                    let json = JSON(jsonString)
                    if let errors = json["errors"].string {
                        SCLAlertView().showError("Whoops!", subTitle: errors, closeButtonTitle: "OK")
                    } else {
                        self.tours[indexPath.row]["published"] = JSON(published)
                    }
                    break
                default:
                    break
                }
            }
        }
    }

    private func cloneTourAtIndexPath(_ indexPath: IndexPath) {
        guard let id = self.tours[indexPath.row]["id"].int else { return }
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        let name = alert.addTextField("Enter the new tour name")
        alert.addButton("Clone") {
            guard let name = name.text else { return }

            let params = ["tour[name]": name]
            SVProgressHUD.show()
            Alamofire.request("\(API.URL)\(API.ToursPath)/\(id)/clone", method: .post, parameters: params, headers: API.authHeaders()).responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success(let jsonString):
                    let json = JSON(jsonString)
                    if let errors = json["errors"].string {
                        SCLAlertView().showError("Whoops!", subTitle: errors, closeButtonTitle: "OK")
                    } else {
                        self.refresh()
                    }
                    break
                default:
                    break
                }
            }
        }
        alert.addButton("Cancel", action: {})
        alert.showEdit("Clone Tour", subTitle: "")
    }

    private func deleteTourAtIndexPath(_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Delete Tour", message: "Are you sure you want to delete this tour?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            if let id = self.tours[indexPath.row]["id"].int {
                _ = Alamofire.request("\(API.URL)\(API.ToursPath)/\(id)", method: .delete, headers: API.authHeaders())

                self.tours.arrayObject?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        })
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ToursTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return self.tours.count == 0
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "NO TOURS YET"

        let attributes: [String : Any] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 24)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#AAAAAA"),
            NSKernAttributeName: UI.LabelCharacterSpacing as ImplicitlyUnwrappedOptional<AnyObject>
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Create a tour and\nshare it with others!"

        let attributes: [String : Any] = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 18)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#333333")
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }
}
