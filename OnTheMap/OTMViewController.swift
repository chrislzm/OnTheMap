//
//  Extensions.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

// MARK: UIViewController extension

class OTMViewController: UIViewController {
    
    var activityIndicatorTag: Int { return Int.max }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.willLoadFromNetwork(_:)), name: Notification.Name("willLoadStudentInformation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.didLoadFromNetwork(_:)), name: Notification.Name("didLoadStudentInformation"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.willLoadFromNetwork(_:)), name: Notification.Name("willLoadNonStudentData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.didLoadFromNetwork(_:)), name: Notification.Name("didLoadNonStudentData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OTMViewController.didUpdateStudentInformation(_:)), name: Notification.Name("didUpdateStudentInformation"), object: nil)
        
        loadStudentLocations()
    }
    
    // Returns the current saved memes array
    func getStudentInformation() -> [StudentInformation] {
        return (UIApplication.shared.delegate as! AppDelegate).students
    }
    
    // MARK: Load student locations and refresh mapView
    
    func loadStudentLocations() {
        
        // Send notification student data will load
        NotificationCenter.default.post(name: Notification.Name("willLoadStudentInformation"), object: nil)
        
        // Update recent student locations
        OTMClient.sharedInstance().updateRecentStudentLocations() { (success, errorString) in
            if (!success) {
                DispatchQueue.main.async {
                    self.displayErrorAlert(errorString!)
                }
            }
            
            DispatchQueue.main.async {
                // Send notification student data did load
                NotificationCenter.default.post(name: Notification.Name("didLoadStudentInformation"), object: nil)
            }
            
        }
    }
    
    func postStudentLocation() {
        
        // Send notification will confirm overwrite
        NotificationCenter.default.post(name: Notification.Name("willLoadNonStudentData"), object: nil)

        OTMClient.sharedInstance().doesStudentLocationAlreadyExist() { (exists,error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayErrorAlert(error)
                } else if exists {
                    self.displayConfirmOverwriteAlert()
                } else {
                    self.showAddLocationViewController()
                }
                
                // Send notification did confirm overwrite
                NotificationCenter.default.post(name: Notification.Name("didLoadNonStudentData"), object: nil)
            }
        }
    }

    func logout() {
        OTMClient.sharedInstance().logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayAlertWithOKButton(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func displayErrorAlert(_ errorString: String) {
        let alert = UIAlertController(title: "Error Loading Data", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
    
    func willLoadFromNetwork(_ notification:Notification) {
        startLoadingAnimation()
    }
    
    func didLoadFromNetwork(_ notification:Notification) {
        stopLoadingAnimation()
    }
    
    func didUpdateStudentInformation(_ notification:Notification) {
        loadStudentLocations()
    }
    
    func startLoadingAnimation() {
        
        //Create the activity indicator
        
        let activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        self.view.addSubview(activityIndicator)
        
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.alpha = 0.3
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        //Add the tag so we can find the view in order to remove it later
        
        activityIndicator.tag = self.activityIndicatorTag
        
        //Set the location
        
        //activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        
        //Start animating and add the view
        activityIndicator.startAnimating()
        
    }
    
    func stopLoadingAnimation() {
        
        //Here we find the `UIActivityIndicatorView` and remove it from the view
        
        if let activityIndicator = self.view.subviews.filter(
            { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }

}
