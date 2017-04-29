//
//  ViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    // MARK: Properties
    
    // MARK: Lifecycle
    
    @IBAction func loginButtonPressed(_ sender: Any) {

        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayError("Email or password empty")
        } else {
            // Start animation
            activityView.startAnimating()
            
            OTMClient.sharedInstance().loginWith(username: emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                DispatchQueue.main.async {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayError(errorString)
                    }
                    
                    // Stop Animation
                    self.activityView.stopAnimating()
                }
            }
        }
    }
    
    // MARK: Login
    
    private func completeLogin() {
        debugTextLabel.text = ""
        let controller = storyboard!.instantiateViewController(withIdentifier: "OnTheMapTabController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
    
    private func displayError(_ errorString: String?) {
        let alert = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

