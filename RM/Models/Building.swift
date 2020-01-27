//
//  BuildingModel.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

// BE: Back end. As in, this class is used to connect with back end data
open class BuildingKeys {
    static let acronymName = "acronymName"
//    static let buildingAddressFull = "buildingAddressFull"
    static let buildingName = "buildingName"
    static let longitude = "longitude"
    static let latitude = "latitude"
    
    // back-end important parameters
    static let id = "id"
    static let version = "version"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
}

class Building: NSObject {
    
    var id: String = ""
    
    var name : String = ""
    var acronym: String = ""
//    var address : Address?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override init() {
        super.init()
    }
    
}


