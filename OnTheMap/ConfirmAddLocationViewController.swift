//
//  ConfirmAddLocationViewController.swift
//  OnTheMap
//
//  Controller for the Confirm Add Location scene
//
//  Created by Chris Leung on 4/30/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit
import MapKit

class ConfirmAddLocationViewController:OTMViewController {

    // MARK: Properties
    override var activityIndicatorTag: Int { return 4 }
    var latitude:Double?
    var longitude:Double?
    var mapString:String?
    var mediaURL:String?
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Actions
    @IBAction func pressedFinishButton(_ sender: Any) {
        startLoadingAnimation()

        // Have the OTM Client save (or update) the pin
        OTMClient.sharedInstance().saveStudentLocation(mapString!, mediaURL!, latitude!, longitude!) { (success, errorString) in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                if success {
                    NotificationCenter.default.post(name: Notification.Name("didUpdateStudentInformation"), object: nil)
                    self.navigationController!.dismiss(animated: true, completion: nil)
                } else {
                    self.displayAlertWithOKButton("Update Failed", errorString!)
                }
            }
        }
    }

    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Add the geocoded location as an annotation to the map
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // Set the MapView to a 1km * 1km box around the geocoded location
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
        mapView.setRegion(viewRegion, animated: true)
    }
    

}
