//
//  OTMConstants.swift
//  OnTheMap
//
//  Constants used in the OTMClient class
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
        static let HttpPut = "PUT"
        static let HttpDelete = "DELETE"
        
        // MARK: Parse API Information
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApiHost = "parse.udacity.com"
        static let ParseStudentLocationLimit = "100"
        
        // MARK: Udacity API Information
        static let UdacityApiHost = "www.udacity.com"
    }
    
    struct HttpHeaderField {
        // MARK: Parse HTTP Header Fields
        static let ParseAppID = "X-Parse-Application-Id"
        static let ParseApiKey = "X-Parse-REST-API-Key"
    }

    struct Methods {
        // MARK: Udacity API Methods
        static let UdacitySession = "/api/session"
        static let UdacityUserData = "/api/users/[userId]"
        
        // MARK: Parse API Methods
        static let ParseStudentLocation = "/parse/classes/StudentLocation"
        static let ParseUpdateStudentLocation = "/parse/classes/StudentLocation/[objectId]"
    }
    
    struct URLKeys {
        // MARK: Udacity Parameter Keys
        static let UdacityUserId = "[userId]"
        
        // MARK: Parse Parameter Keys
        static let ParseUniqueKey = "[uniqueKey]"
        static let ParseObjectId = "[objectId]"
    }
    
    struct ParameterKeys {
        // MARK: Parse Parameter Keys
        static let ParseLimit = "limit"
        static let ParseOrder = "order"
        static let ParseWhere = "where"
    }

    struct ParameterValues {
        // MARK: Parse Parameter Values
        static let ParseNumStudents = OTMClient.Constants.ParseStudentLocationLimit
        static let ParseUpdatedAt = "-updatedAt"
        static let ParseUniqueKey = "{\"uniqueKey\":\"[uniqueKey]\"}"
    }

    struct JSONRequestKeys {
        // MARK: Udacity JSON Requst Keys
        static let UdacityLogin = "udacity"
        static let UdacityUsername = "username"
        static let UdacityPassword = "password"

        // MARK: Udacity+Facebook JSON Request Keys
        static let FacebookLogin = "facebook_mobile"
        static let FacebookAccessToken = "access_token"

        // MARK: Parse JSON Request Keys
        static let ParseUniqueKey = "uniqueKey"
        static let ParseFirstName = "firstName"
        static let ParseLastName = "lastName"
        static let ParseMapString = "mapString"
        static let ParseMediaURL = "mediaURL"
        static let ParseLatitude = "latitude"
        static let ParseLongitude = "longitude"
    }
    
    struct JSONResponseKeys {
        // MARK: Udacity API JSON Response Keys
        static let UdacitySession = "session"
        static let UdacitySessionID = "id"
        static let UdacityUser = "user"
        static let UdacityLastName = "last_name"
        static let UdacityFirstName = "first_name"
        
        // MARK: Parse API JSON Response Keys
        static let ParseFirstName = "firstName"
        static let ParseLastName = "lastName"
        static let ParseLatitude = "latitude"
        static let ParseLongitude = "longitude"
        static let ParseMediaURL = "mediaURL"
        static let ParseResults = "results"
        static let ParseLocationCreated = "createdAt"
        static let ParseObjectId = "objectId"
        static let ParseUpdatedAt = "updatedAt"
    }
}
