//
//  ConfirmAddLocationViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/30/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit
import MapKit

class ConfirmAddLocationViewController:UIViewController {

    // MARK: Properties
    override var activityIndicatorTag: Int { return 4 }
    var latitude:Double?
    var longitude:Double?
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
        mapView.setRegion(viewRegion, animated: true)
    }
    
    @IBAction func pressedFinishButton(_ sender: Any) {
        startActivityIndicator()
        
        OTMClient.sharedInstance().updateStudentLocation() { (success, errorString) in
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                if success {
                    NotificationCenter.default.post(name: Notification.Name("refreshStudentInformation"), object: nil)
                    self.navigationController!.dismiss(animated: true, completion: nil)
                } else {
                    self.displayAlertWithOKButton("Update Failed", errorString!)
                }
            }
        }
    }

}
