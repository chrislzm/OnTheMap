//
//  Extensions.swift
//  OnTheMap
//
//  Created by Chris Leung on 4/28/17.
//  Copyright © 2017 Chris Leung. All rights reserved.
//

import UIKit

// MARK: UIViewController extension

extension UIViewController {
    
    // Returns the current saved memes array
    func getStudents() -> [StudentInformation] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.students
    }
}
