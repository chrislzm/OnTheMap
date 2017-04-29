//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    @IBAction func logoutButtonPressed(_ sender: Any) {
        OTMClient.sharedInstance().logout()
        completeLogout()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Point annotations will be stored in this array
        var annotations = [MKPointAnnotation]()
        
        // Test annotation
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        annotation.coordinate = coordinate
        annotation.title = "Chris Leung"
        annotation.subtitle = "http://chrisleung.com"
        
        annotations.append(annotation)
        
        mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method that respond to taps. Opens the system browser to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!,options: [:],completionHandler: nil)
            }
        }
    }
    
    // MARK: Logout
    
    private func completeLogout() {
        self.dismiss(animated: true, completion: nil)
    }
}
