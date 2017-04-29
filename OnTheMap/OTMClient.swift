//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/27/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    // MARK: Properties
    
    // Shared session
    var session = URLSession.shared
    
    // Session data: Session ID, First Name, Last Name of logged in user
    var userSessionId:String? = nil
    var userFirstName:String? = nil
    var userLastName:String? = nil
    
    // MARK: Methods
    
    // Shared HTTP Method for all HTTP requests
    
    func taskForHTTPMethod(_ httpMethod:String, _ apiHost: String, _ apiMethod: String, apiParameters: [String:String]?, valuesForHTTPHeader: [(String, String)]?, httpBody: String?, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
 
        /* 1. Build the URL */
        let request = NSMutableURLRequest(url: urlFromParameters(apiHost, apiMethod, apiParameters))
        
        /* 2. Configure the request */
        
        request.httpMethod = httpMethod
        
        // Add values for HTTP Header field, if any
        if let valuesForHTTPHeader = valuesForHTTPHeader {
            for (value,headerField) in valuesForHTTPHeader {
                request.addValue(value, forHTTPHeaderField: headerField)
            }
        }
        
        // Add http request body, if any
        if let httpBody = httpBody {
            request.httpBody = httpBody.data(using: String.Encoding.utf8)
        }
        
        /* 3. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a status code from the response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Your request did not return a valid response (no status code).")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard statusCode >= 200 && statusCode <= 299  else {
                sendError("Your request returned a status code other than 2xx. Status code returned: \(statusCode)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard var data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Extract the data if it's from Udacity
            if apiHost == OTMClient.Constants.UdacityApiHost {
                let range = Range(5..<data.count)
                data = data.subdata(in: range)
            }
            
            /* 4/5. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
        }
        
        /* 6. Start the request */
        task.resume()
        
        return task
    }

    // Creates a URL from parameters
    
    private func urlFromParameters(_ host:String, _ method:String, _ parameters: [String:String]?) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = host
        components.path = method
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        // TODO: Remove debug print statement
        print ("Making HTTP Request with URL \(components.url!.absoluteString)")
        return components.url!
    }
    
    // Converts raw JSON into a usable Foundation object and sends it to a completion handler
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}
