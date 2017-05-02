//
//  LoginViewController.swift
//  OnTheMap
//
//  Controller for login scene
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: OTMViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 1 }
    
    // MARK: Actions
    
    // Handles user login with Udacity account
    @IBAction func loginButtonPressed(_ sender: Any) {

        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayAlertWithOKButton("Login Failed","Email or password empty")
        } else {
            startLoadingAnimation()

            // Use the OTMClient to attempt login with the given userName and password
            OTMClient.sharedInstance().loginWithUdacity(userId: emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                DispatchQueue.main.async {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayAlertWithOKButton("Login Failed",errorString!)
                    }
                    self.stopLoadingAnimation()
                }
            }
        }
    }
    
    // Handles user login with Facebook account
    @IBAction func loginWithFacebookButtonPressed(_ sender: Any) {
        let loginManager = LoginManager()
        
        // We ask for email address here because we need it to verify the user is actually a Udacity student
        // We ask for public profile access since we'll probably need it in a future version of this app
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.displayAlertWithOKButton("Facebook Login Failed", error.localizedDescription)
                print(error)
            case .cancelled:
                break
            case .success( _, let declinedPermissions, let accessToken):
                if declinedPermissions.contains(FacebookCore.Permission.init(name: "email")) {
                    self.displayAlertWithOKButton("Facebook Login Failed", "You must allow Udacity to access your Facebook email address in order to use this app.")
                    return
                } else {
                    self.startLoadingAnimation()
                    
                    // Use the OTMClient to complete our Facebook login process
                    OTMClient.sharedInstance().completeLoginWithFacebook(accessToken.authenticationToken) { (success, errorString) in
                        DispatchQueue.main.async {
                            self.stopLoadingAnimation()
                            
                            if success {
                                self.completeLogin()
                            } else {
                                self.displayAlertWithOKButton("Login Failed",errorString!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Lifecycle

    // For making sure keyboard disappears when we hit the done button
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.returnKeyType = UIReturnKeyType.done
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // Dismisses keyboard when we hit done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Final step of the login process -- present the main screen of the app
    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "OnTheMapTabController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
}

