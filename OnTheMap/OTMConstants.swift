//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

extension OTMClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: HTTP Constants
        static let ApiScheme = "https"
        static let HttpGet = "GET"
        static let HttpPost = "POST"
        
        // MARK: Parse API Information
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApiHost = "parse.udacity.com"
        
        // MARK: Udacity API Information
        static let UdacityApiHost = "www.udacity.com"
    }
    
    struct Methods {
        // MARK: Udacity API Methods
        static let UdacitySession = "/api/session"
        static let UdacityUserData = "/api/users/"
    }
    
    struct UdacityResponseKeys {
        // MARK: Udacity API JSON Response Keys
        static let Session = "session"
        static let SessionID = "id"
        static let User = "user"
        static let LastName = "last_name"
        static let FirstName = "first_name"
    }
}
