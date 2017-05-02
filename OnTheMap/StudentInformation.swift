//
//  StudentInformation.swift
//  OnTheMap
//
//  Student Information model for On The Map
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

struct StudentInformation {
    
    // MARK: Properties

    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mediaURL: String
    
    // MARK: Initializers
    
    // Construct StudentInformation from a dictionary
    init(dictionary: [String:AnyObject]) {
        if let fn = dictionary[OTMClient.JSONResponseKeys.ParseFirstName] as? String {
            firstName = fn
        } else {
            firstName = String()
        }
        if let ln = dictionary[OTMClient.JSONResponseKeys.ParseLastName] as? String {
            lastName = ln
        } else {
            lastName = String()
        }
        if let lat = dictionary[OTMClient.JSONResponseKeys.ParseLatitude] as? Double {
            latitude = lat
        } else {
            latitude = Double()
        }
        if let long = dictionary[OTMClient.JSONResponseKeys.ParseLongitude] as? Double {
            longitude = long
        } else {
            longitude = Double()
        }
        if let url = dictionary[OTMClient.JSONResponseKeys.ParseMediaURL] as? String {
            mediaURL = url
        } else {
            mediaURL = String()
        }
    }
    
    // Construct an array of Student Information from an array of dictionaries obtained from JSON
    static func studentsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        // Iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        return students
    }
}
