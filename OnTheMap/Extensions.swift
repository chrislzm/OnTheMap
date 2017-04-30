//
//  Extensions.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

// MARK: UIViewController extension

extension UIViewController {
    
    var activityIndicatorTag: Int { return Int.max }
    
    // Returns the current saved memes array
    func getStudents() -> [StudentInformation] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.students
    }
    
    func startActivityIndicator() {
        
        //Create the activity indicator
        
        let activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        self.view.addSubview(activityIndicator)
        
        //let margins = self.view.layoutMarginsGuide
        
        //activityIndicator.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        //activityIndicator.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        //activityIndicator.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        //activityIndicator.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
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

    func stopActivityIndicator() {
        
        //Here we find the `UIActivityIndicatorView` and remove it from the view
        
        if let activityIndicator = self.view.subviews.filter(
            { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    func displayAlertWithOKButton(_ errorTitle: String, _ errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
