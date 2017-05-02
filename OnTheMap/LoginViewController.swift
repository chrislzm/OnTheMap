//
//  ViewController.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: OTMViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Properties
    override var activityIndicatorTag: Int { return 1 }
    
    // MARK: Actions
    @IBAction func loginButtonPressed(_ sender: Any) {

        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayAlertWithOKButton("Login Failed","Email or password empty")
        } else {
            // Start animation
            startLoadingAnimation()
            
            OTMClient.sharedInstance().loginWithUdacity(userId: emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                DispatchQueue.main.async {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayAlertWithOKButton("Login Failed",errorString!)
                    }
                    // Stop Animation
                    self.stopLoadingAnimation()
                }
            }
        }
    }
    @IBAction func loginWithFacebookPressed(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.displayAlertWithOKButton("Facebook Login Failed", error.localizedDescription)
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                // Start animation
                self.startLoadingAnimation()
    
                OTMClient.sharedInstance().completeLoginWithFacebook(accessToken.authenticationToken) { (success, errorString) in
                    DispatchQueue.main.async {
                        // Stop Animation
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
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        emailTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.returnKeyType = UIReturnKeyType.done
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // Dismisses keyboard when we hit enter/return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Login
    
    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "OnTheMapTabController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
}

