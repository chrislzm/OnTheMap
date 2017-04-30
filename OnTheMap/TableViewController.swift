//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

// MARK: - WatchlistViewController: UIViewController

class TableViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    var students = [StudentInformation]()

    // MARK: Actions
    @IBAction func refreshButtonPressed(_ sender: Any) {
        let mapViewController = self.parent!.parent!.childViewControllers[0].childViewControllers[0] as! MapViewController
        mapViewController.refreshStudentLocations()
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        // Get the update list of students
        students = getStudents()
    }

    func refreshTableView() {
        // Copy the updated array of memes
        students = getStudents()
        
        // Force reload data
        tableView.reloadData()
    }
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "TableViewCell"
        let student = students[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell?.textLabel!.text = "\(student.firstName) \(student.lastName)"
        cell?.detailTextLabel?.text = student.mediaURL
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[(indexPath as NSIndexPath).row]
        let app = UIApplication.shared
        if let url = URL(string: student.mediaURL) {
            app.open(url,options: [:],completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
