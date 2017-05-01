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
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: Actions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        OTMClient.sharedInstance().logout()
        completeLogout()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loadStudentLocations()
    }
    
    @IBAction func postInformationButtonPressed(_ sender: Any) {
        postStudentLocation()
    }
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 2 }
    var mapViewAnnotations = [MKPointAnnotation]()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.refreshButtonPressed(_:)), name: Notification.Name("refreshButtonPressed"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.postInformationButtonPressed(_:)), name: Notification.Name("postInformationButtonPressed"), object: nil)
        
        loadStudentLocations()
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
    
    func loadStudentLocations() {
        
        // Send notification student data will load
        NotificationCenter.default.post(name: Notification.Name("studentDataWillLoad"), object: nil)
        
        // Start animations while loading student locations
        startActivityIndicator()
        
        // Update recent student locations
        OTMClient.sharedInstance().updateRecentStudentLocations() { (success, errorString) in
            if (!success) {
                DispatchQueue.main.async {
                    self.displayErrorAlert(errorString!)
                }
            }

            DispatchQueue.main.async {
                // Send notification student data did load
                NotificationCenter.default.post(name: Notification.Name("studentDataDidLoad"), object: nil)
                self.stopActivityIndicator()
                self.refreshMapView()
            }
            
        }
    }
    
    func postStudentLocation() {
        
        // Send notification will confirm overwrite
        NotificationCenter.default.post(name: Notification.Name("willConfirmLocationOverwrite"), object: nil)
        
        startActivityIndicator()
        
        OTMClient.sharedInstance().doesStudentLocationAlreadyExist() { (exists,error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayErrorAlert(error)
                } else if exists {
                    self.displayConfirmOverwriteAlert()
                } else {
                    self.showAddLocationViewController()
                }
                
                // Send notification did confirm overwrite
                NotificationCenter.default.post(name: Notification.Name("didConfirmLocationOverwrite"), object: nil)
                
                self.stopActivityIndicator()
            }
        }
    }
    
    func refreshMapView() {
        var updatedMapViewAnnotations = [MKPointAnnotation]()
        
        for studentInformation in self.getStudents() {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
            annotation.coordinate = coordinate
            annotation.title = "\(studentInformation.firstName) \(studentInformation.lastName)"
            annotation.subtitle = studentInformation.mediaURL
            
            updatedMapViewAnnotations.append(annotation)
        }
        
        mapView.removeAnnotations(self.mapViewAnnotations)
        mapView.addAnnotations(updatedMapViewAnnotations)
        mapViewAnnotations = updatedMapViewAnnotations
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
    
    private func displayConfirmOverwriteAlert() {
        let alert = UIAlertController(title: "Overwrite location?", message: "You already saved a location. Would you like to overwrite it?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (uiActionAlert) in
                self.showAddLocationViewController()
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAddLocationViewController() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddLocationNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
}
