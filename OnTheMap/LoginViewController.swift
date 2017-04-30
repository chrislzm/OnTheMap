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
    override var activityIndicatorTag: Int { return 1 }
    
    // MARK: Lifecycle
    
    @IBAction func loginButtonPressed(_ sender: Any) {

        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayAlertWithOKButton("Login Failed","Email or password empty")
        } else {
            // Start animation
            startActivityIndicator()
            
            OTMClient.sharedInstance().loginWith(username: emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                DispatchQueue.main.async {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayAlertWithOKButton("Login Failed",errorString!)
                    }
                    
                    // Stop Animation
                    self.stopActivityIndicator()
                }
            }
        }
    }
    
    // MARK: Login
    
    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "OnTheMapTabController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
}

