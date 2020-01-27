//
//  RoomTime.swift
//  RM
//
//  Created by Luis Fernandez on 8/17/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import Foundation

class RoomTimeKeys {
    static let timeId = "id"
    static let roomId = "RoomId"
    static let dayOfWeek = "dayOfWeek"
    static let start = "start"
    static let end = "end"
}

class RoomTime: NSObject {
    
    var timeId: String?
    
    var roomId = ""
    var weekDay = ""
    var start: Float = 0.0
    var end: Float = 0.0
    
    override init() {
        super.init()
    }
    
}
