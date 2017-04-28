//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

// MARK: - OTMClient (Convenient Resource Methods)

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
            guard let response = results as? [String:AnyObject], let session = response[OTMClient.UdacityResponseKeys.Session] as? [String:AnyObject], let sessionID = session[OTMClient.UdacityResponseKeys.SessionID] else {
                // TODO: Delete debug statement
                print("Could not find \(OTMClient.UdacityResponseKeys.Session) or \(OTMClient.UdacityResponseKeys.SessionID) in \(String(describing: results))")
                completionHandler(false, "Login Failed (Error creating session)")
                return
            }
            
            // TODO: Delete session ID Debug statenent
            print("Login Success! Session ID = \(sessionID)")
            
            /* 4. Create and run HTTP request to retrieve user's first name and last name */
            let _ = self.taskForHTTPMethod(OTMClient.Constants.HttpGet, OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacityUserData + username, apiParameters: nil, valuesForHTTPHeader: nil, httpBody: nil) { (results, error) in
                
                /* 5. Check for error response from Udacity */
                if let error = error {
                    // TODO: Delete debug statement
                    print(error)
                    completionHandler(false, "Login Failed (Error retrieving user data)")
                }
                
                /* 6. Verify we have obtained a the first name and last name */
                guard let response = results as? [String:AnyObject], let user = response[OTMClient.UdacityResponseKeys.User] as? [String:AnyObject], let firstName = user[OTMClient.UdacityResponseKeys.FirstName] as? String, let lastName = user[OTMClient.UdacityResponseKeys.LastName] as? String else {
                    // TODO: Delete debug statement
                    print("Could not find \(OTMClient.UdacityResponseKeys.User), \(OTMClient.UdacityResponseKeys.FirstName), or \(OTMClient.UdacityResponseKeys.LastName) in \(String(describing: results))")
                    completionHandler(false, "Login Failed (Error retrieving user data)")
                    return
                }
                
                /* 7. Save the user's first and last name */
                // TODO: Delete debug print statement
                print("Retrieved user data. First name: \(firstName), Last name: \(lastName)")
                self.userFirstName = firstName
                self.userLastName = lastName

                /* 8. Run the completion handler and return*/
                completionHandler(true, nil)
            }
        }
    }
}
