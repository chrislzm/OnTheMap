//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/29/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import CoreLocation
import UIKit

class AddLocationViewController:UIViewController {
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 4 }
    
    // MARK: Outlets
    @IBOutlet weak var locationTextView: UITextField!
    @IBOutlet weak var websiteTextView: UITextField!
    
    // MARK: Actions
    @IBAction func findLocationButtonPressed(_ sender: Any) {
        if locationTextView.text!.isEmpty {
            displayAlertWithOKButton("Location Is Empty","Please enter a location")
        } else if websiteTextView.text!.isEmpty {
            displayAlertWithOKButton("Website Is Empty","Please enter a website")
        } else if !validUrl(urlString: websiteTextView.text!) {
            displayAlertWithOKButton("Invalid Website","Please enter a valid website address beginning with http(s)://")
        } else {
            startActivityIndicator()
            
            OTMClient.sharedInstance().geocode(locationTextView.text!) { (latitude,longitude,errorString) in
                
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                
                    if let errorString = errorString {
                        self.displayAlertWithOKButton("Unable to Find Location", errorString)
                    } else {
                        // Grab the Confirm Add ViewController from Storyboard
                        let confirmAddLocationViewController = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmAddLocationViewController") as! ConfirmAddLocationViewController
                        
                        // Populate view controller with data
                        confirmAddLocationViewController.latitude = latitude!
                        confirmAddLocationViewController.longitude = longitude!
                        
                        // Present the view controller using navigation
                        self.navigationController!.pushViewController(confirmAddLocationViewController, animated: true)
                    }
                }
            }
            
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}
