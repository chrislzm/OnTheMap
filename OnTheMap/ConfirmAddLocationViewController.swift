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

    @IBOutlet weak var mapView: MKMapView!
    
    var latitude:Double?
    var longitude:Double?
    
    override func viewWillAppear(_ animated: Bool) {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
        mapView.setRegion(viewRegion, animated: true)
    }
    
    @IBAction func pressedFinishButton(_ sender: Any) {
        
    }

}
