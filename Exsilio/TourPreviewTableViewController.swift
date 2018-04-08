//
//  TourPreviewTableViewController.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/8/18.
//

import UIKit
import SwiftyJSON

final class TourPreviewTableViewController: UITableViewController {
    var tour: JSON!

    var waypoints: [JSON] {
        return tour["waypoints"].array ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = tour["name"].string

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(takeTour))

        cacheAllImages()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypoints.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TourPreviewTableViewCell", for: indexPath) as! TourPreviewTableViewCell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TourPreviewTableViewCell {
            cell.waypoint = waypoints[indexPath.row].dictionaryObject
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }

    private func cacheAllImages() {
        waypoints.forEach({ waypoint in
            if let urlString = waypoint["image_url"].string {
                if urlString != API.MissingImagePath {
                    let urlRequest = URLRequest(url: URL(string: urlString)!)
                    CurrentTourSingleton.sharedInstance.imageDownloader.download(urlRequest, completion: nil)
                }
            }
        })
    }

    @objc private func takeTour() {
        CurrentTourSingleton.sharedInstance.loadTourFromJSON(self.tour)
        let vc = storyboard?.instantiateViewController(withIdentifier: "ActiveTourViewController") as! ActiveTourViewController
        present(vc, animated: true, completion: nil)
    }
}

final class TourPreviewTableViewCell: UITableViewCell {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var waypointLabel: UILabel!

    var waypoint: Waypoint? {
        didSet {
            if let waypoint = waypoint {
                var text = ""

                if let name = waypoint["name"] as? String {
                    text = name
                }

                if let description = waypoint["description"] as? String, !description.isEmpty {
                    text = "\(text)\n\n\(description)"
                }

                waypointLabel.text = text

                if let imageURLString = waypoint["image_url"] as? String, let imageURL = URL(string: imageURLString) {
                    backgroundImageView.af_setImage(withURL: imageURL)
                }
            } else {
                backgroundImageView.af_cancelImageRequest()
                backgroundImageView.image = nil
                waypointLabel.text = nil
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        waypoint = nil
    }
}
