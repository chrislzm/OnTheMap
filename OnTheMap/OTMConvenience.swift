//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

// MARK: - OTMClient (Convenient Resource Methods)

import Foundation
import UIKit
import FBSDKCoreKit
import FacebookLogin

extension OTMClient {
    
    // Handles Udacity auth flow, verifies we are logged in with a session ID, and retrieves the user's first name and last name
    func loginWithUdacity(userId:String, password:String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Create and run HTTP request to authenticate the user's email and password with Udacity */
        let httpBody = "{\"udacity\": {\"username\": \"\(userId)\", \"password\": \"\(password)\"}}"
        let httpHeaderValues = [("application/json","Accept"),
                                ("application/json","Content-Type")]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPost, OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacitySession, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 2. Check for error response from Udacity */
            if let error = error {
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 3. Verify we have obtained a Session ID from Udacity and are logged in */
            guard let response = results as? [String:AnyObject], let session = response[OTMClient.JSONResponseKeys.UdacitySession] as? [String:AnyObject], let sessionID = session[OTMClient.JSONResponseKeys.UdacitySessionID] as? String else {
                // TODO: Delete debug statement
                print("Could not find \(OTMClient.JSONResponseKeys.UdacitySession) or \(OTMClient.JSONResponseKeys.UdacitySessionID) in \(String(describing: results))")
                completionHandler(false, "Error creating session")
                return
            }
            
            // TODO: Delete session ID Debug statenent
            print("Udacity Login Success! Session ID = \(sessionID)")
            
            /* 4. Save the username and session ID */
            self.userId = userId
            self.userSessionId = sessionID

            /* 5. Retrieve the user's first and last name from Udacity and complete the login */
            self.retrieveNameAndCompleteLogin(completionHandler)
        }
    }
    
