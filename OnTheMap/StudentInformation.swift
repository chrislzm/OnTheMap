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
    let latitude: String
    let longitude: String
    let mediaURL: String
    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary[OTMClient.ParseResponseKeys.FirstName] as! String
        lastName = dictionary[OTMClient.ParseResponseKeys.LastName] as! String
        latitude = dictionary[OTMClient.ParseResponseKeys.Latitude] as! String
        longitude = dictionary[OTMClient.ParseResponseKeys.Longitude] as! String
        mediaURL = dictionary[OTMClient.ParseResponseKeys.MediaURL] as! String
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
