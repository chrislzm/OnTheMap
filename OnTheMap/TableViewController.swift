//
//  TableViewController.swift
//  OnTheMap
//
//  Controller for the TableView scene
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

class TableViewController: OTMViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 3 }
    var students = [StudentInformation]()  // Stores student information for the TableView
    
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

        // Refresh our TableView if new student information was loaded from the network
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.didLoadStudentInformation(_:)), name: Notification.Name("didLoadStudentInformation"), object: nil)
    }

    func didLoadStudentInformation(_ notification:Notification) {
        // Copy the updated array of student information
        students = getStudentInformation()
        
        // Reload data
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate and UITableViewDataSource methods

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
