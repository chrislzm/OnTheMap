//
//  OTMConvenience.swift
//  OnTheMap
//
//  OTM Client convenience methods - Utilizes OTM core client methods to exchange information with Facebook, Udacity and Parse over the network. Acts as an interface for the ViewController methods to the model.
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FacebookLogin

extension OTMClient {
    
    // Handles Udacity auth flow, verifies we are logged in with a session ID, and retrieves the user's first name and last name
    func loginWithUdacity(userId:String, password:String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Create and run HTTP request to authenticate the userId and password with Udacity */
        let httpBody = generateUdacityLoginJSONWith(userId,password)
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
                completionHandler(false, "Error creating session")
                return
            }
            
            /* 4. Save the username and session ID */
            self.userId = userId
            self.userSessionId = sessionID

            /* 5. Retrieve the user's first and last name from Udacity and complete the login */
            self.retrieveNameAndCompleteLogin(completionHandler)
        }
    }
    
    // [Re]verify the Udacity account by retrieving its first and last name, then complete login process
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
                completionHandler(false, "Error retrieving user data. If you are using Facebook to login, your Udacity email address must be the same as your Facebook primary email address.")
                return
            }
            
            /* 4. Save the user's first and last name */
            self.userFirstName = firstName
            self.userLastName = lastName
            
            /* 5. Run the completion handler and return*/
            completionHandler(true, nil)
        }

    }
    
    // Handle remainder of Facebook login auth flow (the first part is handled by the Facebook SDK in our login controller)
    func completeLoginWithFacebook (_ accessToken:String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Create and run HTTP request to get the session ID from Udacity */
        let httpBody = generateFacebookLoginJSONWith(accessToken)
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
                completionHandler(false, "Error creating session")
                return
            }
            
            /* 4. Now that we're logged in, save the session ID and Facebook access tokens */
            self.userSessionId = sessionID
            self.userFBAccessToken = accessToken

            /* 5. Now get the userId (email address) from Facebook */
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                /* 6. Verify we were able to obtain the email address */
                if ((error) != nil) {
                    completionHandler(false, "Error retriving your email address from Facebook")
                } else {
                    let data = result as! [String : String]
                    
                    /* 6. Save the email address as our userId */
                    self.userId = data["email"]
                    
                    /* 7. Verify the user's account on Udacity and retrieve user's first and last name from Udacity, then complete the login */
                    self.retrieveNameAndCompleteLogin(completionHandler)
                }
            })
        }
    }
    
    // Logs out of Udacity (and Facebook, if we're logged in there too). This gets run in the background and "fails gracefully" if it's unsuccessful = No completion handler is called of any sort.
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
                // Placeholder in case you'd like to do something with this in the future
                return
            }
            
            /* 3. Verify we have obtained a valid logout response */
            guard let response = results as? [String:AnyObject], let session = response[OTMClient.JSONResponseKeys.UdacitySession] as? [String:AnyObject], let sessionId = session[OTMClient.JSONResponseKeys.UdacitySessionID] as? String else {
                // Placeholder in case you'd like to do something with this in the future
                return
            }
        }
        
        /* 4. If we are logged into Facebook, logout and delete the token  */
        if let _ = userFBAccessToken {
            LoginManager().logOut()
            userFBAccessToken = nil
        }
        
        /* 5. Delete all remaining session variables */
        userId = nil
        userSessionId = nil
        userFirstName = nil
        userLastName = nil
        userObjectId = nil
        
        /* 6. Finally, delete the student information from our model */
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
    
    // Checks if a student location already exists. Error is nil if the request was successful, otherwise will contain the error message.
    func doesStudentLocationAlreadyExist(_ completionHandler: @escaping (_ doesExist: Bool, _ errorString: String?) -> Void) {
        /* 1. Create and run HTTP request to retrieve recent student locations from Parse */
        let uniqueKeyParameter = substituteKey(OTMClient.ParameterValues.ParseUniqueKey, key: OTMClient.URLKeys.ParseUniqueKey, value: userId!)!
        let parameters:[String:String] = [OTMClient.ParameterKeys.ParseWhere:uniqueKeyParameter]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpGet, OTMClient.Constants.ParseApiHost, OTMClient.Methods.ParseStudentLocation, apiParameters: parameters, valuesForHTTPHeader: nil, httpBody: nil) { (results, error) in
            
            /* 2. Check for error response from Parse */
            if let error = error {
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
    
    // Decides whether to save to a new pin, or update an existing one
    func saveStudentLocation(_ mapString:String, _ mediaURL:String, _ latitude:Double, _ longitude:Double, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // If we already have an objectId stored, then we are updating an existing objectId
        if let _ = userObjectId {
            updateStudentLocation(mapString,mediaURL,latitude,longitude,completionHandler)
        }
        // Otherwise we are saving this user's location for the first time
        else {
            addStudentLocation(mapString,mediaURL,latitude,longitude,completionHandler)
        }
    }
    
    // Saves a new student location to Parse
    func addStudentLocation(_ mapString:String, _ mediaURL:String, _ latitude:Double, _ longitude:Double, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        /* 1. Create and run HTTP request to post student location to Parse */
        let httpHeaderValues = [("application/json","Content-Type")]
        let httpBody = generateStudentLocationJSONWith(mapString,mediaURL,latitude,longitude)
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPost, OTMClient.Constants.ParseApiHost, OTMClient.Methods.ParseStudentLocation, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 2. Check for error response from Parse */
            if let error = error {
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
    
    // Updates an existing student location in Parse
    func updateStudentLocation(_ mapString:String, _ mediaURL:String, _ latitude:Double, _ longitude:Double, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Create and run HTTP request to update student location in Parse */
        let updateStudentInformationMethod = substituteKey(OTMClient.Methods.ParseUpdateStudentLocation, key: OTMClient.URLKeys.ParseObjectId, value: userObjectId!)!
        let httpHeaderValues = [("application/json","Content-Type")]
        let httpBody = generateStudentLocationJSONWith(mapString,mediaURL,latitude,longitude)
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPut, OTMClient.Constants.ParseApiHost, updateStudentInformationMethod, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 2. Check for error response from Parse */
            if let error = error {
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
    
    // MARK: Private helper methods
    
    // Generate Udacity login JSON object
    private func generateUdacityLoginJSONWith(_ userId:String,_ password:String) -> String {
        return "{\"\(OTMClient.JSONRequestKeys.UdacityLogin)\": {\"\(OTMClient.JSONRequestKeys.UdacityUsername)\": \"\(userId)\", \"\(OTMClient.JSONRequestKeys.UdacityPassword)\": \"\(password)\"}}"
    }
    
    // Generate Student Location JSON object
    private func generateStudentLocationJSONWith(_ mapString:String,_ mediaURL:String,_ latitude:Double,_ longitude:Double) -> String {
        return "{\"\(OTMClient.JSONRequestKeys.ParseUniqueKey)\": \"\(userId!)\", \"\(OTMClient.JSONRequestKeys.ParseFirstName)\": \"\(userFirstName!)\", \"\(OTMClient.JSONRequestKeys.ParseLastName)\": \"\(userLastName!)\",\"\(OTMClient.JSONRequestKeys.ParseMapString)\": \"\(mapString)\", \"\(OTMClient.JSONRequestKeys.ParseMediaURL)\": \"\(mediaURL)\",\"\(OTMClient.JSONRequestKeys.ParseLatitude)\": \(latitude), \"\(OTMClient.JSONRequestKeys.ParseLongitude)\": \(longitude)}"
    }
    
    // Generate Udacity+Facebook login JSON object
    private func generateFacebookLoginJSONWith(_ accessToken:String) -> String {
        return "{\"\(OTMClient.JSONRequestKeys.FacebookLogin)\": {\"\(OTMClient.JSONRequestKeys.FacebookAccessToken)\": \"\(accessToken)\"}}"
    }

    // Handles NSErrors -- Turns them into user-friendly messages before sending them to the controller's completion handler
    private func handleHttpNSError(_ error:NSError,_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        let errorString = error.userInfo[NSLocalizedDescriptionKey].debugDescription

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
    
    // Substitute a key for the value that is contained within the string
    private func substituteKey(_ string: String, key: String, value: String) -> String? {
        if string.range(of: key) != nil {
            return string.replacingOccurrences(of: key, with: value)
        } else {
            return nil
        }
    }
}
