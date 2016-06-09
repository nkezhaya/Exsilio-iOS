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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavigation()

        form +++ Section("Sorting")
            <<< PickerInlineRow<String>("sort") { row in
                row.title = "Sort By"
                row.options = ["Relevance", "Distance"]
                row.value = "Relevance"
            }

            +++ Section("Distance")
            <<< PickerInlineRow<String>("distance") { row in
                row.title = "Distance From Me"
                row.options = ["1 mile", "2 miles", "5 miles", "10 miles"]
            }
    }

    func showNavigation() {
        let navBarHeight = CGFloat(44)
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, navBarHeight + 20))

        navigationBar.backgroundColor = UIColor.whiteColor()

        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Filters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .Done,
                                                            target: self,
                                                            action: #selector(done))

        navigationBar.items = [navigationItem]

        self.view.addSubview(navigationBar)
        self.tableView?.contentInset = UIEdgeInsetsMake(navBarHeight, 0, 0, 0)
    }

    func done() {
        if let searchVC = self.delegate {
            searchVC.filters = form.values()
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}