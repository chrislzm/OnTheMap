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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    @IBAction func logoutButtonPressed(_ sender: Any) {
        OTMClient.sharedInstance().logout()
        completeLogout()
    }
    
    // MARK: Properties
    var mapViewAnnotations = [MKPointAnnotation]()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshStudentLocations()
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
    
    // MARK: Load student locations and refresh mapView
    
    private func refreshStudentLocations() {
        
        // Start animation while loading student locations
        activityView.startAnimating()
        
        // Remove any existing annotations
        self.mapView.removeAnnotations(mapViewAnnotations)
        
        // Update recent student locations
        OTMClient.sharedInstance().updateRecentStudentLocations() { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.displayError(error)
                }
            }
            
            self.mapViewAnnotations = [MKPointAnnotation]()
            
            for studentInformation in self.getStudents() {
                let annotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2D(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
                annotation.coordinate = coordinate
                annotation.title = "\(studentInformation.firstName) \(studentInformation.lastName)"
                annotation.subtitle = studentInformation.mediaURL
                
                self.mapViewAnnotations.append(annotation)
            }
            
            DispatchQueue.main.async {

                self.mapView.addAnnotations(self.mapViewAnnotations)
                self.activityView.stopAnimating()
            }
            
        }
    }
    
    // MARK: Logout
    
    private func completeLogout() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func displayError(_ error: NSError) {
        let errorString = error.userInfo[NSLocalizedDescriptionKey].debugDescription
        let alert = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
