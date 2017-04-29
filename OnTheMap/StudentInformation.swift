//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

// MARK: Properties

struct StudentInformation {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mediaURL: String
    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary[OTMClient.JSONResponseKeys.ParseFirstName] as! String
        lastName = dictionary[OTMClient.JSONResponseKeys.ParseLastName] as! String
        latitude = dictionary[OTMClient.JSONResponseKeys.ParseLatitude] as! Double
        longitude = dictionary[OTMClient.JSONResponseKeys.ParseLongitude] as! Double
        mediaURL = dictionary[OTMClient.JSONResponseKeys.ParseMediaURL] as! String
    }
    
    static func studentsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        // iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        return students
    }
}
