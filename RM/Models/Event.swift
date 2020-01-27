//
//  Event.swift
//  RM
//
//  Created by Luis Fernandez on 7/22/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation

struct EventKeys {
    static let name = "name"
    static let description = "description"
    static let date = "date"
    static let mainPictureUrl = "mainPictureUrl"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let buildingId = "buildingId"
    
    static let uiImage = "UIImage"
    static let imageData = "imageData"
    static let sDateEpoch = "sDateEpoch"
    
    // Azure edited:
    static let eDateEpoch = "eDateEpoch"
    static let sDateDotNet = "sDateDotNet"
    static let eDateDotNet = "eDateDotNet"
    
    static let id = "id"
    static let version = "version"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
    static let creatorUserID = "creatorUserID"
}

class Event {
    
    var id: String?
    
    var name: String?
    var description: String?
    var date: Date?
    var mainPictureUrl: String?

    var latitude: Double?
    var longitude: Double?
    
    var buildingId: String? // Set in the back-end
    
    var uiImage: UIImage?
    
}

/*
 When upserting this object to back-end:
    - convert dateEpoch into epoch time numer
    - convert uiImage into binary 
 Event image is optional when creating an event.
 */
