//
//  FiltersViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 6/9/16.
//
//

import UIKit
import Eureka

class FiltersViewController: FormViewController {
    var delegate: SearchTableViewController?

    let defaultValues: [String: Any?] = [
        "sort": "Relevance",
        "distance": "1 mile"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavigation()

        form +++ Section("Sorting")
            <<< PickerInlineRow<String>("sort") { row in
                row.title = "Sort By"
                row.options = ["Relevance", "Distance"]
            }

            +++ Section("Distance")
            <<< PickerInlineRow<String>("distance") { row in
                row.title = "Distance From Me"
                row.options = ["1 mile", "2 miles", "5 miles", "10 miles"]
            }

        if let searchVC = self.delegate {
            if searchVC.filters.count > 0 {
                form.setValues(searchVC.filters)
            } else {
                form.setValues(self.defaultValues)
            }
        }
    }

    func showNavigation() {
        let navBarHeight = CGFloat(44)
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, navBarHeight + 20))

        navigationBar.backgroundColor = UIColor.whiteColor()

        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Filters"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset",
                                                           style: .Plain,
                                                           target: self,
                                                           action: #selector(reset))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .Done,
                                                            target: self,
                                                            action: #selector(done))

        navigationBar.items = [navigationItem]

        self.view.addSubview(navigationBar)
        self.tableView?.contentInset = UIEdgeInsetsMake(navBarHeight, 0, 0, 0)
    }

    func reset() {
        form.setValues(self.defaultValues)
        self.tableView?.reloadData()
    }

    func done() {
        if let searchVC = self.delegate {
            searchVC.filters = form.values()
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}