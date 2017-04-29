//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

// MARK: - OTMClient (Convenient Resource Methods)

import Foundation

extension OTMClient {
    
    
    // Handles Udacity auth flow, verifies we are logged in with a session ID, and retrieves the user's first name and last name
    func loginWith(username:String, password:String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Create and run HTTP request to authenticate the user's email and password with Udacity */
        let httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        let httpHeaderValues = [("application/json","Accept"),
                                ("application/json","Content-Type")]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPost, OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacitySession, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 2. Check for error response from Udacity */
            if let error = error {
                // TODO: Delete debug statement
                print(error)
                completionHandler(false, "Login Failed (Invalid username or password)")
            }
            
            /* 3. Verify we have obtained a Session ID from Udacity and are logged in */
            guard let response = results as? [String:AnyObject], let session = response[OTMClient.UdacityResponseKeys.Session] as? [String:AnyObject], let sessionID = session[OTMClient.UdacityResponseKeys.SessionID] as? String else {
                // TODO: Delete debug statement
                print("Could not find \(OTMClient.UdacityResponseKeys.Session) or \(OTMClient.UdacityResponseKeys.SessionID) in \(String(describing: results))")
                completionHandler(false, "Login Failed (Error creating session)")
                return
            }
            
            // TODO: Delete session ID Debug statenent
            print("Login Success! Session ID = \(sessionID)")
            
            /* 4. Save the session ID */
            self.userSessionId = sessionID
            
            /* 5. Create and run HTTP request to retrieve user's first name and last name */
            let _ = self.taskForHTTPMethod(OTMClient.Constants.HttpGet, OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacityUserData + username, apiParameters: nil, valuesForHTTPHeader: nil, httpBody: nil) { (results, error) in
                
                /* 6. Check for error response from Udacity */
                if let error = error {
                    // TODO: Delete debug statement
                    print(error)
                    completionHandler(false, "Login Failed (Error retrieving user data)")
                }
                
                /* 7. Verify we have obtained a the first name and last name */
                guard let response = results as? [String:AnyObject], let user = response[OTMClient.UdacityResponseKeys.User] as? [String:AnyObject], let firstName = user[OTMClient.UdacityResponseKeys.FirstName] as? String, let lastName = user[OTMClient.UdacityResponseKeys.LastName] as? String else {
                    // TODO: Delete debug statement
                    print("Could not find \(OTMClient.UdacityResponseKeys.User), \(OTMClient.UdacityResponseKeys.FirstName), or \(OTMClient.UdacityResponseKeys.LastName) in \(String(describing: results))")
                    completionHandler(false, "Login Failed (Error retrieving user data)")
                    return
                }
                
                /* 8. Save the user's first and last name */
                // TODO: Delete debug print statement
                print("Retrieved user data. First name: \(firstName), Last name: \(lastName)")
                self.userFirstName = firstName
                self.userLastName = lastName

                /* 9. Run the completion handler and return*/
                completionHandler(true, nil)
            }
        }
    }
    
    // Logs out of Udacity. This gets run in the background, and whether it's succesful or not, we don't need to let the user know, so there's no completion handler. It "fails gracefully".
    func logout() {

        /* 1. Create and run HTTP request to logout */
        
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
            }
            
            /* 3. Verify we have obtained a valid logout response */
            guard let response = results as? [String:AnyObject], let session = response[OTMClient.UdacityResponseKeys.Session] as? [String:AnyObject], let sessionId = session[OTMClient.UdacityResponseKeys.SessionID] as? String else {
                // TODO: Delete debug statement
                print("Could not find \(OTMClient.UdacityResponseKeys.Session) or \(OTMClient.UdacityResponseKeys.SessionID) in \(String(describing: results))")
                return
            }
            
            /* 4. Delete the session ID */
            print("Logged out successfully. Old Session ID: \(self.userSessionId!), Session ID received: \(sessionId)")
            self.userSessionId = ""
        }

    }
}
