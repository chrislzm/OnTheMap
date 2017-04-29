//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//


import UIKit

class MapViewController: UIViewController {

    @IBAction func logoutButtonPressed(_ sender: Any) {
        OTMClient.sharedInstance().logout()
        completeLogout()
    }
    
    // MARK: Logout
    
    private func completeLogout() {
        self.dismiss(animated: true, completion: nil)
    }
}
