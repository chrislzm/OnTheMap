//
//  OTMViewController
//  OnTheMap
//
//  Superclass that implements shared methods for all OTM ViewController classes. Also ensures that the Activity View Indicators in different ViewControllers are synced whenever we begin/end loading data from the network. This is accomplished using notifications.
//
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

// MARK: OTMViewController

class OTMViewController: UIViewController {
    
    // MARK: Properties
    static let AVI_ALPHA:CGFloat = 0.3  // Alpha (transparancy) value for Activity View Indicators
    var activityIndicatorTag: Int { return Int.max }  // Each ViewController must override this with a unique tag value beginning with 1, so that it can instantiate its own unique Activity View Indicator
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observers for when student information will load, and did load
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.willLoadFromNetwork(_:)), name: Notification.Name("willLoadStudentInformation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.didLoadFromNetwork(_:)), name: Notification.Name("didLoadStudentInformation"), object: nil)
        
        // Observers for when other data will load, and did load
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.willLoadFromNetwork(_:)), name: Notification.Name("willLoadOtherData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.didLoadFromNetwork(_:)), name: Notification.Name("didLoadOtherData"), object: nil)
        
        // Observer for when student information got updated (e.g. we saved a pin/updated a pin)
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.didUpdateStudentInformation(_:)), name: Notification.Name("didUpdateStudentInformation"), object: nil)
        
        // Initial load of student locations
        loadStudentLocations()
    }
    
    // MARK: Student Information Methods

    // Get student information from our model
    func getStudentInformation() -> [StudentInformation] {
        return (UIApplication.shared.delegate as! AppDelegate).students
    }

    // Handles user request to [re]load student locations
    func loadStudentLocations() {
        
        NotificationCenter.default.post(name: Notification.Name("willLoadStudentInformation"), object: nil)
        
        // Use the OTMClient to get the most updated student locations. It will automatically save them to our model.
        OTMClient.sharedInstance().updateRecentStudentLocations() { (success, errorString) in
            if (!success) {
                DispatchQueue.main.async {
                    self.displayAlertWithOKButton("Error Loading Data",errorString!)
                }
            }
            
            DispatchQueue.main.async {
                // Send notification student data did load
                NotificationCenter.default.post(name: Notification.Name("didLoadStudentInformation"), object: nil)
            }
            
        }
    }
    
    // Handles user request to post/update their student location
    func postStudentLocation() {
        
        NotificationCenter.default.post(name: Notification.Name("willLoadOtherData"), object: nil)

        // Use the OTMClient to check whether the student already has a location saved
        OTMClient.sharedInstance().doesStudentLocationAlreadyExist() { (exists,error) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("didLoadOtherData"), object: nil)

                if let error = error {
                    self.displayAlertWithOKButton("Error Loading Data",error)
                } else if exists {
                    // If we already have a saved location, confirm with the user we want to overwrite it
                    self.displayConfirmOverwriteAlert()
                } else {
                    // If we don't already have a saved location, go to the next step
                    self.showAddLocationViewController()
                }
            }
        }
    }

    // Handles user request to logout of app
    func logout() {
        OTMClient.sharedInstance().logout()
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Helper methods
    
    // Displays an alert with a single OK button, takes a title and message as arguemnts
    func displayAlertWithOKButton(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // Displays alert confirmation dialog, confirming user wants to overwrite their previously saved location
    private func displayConfirmOverwriteAlert() {
        let alert = UIAlertController(title: "Overwrite location?", message: "You already have a saved location. Would you like to overwrite it?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (uiActionAlert) in
            self.showAddLocationViewController()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showAddLocationViewController() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddLocationNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }

    // MARK: Observer methods -- Syncs activity view indicators across multiple OTMViewControllers
    
    func willLoadFromNetwork(_ notification:Notification) {
        startLoadingAnimation()
    }
    
    func didLoadFromNetwork(_ notification:Notification) {
        stopLoadingAnimation()
    }
    
    func didUpdateStudentInformation(_ notification:Notification) {
        loadStudentLocations()
    }

    // MARK: Shared Activity View Indicator methods
    
    func startLoadingAnimation() {
        
        // Programmatically create the activity indicator
        let activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        self.view.addSubview(activityIndicator)
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.alpha = OTMViewController.AVI_ALPHA
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        
        // Add the unique tag so we can find this view in order to remove it later
        activityIndicator.tag = self.activityIndicatorTag
        
        // Start animating and add the view
        activityIndicator.startAnimating()
        
    }
    
    func stopLoadingAnimation() {
        
        // Find our unique activity indicator and remove it from the view
        if let activityIndicator = self.view.subviews.filter(
            { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}
