//
//  MapViewController.swift
//  OnTheMap
//
//  Controller for the MapView scene
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: OTMViewController, MKMapViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    @IBAction func logoutButtonPressed(_ sender: Any) {
        logout()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loadStudentLocations()
    }
    
    @IBAction func postInformationButtonPressed(_ sender: Any) {
        postStudentLocation()
    }
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 2 }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh our MapView if new student information was loaded from the network
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.didLoadStudentInformation(_:)), name: Notification.Name("didLoadStudentInformation"), object: nil)
    }
    
    // Setup annotation (pin) appearance and behavior on the MapView
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
    
    // Delegate method that respond to taps. Opens the system browser to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!,options: [:],completionHandler: nil)
            }
        }
    }
    
    // Refresh our MapView if new student information was loaded
    func didLoadStudentInformation(_ notification:Notification) {
        var updatedMapViewAnnotations = [MKPointAnnotation]()
        
        // Copy the updated information from the model
        let students = getStudentInformation()
        for studentInformation in students {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
            annotation.coordinate = coordinate
            annotation.title = "\(studentInformation.firstName) \(studentInformation.lastName)"
            annotation.subtitle = studentInformation.mediaURL
            
            updatedMapViewAnnotations.append(annotation)
        }
        
        let oldAnnotations = self.mapView.annotations
        mapView.removeAnnotations(oldAnnotations)
        mapView.addAnnotations(updatedMapViewAnnotations)
    }

}
