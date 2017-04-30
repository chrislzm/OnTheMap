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
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 3 }
    var students = [StudentInformation]()
    
    // MARK: Actions
    @IBAction func refreshButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("refreshButtonPressed"), object: nil)
    }
    
    @IBAction func postInformationButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("postInformationButtonPressed"), object: nil)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.willMakeNetworkRequest(_:)), name: Notification.Name("studentDataWillLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.didMakeNetworkRequest(_:)), name: Notification.Name("studentDataDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.willMakeNetworkRequest(_:)), name: Notification.Name("willConfirmLocationOverwrite"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.didMakeNetworkRequest(_:)), name: Notification.Name("didConfirmLocationOverwrite"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get the update list of students
        students = getStudents()
    }
    
    func willMakeNetworkRequest(_ notification:Notification) {
        startActivityIndicator()
    }
    
    func didMakeNetworkRequest(_ notification:Notification) {
        stopActivityIndicator()
        refreshTableView()
    }
    
    //func startActivityViewAnimations

    func refreshTableView() {
        // Copy the updated array of memes
        students = getStudents()
        
        // Reload data
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
}
