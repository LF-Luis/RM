//
//  RoomModel.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

class RoomKeys {
    static let roomNum = "roomNumber"
    static let buildingId = "buildingId"
    static let buildingName = "buildingName"
    static let floor = "floor"
    static let longitude = "longitude"
    static let latitude = "latitude"
    static let iconId = "iconId"
    static let rmDescription = "description"
    static let isFavorite = "isFavorite"
    
    static let id = "id"
    static let version = "version"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
    static let creatorUserID = "creatorUserID"
    static let formattedHoursAvailable = "formattedHoursAvailable"
}

class Room : NSObject {
    
    var id: String = ""
    
    var building : Building!
    var floor : String = ""
    var roomNum : String = ""
    var iconId : String = ""
    var rmDescription: String = ""
    var isFavorite: Bool?
    var buildingId: String = ""
    
    var longitude: Double?
    var latitude: Double?

    /**
     Should only be used for brief display cells.
     */
    var todayFormattedTimes = [String]()
    
    var dayTimesAvailable = [WeekDay: [String]]() // Use when editing this room's hours, to display multiple days
    
    override init() {
        super.init()
    }

    func getCellTitle() -> String? {
        
        let items = [building?.name, " ", floor, ".", roomNum]
        
        var retStr = String()
        
        for item in items { if item != nil { retStr += item! } }
        
        return retStr
    }
    
}