    func retrieveNameAndCompleteLogin(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        /* 1. Create and run HTTP request to retrieve user's first name and last name */
        
        let getUserDataMethod = substituteKey(OTMClient.Methods.UdacityUserData, key: OTMClient.URLKeys.UdacityUserId, value: userId!)!
        
        let _ = self.taskForHTTPMethod(OTMClient.Constants.HttpGet, OTMClient.Constants.UdacityApiHost, getUserDataMethod, apiParameters: nil, valuesForHTTPHeader: nil, httpBody: nil) { (results, error) in
            
            /* 2. Check for error response from Udacity */
            if let error = error {
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 3. Verify we have obtained a the first name and last name */
            guard let response = results as? [String:AnyObject], let user = response[OTMClient.JSONResponseKeys.UdacityUser] as? [String:AnyObject], let firstName = user[OTMClient.JSONResponseKeys.UdacityFirstName] as? String, let lastName = user[OTMClient.JSONResponseKeys.UdacityLastName] as? String else {
                // TODO: Delete debug statement
                print("Could not find one or more of keys \(OTMClient.JSONResponseKeys.UdacityUser), \(OTMClient.JSONResponseKeys.UdacityFirstName), \(OTMClient.JSONResponseKeys.UdacityLastName) in \(String(describing: results))")
                completionHandler(false, "Error retrieving user data. If you are using Facebook to login, your Udacity email address must be the same as your Facebook primary email address.")
                return
            }
            
            /* 4. Save the user's first and last name */
            // TODO: Delete debug print statement
            print("Retrieved user data. First name: \(firstName), Last name: \(lastName)")
            self.userFirstName = firstName
            self.userLastName = lastName
            
            /* 5. Run the completion handler and return*/
            completionHandler(true, nil)
        }

    }
    func completeLoginWithFacebook (_ accessToken:String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        /* 1. Create and run HTTP request to get the session ID from Udacity */
        let httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
        let httpHeaderValues = [("application/json","Accept"),
                                ("application/json","Content-Type")]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPost, OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacitySession, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 2. Check for error response from Udacity */
            if let error = error {
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 3. Verify we have obtained a Session ID from Udacity and are logged in */
            guard let response = results as? [String:AnyObject], let session = response[OTMClient.JSONResponseKeys.UdacitySession] as? [String:AnyObject], let sessionID = session[OTMClient.JSONResponseKeys.UdacitySessionID] as? String else {
                // TODO: Delete debug statement
                print("Could not find \(OTMClient.JSONResponseKeys.UdacitySession) or \(OTMClient.JSONResponseKeys.UdacitySessionID) in \(String(describing: results))")
                completionHandler(false, "Error creating session")
                return
            }
            
            /* 4. Save the session ID and Facebook access token */
            self.userSessionId = sessionID
            self.userFBAccessToken = accessToken

            // TODO: Delete session ID Debug statenent
            print("Udacity Login Success! Session ID = \(sessionID)")

            /* 5. Now get the user ID from Facebook */
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil) {
                    print("Error: \(String(describing: error))")
                } else {
                    let data = result as! [String : String]
                    
                    /* 6. Save the user ID */
                    self.userId = data["email"]
                    print(data)
                    
                    /* 7. Retrieve the user's first and last name from Udacity (based on email address) and complete the login */
                    self.retrieveNameAndCompleteLogin(completionHandler)
                }
            })
        }
    }
    
    // Logs out of Udacity. This gets run in the background, and whether it's succesful or not, we don't need to let the user know, so there's no completion handler. It "fails gracefully".
    func logout() {
        
        /* 1. Create and run HTTP request to logout from Udacity */
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        var httpHeaderValues:[(String,String)]? = nil
        if let xsrfCookie = xsrfCookie {
            httpHeaderValues = [(xsrfCookie.value, "X-XSRF-TOKEN")]
        }
        
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpDelete, OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacitySession, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: nil) { (results, error) in
            
            /* 2. Check for error response from Udacity */
            if let error = error {
                // TODO: Delete debug statement
                print(error)
                return
            }
            
            /* 3. Verify we have obtained a valid logout response */
            guard let response = results as? [String:AnyObject], let session = response[OTMClient.JSONResponseKeys.UdacitySession] as? [String:AnyObject], let sessionId = session[OTMClient.JSONResponseKeys.UdacitySessionID] as? String else {
                // TODO: Delete debug statement
                print("Could not find \(OTMClient.JSONResponseKeys.UdacitySession) or \(OTMClient.JSONResponseKeys.UdacitySessionID) in \(String(describing: results))")
                return
            }
            
            /* 4. Delete the session ID */
            print("Logged out successfully. Old Session ID: \(self.userSessionId!), Session ID received: \(sessionId)")
        }
        
        /* 5. If we are logged into Facebook, log out  */
        if let _ = userFBAccessToken {
            LoginManager().logOut()
            userFBAccessToken = nil
        }
        
        /* 6. Delete all remaining session data */
        userId = nil
        userSessionId = nil
        userFirstName = nil
        userLastName = nil
        userObjectId = nil
        
        /* 7. Clear the student information from our model */
        (UIApplication.shared.delegate as! AppDelegate).students = [StudentInformation]()
    }
    
    
    // Gets recent locations posted by students
    func updateRecentStudentLocations(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Create and run HTTP request to retrieve recent student locations from Parse */
        let parameters:[String:String] = [OTMClient.ParameterKeys.ParseLimit:OTMClient.ParameterValues.ParseNumStudents,
                                             OTMClient.ParameterKeys.ParseOrder:OTMClient.ParameterValues.ParseUpdatedAt]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpGet, OTMClient.Constants.ParseApiHost, OTMClient.Methods.ParseStudentLocation, apiParameters: parameters, valuesForHTTPHeader: nil, httpBody: nil) { (results, error) in
            
            /* 2. Check for error response from Parse */
            if let error = error {
                // TODO: Delete debug statement
                print(error)
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 3. Extract results */
            guard let results = results?[OTMClient.JSONResponseKeys.ParseResults] as? [[String:AnyObject]] else {
                let error = NSError(domain: "updateRecentStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse student location information. Missing key: \(OTMClient.JSONResponseKeys.ParseResults)"])
                self.handleHttpNSError(error,completionHandler)
                return
            }

            /* 4. Parse results and save the data to the model */
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.students = StudentInformation.studentsFromResults(results)
            
            /* 5. Call the completion handler */
            completionHandler(true, nil)
        }
    }
    
    // Checks if a student location already exists. Error is nil if the request was successful. doesExist will contain the result.
    func doesStudentLocationAlreadyExist(_ completionHandler: @escaping (_ doesExist: Bool, _ errorString: String?) -> Void) {
        /* 1. Create and run HTTP request to retrieve recent student locations from Parse */
        let uniqueKeyParameter = substituteKey(OTMClient.ParameterValues.ParseUniqueKey, key: OTMClient.URLKeys.ParseUniqueKey, value: userId!)!
        let parameters:[String:String] = [OTMClient.ParameterKeys.ParseWhere:uniqueKeyParameter]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpGet, OTMClient.Constants.ParseApiHost, OTMClient.Methods.ParseStudentLocation, apiParameters: parameters, valuesForHTTPHeader: nil, httpBody: nil) { (results, error) in
            
            /* 2. Check for error response from Parse */
            if let error = error {
                // TODO: Delete debug statement
                print(error)
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 3. Extract results */
            guard let results = results?[OTMClient.JSONResponseKeys.ParseResults] as? [[String:AnyObject]] else {
                let error = NSError(domain: "doesStudentLocationAlreadyExist parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse student location information. Missing key: \(OTMClient.JSONResponseKeys.ParseResults)"])
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 4. Return false to the completion handler if no matches */
            if results.count == 0 {
                completionHandler(false, nil)
            } else {
                
                /* 5. Otherwise, save the objectId in case we need to update it later */
                let studentInformation = results[0] 
                
                guard let objectId = studentInformation[OTMClient.JSONResponseKeys.ParseObjectId] as? String else {
                    let error = NSError(domain: "doesStudentLocationAlreadyExist parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse student location information. Missing key: \(OTMClient.JSONResponseKeys.ParseObjectId)"])
                    self.handleHttpNSError(error,completionHandler)
                    return
                }
                
                self.userObjectId = objectId

                /* 6. Return true to the completion handler */
                completionHandler(true, nil)
            }
        }
    }
    
    func addStudentLocation(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        /* 1. Create and run HTTP request to post student location to Parse */
        let httpBody = "{\"uniqueKey\": \"\(userId!)\", \"firstName\": \"\(userFirstName!)\", \"lastName\": \"\(userLastName!)\",\"mapString\": \"Reno, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 39.5296, \"longitude\": -119.8138}"
        let httpHeaderValues = [("application/json","Content-Type")]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPost, OTMClient.Constants.ParseApiHost, OTMClient.Methods.ParseStudentLocation, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 2. Check for error response from Parse */
            if let error = error {
                // TODO: Delete debug statement
                print(error)
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 3. Verify the student location was created */
            guard let _ = results?[OTMClient.JSONResponseKeys.ParseLocationCreated] else {
                let error = NSError(domain: "addStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not add student location. Missing key: \(OTMClient.JSONResponseKeys.ParseLocationCreated)."])
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 4. Return without an error */
            completionHandler(true, nil)
        }
    }
    
    func updateStudentLocation(_ mapString:String, _ mediaURL:String, _ latitude:Double, _ longitude:Double, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Verify we have a Parse objectId that we can update (retrieved in doesStudentLocationAlreadyExist, which was run before we get here)  */
        guard let objectId = self.userObjectId else {
            completionHandler(false,"Unable to retrieve your student information")
            return
        }
        
        /* 2. Create and run HTTP request to update student location in Parse */
        let updateStudentInformationMethod = substituteKey(OTMClient.Methods.ParseUpdateStudentLocation, key: OTMClient.URLKeys.ParseObjectId, value: objectId)!
        let httpHeaderValues = [("application/json","Content-Type")]
        let httpBody = "{\"uniqueKey\": \"\(userId!)\", \"firstName\": \"\(userFirstName!)\", \"lastName\": \"\(userLastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPut, OTMClient.Constants.ParseApiHost, updateStudentInformationMethod, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 2. Check for error response from Parse */
            if let error = error {
                // TODO: Delete debug statement
                print(error)
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 3. Verify the student location was created */
            guard let _ = results?[OTMClient.JSONResponseKeys.ParseUpdatedAt] else {
                let error = NSError(domain: "updateStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not update student location. Missing key: \(OTMClient.JSONResponseKeys.ParseUpdatedAt)"])
                self.handleHttpNSError(error,completionHandler)
                return
            }
            
            /* 4. Return without an error */
            completionHandler(true, nil)
        }
    }
    
    
    private func handleHttpNSError(_ error:NSError,_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        let errorString = error.userInfo[NSLocalizedDescriptionKey].debugDescription

        // TODO: Remove debug statement
        print("handleHTTPError: " + errorString)

        if errorString.contains("timed out") {
            completionHandler(false, "Couldn't reach server (timed out)")
        } else if errorString.contains("Status code returned: 403"){
            completionHandler(false, "Email or password incorrect")
        } else if errorString.contains("Could not parse student location information") {
            completionHandler(false, "Error processing student data")
        } else if errorString.contains("Could not update student location") {
            completionHandler(false, "Error updating your student location")
        } else {
            completionHandler(false, "Try again. Please note that if you are logging in with Facebook, your Udacity email address must be the same as your Facebook email address.")
        }
    }
}
