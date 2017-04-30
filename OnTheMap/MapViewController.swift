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
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: Actions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        OTMClient.sharedInstance().logout()
        completeLogout()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        refreshStudentLocations()
    }
    
    // MARK: Properties
    var mapViewAnnotations = [MKPointAnnotation]()
    var tableViewController:TableViewController?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Now that the view hierarchy is loaded, initialize reference to tableViewController
        tableViewController = self.parent!.parent!.childViewControllers[1].childViewControllers[0] as? TableViewController
        
        // Make it load
        tableViewController!.loadViewIfNeeded()

        // So that we can animate the activity view indicator there
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
    
    func refreshStudentLocations() {
        
        // Start animations while loading student locations
        startAllActivityViewAnimations()
        
        // Update recent student locations
        OTMClient.sharedInstance().updateRecentStudentLocations() { (success, errorString) in
            if (!success) {
                DispatchQueue.main.async {
                    self.displayErrorAlert(errorString!)
                }
            }
            
            var updatedMapViewAnnotations = [MKPointAnnotation]()
            
            for studentInformation in self.getStudents() {
                let annotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2D(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
                annotation.coordinate = coordinate
                annotation.title = "\(studentInformation.firstName) \(studentInformation.lastName)"
                annotation.subtitle = studentInformation.mediaURL
                
                updatedMapViewAnnotations.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapViewAnnotations)
                self.mapView.addAnnotations(updatedMapViewAnnotations)
                self.stopAllActivityViewAnimations()
                
                // Save a copy so that we can remove them later if needed
                self.mapViewAnnotations = updatedMapViewAnnotations
            }
            
        }
    }
    
    // MARK: Logout
    
    private func completeLogout() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func displayErrorAlert(_ errorString: String) {
        let alert = UIAlertController(title: "Error Loading Data", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func startAllActivityViewAnimations() {
        activityView.startAnimating()
        animateTableViewControllerActivityView(true)
    }
    
    private func stopAllActivityViewAnimations() {
        activityView.stopAnimating()
        animateTableViewControllerActivityView(false)
    }
    
    private func animateTableViewControllerActivityView(_ animate:Bool) -> Void {
        if let tableViewActivityView = tableViewController!.activityView {
            if(animate) {
                tableViewActivityView.startAnimating()
            } else {
                tableViewActivityView.stopAnimating()
            }
        }
    }
}
