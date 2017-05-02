//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

// MARK: - WatchlistViewController: UIViewController

class TableViewController: OTMViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 3 }
    var students:[StudentInformation]?                   // Stores student information for the TableView
    
    // MARK: Actions
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loadStudentLocations()
    }
    
    @IBAction func postInformationButtonPressed(_ sender: Any) {
        postStudentLocation()
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {
        logout()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.didLoadStudentInformation(_:)), name: Notification.Name("didLoadStudentInformation"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the updated list of students
        students = getStudentInformation()
    }

    func didLoadStudentInformation(_ notification:Notification) {
        // Copy the updated array of memes
        students = getStudentInformation()
        
        // Reload data
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "TableViewCell"
        let student = students![(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell?.textLabel!.text = "\(student.firstName) \(student.lastName)"
        cell?.detailTextLabel?.text = student.mediaURL
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students![(indexPath as NSIndexPath).row]
        let app = UIApplication.shared
        if let url = URL(string: student.mediaURL) {
            app.open(url,options: [:],completionHandler: nil)
        }
    }
}
