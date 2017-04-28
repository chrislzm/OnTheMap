//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

// MARK: - OTMClient (Convenient Resource Methods)

extension OTMClient {
    func loginWith(username:String, password:String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        let httpHeaderValues = [("application/json","Accept"),
                                ("application/json","Content-Type")]
        let _ = taskForHTTPMethod(OTMClient.Constants.HttpPost, OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacitySession, apiParameters: nil, valuesForHTTPHeader: httpHeaderValues, httpBody: httpBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // TODO: Delete debug statement
                print(error)
                completionHandler(false, "Login Failed (Invalid Username or Password)")
            } else {
                if let response = results as? [String:AnyObject], let session = response[OTMClient.UdacityResponseKeys.Session] as? [String:AnyObject], let sessionID = session[OTMClient.UdacityResponseKeys.SessionID] {
                    // TODO: Delete session ID Debug statenent
                    print("Login success: Session ID = \(sessionID)")
                    completionHandler(true, nil)
                } else {
                    print("Could not find \(OTMClient.UdacityResponseKeys.Session) or \(OTMClient.UdacityResponseKeys.SessionID) in \(String(describing: results))")
                    completionHandler(false, "Login Failed (Error creating session)")
                }
            }
        }

    }
}
