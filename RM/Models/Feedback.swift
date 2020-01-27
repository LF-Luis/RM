//
//  Feedback.swift
//  RM
//
//  Created by Luis Fernandez on 8/15/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

class FeedbackKeys {
    static let userId = "userId"
    static let date = "date"
    static let locLat = "locLat"
    static let locLong = "locLong"
    static let feedback = "feedbackString"
}

class Feedback: NSObject {

    var userId = ""
    var date: Int!
    var longitude: Double?
    var latitude: Double?
    
    var feedbackMsg = ""
    
}


