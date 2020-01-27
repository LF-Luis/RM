//
//  DatabaseConnestion.swift
//  RM
//
//  Created by Luis Fernandez on 8/14/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

// FIXME: Move to public file
//____________________
// Model Entity Names
// These are publicly accessible things

class Entities {
    static let building = "Building"
    static let room = "RoomModel"
    static let feedback = "FeedbackItemModels"
    static let roomTime = "RoomTimeModel"
    static let myFavorite = "MyFavorite"
    static let Event = "Event"
}


/**
 BriefList: List of Room objects.
 FullSingleDescription: Single Room object.
 */

enum CellDataPresentaton {
    case briefListNearMe
    case briefListMyRooms
    case fullSingleDescription
}

// Cache Images. Key will be their URL
let imgCache = NSCache<AnyObject, AnyObject>()

//let ServiceUrl : String = "<sensitive_url>/.auth/login/facebook/callback"
let ServiceUrl : String = "<sensitive_url>"   //  "/.auth/login/facebook/callback"
let ServiceUrl_FACEBOOK : String = "https://<sensitive_url>/.auth/login/facebook/callback"
let MicrosoftProvider = "MICROSOFTACCOUNT"
let GoogleProvider = "GOOGLE"
let TwitterProvider = "TWITTER"
let FacebookProvider = "FACEBOOK"
var RMUserID = String()
//____________________

typealias ServiceCompletion = (NSError?) -> Void
/// Contains error and item returned by database when upserting to database
typealias DBErrorAndItemCompletion = (_ error: NSError?, _ DBReturnedItem: [AnyHashable: Any]?) -> Void
typealias DBUpdateCompletion = (_ error: Error?) -> Void

class DatabaseConnection {
    
    // MARK: - Upserting Items to Database Tables
    
    /// Add a room as a favorite room of User
    /// If adding RoomID to Favorites fails while creating a Room, Room will be created regardless.
    class func upsertToFavorite(roomID rID: String) {
        getUserID { (userID: String?) in
            if userID != nil {

                let favDict: [AnyHashable: Any] = [ "RoomId": rID,
                                                        "UserId": userID!]
                
                // upsert to backend
                upsertToBackend(forEntity: Entities.myFavorite, withItems: favDict, completion: { (error, DBReturnedItem) in
                    if error != nil {
                        print("Error adding to favorites: \(error)")
                    }
                })
            }
        }
    }
    
    /// The following values are required, else method will fail: feedback message, user id, and date in unix time
    class func sendFeedback(feedback fb: Feedback, completion: @escaping ServiceResponse) {
        
        var feedbackDict: [AnyHashable: Any] = [FeedbackKeys.feedback : fb.feedbackMsg]
        
        if fb.latitude != nil {
            feedbackDict[FeedbackKeys.locLat] = fb.latitude!
        }
        
        if fb.longitude != nil {
            feedbackDict[FeedbackKeys.locLong] = fb.longitude!
        }
        
        print(feedbackDict)
        
        upsertToBackend(forEntity: Entities.feedback, withItems: feedbackDict) { (error, DBReturnedItem) in
            completion(error)
        }
        
    }
    
    class func upsert(event e: Event, completion: @escaping ServiceResponse) {
    
        var eventDict: [AnyHashable: Any] = [EventKeys.name : e.name!,
                                            EventKeys.description : e.description!,
                                            EventKeys.sDateEpoch : e.date!.timeIntervalSince1970,
                                            EventKeys.latitude : e.latitude!,
                                            EventKeys.longitude: e.longitude!]
        
        if
            e.uiImage != nil ,
            let data = UIImagePNGRepresentation(e.uiImage!)
        {
            // included image
            // convert image to string
            // add image to eventDict
            eventDict[EventKeys.imageData] = String(data.base64EncodedString()) //String(data.base64EncodedData())
            
        }
        
        upsertToBackend(forEntity: Entities.Event, withItems: eventDict) { (error, DBReturnedItem) in
            print(DBReturnedItem)
            completion(error)
        }
        
    }
    
    /// The following values are required, else method will fail: room id, dayOfWeek, start, end
    class func upsert(time tm: RoomTime, completion: @escaping ServiceResponse) {
        
        let timeDict: [AnyHashable: Any] = [RoomTimeKeys.roomId : tm.roomId,
                                                RoomTimeKeys.dayOfWeek : tm.weekDay,
                                                RoomTimeKeys.start : tm.start,
                                                RoomTimeKeys.end : tm.end]
        
        upsertToBackend(forEntity: Entities.roomTime, withItems: timeDict) { (error, DBReturnedItem) in
            completion(error)
        }
        
    }
    
    /// The following values are required, else method will fail: buildingId, floor, roomNum, iconId
    class func upsert(room rm: Room, completion: @escaping DBErrorAndItemCompletion) {
        
        var roomDict: [AnyHashable: Any] = [RoomKeys.buildingId : rm.buildingId,
                                                RoomKeys.floor : rm.floor,
                                                RoomKeys.roomNum : rm.roomNum
                                                ]
        
        if !rm.iconId.isEmpty {
            roomDict[RoomKeys.iconId] = rm.iconId
        }
        
        if rm.latitude != nil {
            roomDict[RoomKeys.latitude] = rm.latitude!
        }
        
        if rm.longitude != nil {
            roomDict[RoomKeys.longitude] = rm.longitude
        }
        
        upsertToBackend(forEntity: Entities.room, withItems: roomDict) { (error, DBReturnedItem) in
            print(DBReturnedItem)
            completion(error, DBReturnedItem)
        }
        
    }
    
    class func upsert(building bld: Building, completion: @escaping DBErrorAndItemCompletion) {
        
        let bldDict: [AnyHashable: Any] = [BuildingKeys.acronymName : bld.acronym,
                                               BuildingKeys.buildingName : bld.name,
                                               BuildingKeys.latitude : bld.latitude,
                                               BuildingKeys.longitude : bld.longitude] //,
//                                               BuildingKeys.iconId : bld.iconId]

        upsertToBackend(forEntity: Entities.building, withItems: bldDict) { (error, DBReturnedItem) in
            completion(error, DBReturnedItem)
        }
    }
    
    // base upsert function (all other upsert functions come from this one)
    fileprivate class func upsertToBackend(forEntity ent: String, withItems dict: [AnyHashable: Any], completion: @escaping DBErrorAndItemCompletion) {
        
        let table = MSTable(name: ent, client: MSClient(applicationURLString: ServiceUrl))
        
        table.insert(dict) { (iten: [AnyHashable : Any]?, error:Error?) in
            completion(error as NSError?, iten)
        }
        
    }
    
    // MARK: - Update

    class func update(item: [AnyHashable: Any], forEntity ent: String, completion: @escaping DBUpdateCompletion) {
        /*
         - Must include ID
         - Have following format:
            ["id": "custom-id", "text": "my EDITED item"]
         */
        print("item---")
        print(item)
        print("item+++++")
        let table = MSTable(name: ent, client: MSClient(applicationURLString: ServiceUrl))
        table.update(item) { (itemRet: [AnyHashable : Any]?, error: Error?) in
            print(itemRet)
            print(error)
            if error != nil {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    class func update(newItems: [AnyHashable: Any], oldEventAnyData: [AnyHashable: Any], forEntity ent: String, completion: @escaping DBUpdateCompletion) {
        /*
         - Must include ID
         - Have following format:
         ["id": "custom-id", "text": "my EDITED item"]
         */
        
        
        var dataForBackend = [AnyHashable: Any]()
        
        // update of event
        let eventKeysNeeded = [EventKeys.id, EventKeys.sDateDotNet, EventKeys.buildingId, EventKeys.name, EventKeys.eDateDotNet, EventKeys.description, EventKeys.imageData, EventKeys.latitude, EventKeys.sDateEpoch, EventKeys.longitude, EventKeys.eDateEpoch, EventKeys.creatorUserID, EventKeys.mainPictureUrl]
        
        for key in eventKeysNeeded {
            dataForBackend[key] = oldEventAnyData[key]
        }
        
//        var newData = oldEventAnyData
        
        for item in newItems {
            dataForBackend[item.key] = item.value
        }
        
        print("New Data: ")
        print(dataForBackend)
        
        let table = MSTable(name: ent, client: MSClient(applicationURLString: ServiceUrl))
        
        table.update(dataForBackend) { (itemRet: [AnyHashable : Any]?, error: Error?) in
            print(itemRet)
            print(error)
            if error != nil {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    // MARK: - API Calls
    
    // base JSON request
    private class func simpleJSONGetRequest(url: String, _ completion:@escaping ((_ json: [String:Any]?) -> Void)) {
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{ response in
            switch response.result {
            case .success(let JSON):
                completion(JSON as? [String:Any])
            case .failure(let error):
                print("errrrr")
                print(error.localizedDescription)
                print("errrrr")
                completion(nil)
            }
        }
    }
    
    /// Completes with Array<String> of Building Acronym + Name, and Dictionary<String, String> of Building Acronym + Name and Building Id.
    /// If something fails, nil will be completed for both for both.
    class func getBuildingsForDisplay(latitude lat: Double, longitude long: Double, completion:@escaping ((_ buildingDisplayName: [String]?, _ dictOfDisplayName_toId: Dictionary<String, String>?) -> Void)) {
 
//        let url = "https://<sensitive_url>/api/BuildingApi"
        let url = "https://<sensitive_url>/api/BuildingApi?lat=30.4619062944781&lon=-97.5840086862445"
        
        simpleJSONGetRequest(url: url) { (response: [String:Any]?) in
            if response != nil {
                var displayName = [String]()
                var displayName_toId = Dictionary<String, String>()
                
                if let buildings = response!["myBuildings"] as? [[String:Any]] {
                    for building in buildings {
                        
                        var tempAcronym: String?
                        var tempName: String?
                        var tempID: String?
                
                        if let tA = building["acronymName"] as? String {
                            tempAcronym = tA
                        }
                        
                        if let name = building["buildingName"] as? String{
                            tempName = name
                        }
                        
                        if let bldId = building["id"] as? String {
                            tempID = bldId
                        }
                        
                        if tempID != nil && (tempAcronym != nil || tempName != nil) {
                            var key: String = ""
                            
                            if (tempAcronym != nil) {key = key + tempAcronym! + " "}
                            if (tempName != nil) {key = key + tempName!}
                            
                            displayName.append(key)
                            displayName_toId[key] = tempID
                        }
                        
                    }
                }
                completion(displayName, displayName_toId)
                return
            }
            completion(nil, nil)
        }
        
    }
    
    class func getBuildingsForLocation(latitude lat: Double, longitude long: Double, completion:@escaping ((_ nearbyBldDict:[String: Building]?) -> Void)) {
        
        let url = "https://<sensitive_url>/api/BuildingApi?lat=\(lat)&lon=\(long)"
        simpleJSONGetRequest(url: url) { (response: [String:Any]?) in
            if response != nil {
                
                var tempNearbyBldDict = [String: Building]()
                
                if let buildings = response!["myBuildings"] as? [[String:Any]] {
                    for building in buildings {
                        
                        let tempBld = Building()
                        
                        if let tA = building["acronymName"] as? String {
                            tempBld.acronym = tA
                        }
                        
                        if let name = building["buildingName"] as? String{
                            tempBld.name = name
                        }
                        
                        if let bldId = building["id"] as? String {
                            tempBld.id = bldId
                        }
                        
                        if let long = building["Longitude"] as? Double {
                            tempBld.longitude = long
                        }
                        
                        if let lat = building["Latitude"] as? Double {
                            tempBld.latitude = lat
                        }
                        
                        if !tempBld.id.isEmpty && (!tempBld.acronym.isEmpty || !tempBld.name.isEmpty) {
                            var key: String = ""
                            
                            if (!tempBld.acronym.isEmpty) {key = key + tempBld.acronym + " "}
                            if (!tempBld.name.isEmpty) {key = key + tempBld.name}
                            
                            tempNearbyBldDict[key] = tempBld
                            
                        }
                        
                    }
                }
                completion(tempNearbyBldDict)
                return
            }
            completion(nil)
        }
        
    }
    
    // This is used in main view off app. Used to display rooms based on location and day
    class func getEventsForMainDisplay(latitude lat: Double, longitude long: Double, forDayAndTime dayTime: Date, lastRecordCount rCount: Int?, completion:@escaping ((_ rooms: [Event]?) -> Void)) {
       
        // assgning last record count
        var lastRecCount = 0
        
        if rCount != nil {
            lastRecCount = rCount!
        }
        
        // Currently, RM wants to show every event for today
        // For this reason, here we get the date argument, calculate how many seconds that is, subtract it from itself, so that we have the epoch time at 00:00:00 hours today (the API returns events from dEpoch to 24 hours on)
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let secondsToday = ( hour * 3600 ) + ( minutes * 60 ) + seconds + 100
        // +100 just incase of any errors/lag in calculation
        
        let dayTimeEpoch = Int(dayTime.timeIntervalSince1970)
        
        let timeToCheck = dayTimeEpoch - secondsToday
        
        let url = "https://<sensitive_url>/api/GetEvents?lat=\(lat)&lon=\(long)&dEpoch=\(timeToCheck)&lastRecCnt=\(lastRecCount)"
        
        simpleJSONGetRequest(url: url) { (response: [String:Any]?) in
            
            print("Events: ----")
            print(response)
            print("Events: ++++")
            
            if response != nil {
                
                var events = [Event]()
                
                if let eventsList = response!["eventItems"] as? [[String:Any]] {
                    for event in eventsList {
                        
                        let tempEvent = Event()
                        
                        // Main Category
                        
                        let eventInfo = event["eventItem"] as! NSDictionary
                        
                        // Parsing out Event Info
                        
                        if let eventId = eventInfo["id"] as? String{
                            tempEvent.id = eventId
                        }
                        
                        if let name = eventInfo["name"] as? String{
                            tempEvent.name = name
                        }
                        
                        if let description = eventInfo["description"] as? String{
                            tempEvent.description = description
                        }
                        
                        if let epochDate = eventInfo["sDateEpoch"] as? Int{
                            tempEvent.date = Date(timeIntervalSince1970: Double(epochDate))
                        }
                        
                        // FIXME: Image data
                        
                        // aggregate event to list of events to be diplayes
                        events.append(tempEvent)
                    }
                }
                completion(events)
                return
            }
            completion(nil)
        }
    }
    
    // This is used in main view off app. Used to display rooms based on location and day
    class func getRoomsMainDisplay(latitude lat: Double, longitude long: Double, forDay day: WeekDay, lastRecordCount rCount: Int?, completion:@escaping ((_ rooms: [Room]?) -> Void)) {
        
        var lastRecCount = 0
        
        if rCount != nil {
            lastRecCount = rCount!
        }
        
        let url = "https://<sensitive_url>/api/GetRooms?lat=\(lat)&lon=\(long)&day=\(TimesHelper.stringDay(fromWeekDay: day))&lastRecordCount=\(String(lastRecCount))"
       
        simpleJSONGetRequest(url: url) { (response: [String:Any]?) in
            if response != nil {
                print("*********")
                print(response)
                print("*********")
                
                var listRooms = [Room]()
                
                if let rooms = response!["rooms"] as? [[String:Any]] {
                    for room in rooms {
                        
                        let tempRoom = Room()
                        let tempBuilding = Building()
                        
                        // Main Category
                        
                        let buildingInfo = room["buildingInfo"] as! NSDictionary
                        
                        // Building Info
                        
                        if let acronym = buildingInfo["acronymName"] as? String{
                            tempBuilding.acronym = acronym
                        }
                        
                        if let bldName = buildingInfo["buildingName"] as? String{
                            tempBuilding.name = bldName
                        }
                        
                        // Room Info
                        
                        if let roomInfo = room["roomInfo"] as? [String:Any] {
                    
                            if let availabilties = roomInfo["hoursAvailableForDay"] as? [[String:Any]] {
                                for availabilty in availabilties {
                                    // Time Info
                                    if let hourSet = availabilty["hours"] as? [[String:Any]] {
                                        var tempSet = [String]()
                                        for set in hourSet {
                                            if
                                                let start = set["start"] as? NSNumber,
                                                let end = set["end"] as? NSNumber
                                            {
                                                tempSet.append(TimesHelper.formattedTime(start: Float(start), end: Float(end)))
                                            }
                                        }
                                        tempRoom.todayFormattedTimes = tempSet
                                    }
                                }
                            }
                            
                            if let roomID = roomInfo["roomId"] as? String{
                                tempRoom.id = roomID
                            }
                            
                            if let flr = roomInfo["floor"] as? String{
                                tempRoom.floor = flr
                            }
                            
                            if let roomNum = roomInfo["roomNumber"] as? String{
                                tempRoom.roomNum = roomNum
                            }
                            
                            if let iconId = roomInfo["iconId"] as? String {
                                tempRoom.iconId = iconId
                                if iconId.isEmpty {
                                    tempRoom.iconId = DefaultValues.defaultRoomIconId
                                }
                            }
                            
                        }
                        
                        // Add building info to current room
                        
                        tempRoom.building = tempBuilding
                        
                        // aggregate current room to list of rooms to be diplayes
                        
                        listRooms.append(tempRoom)
                    }
                }
                completion(listRooms)
                return
            }
            completion(nil)
        }
    }
    
    class func getUserInfo(_ completion:@escaping ((_ rmUserInfo: RMUser?) -> Void)) {
        // User data returned is (which ever is available):
            // First Name
            // Last Name
            // Email
        
        let APIUrl = "https://<sensitive_url>/api/FacebookInfo"
        
        let rmUser = RMUser()
        
        simpleJSONGetRequest(url: APIUrl) { (response: [String:Any]?) in
        
            if response != nil {
                
                if let _email = response!["fbEmail"] as? String {
                    rmUser.email = _email
                }
                
                if let _firstName = response!["firstName"] as? String {
                    rmUser.firstName = _firstName
                }
                
                if let _lastName = response!["lastName"] as? String {
                    rmUser.lastName = _lastName
                }
                
                completion(rmUser)
                return
            }
            
            completion(nil)
        
        }
        
    }
    
    /// Call for ID only works if User is logged in
    class func getUserID(_ completion: @escaping (_ userID: String?) -> Void) {
        
        let APIUrl = "https://<sensitive_url>/api/MyUserId"
        
        Alamofire.request(APIUrl, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{ response in
            switch response.result {
            case .success(let JSON):
                completion(String(describing: JSON))
            case .failure(let error):
                print("Error loading JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
//        simpleJSONGetRequest(url: APIUrl) { (response: [String : Any]?) in
//            print(response)
//            if let userId = response as? String {
//                
//            }
//        }
        
    }

    /// Gets buildings name, acronym, and id near loaction
    class func getBuildingsNearLocation(latitude  lat: Double, longitude long: Double, completion:@escaping ((_ buidling: [Building]?) -> Void)) {
        
    }
    
    // This function is mainly used to test async funcs when data is not readily available
    fileprivate static func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    class func testAPI() {
        
        let url = "https://<sensitive_url>/tables/MyFavorite"

//        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON).responseJSON{
//            response in switch response.result {
//                
//            case .Success(let JSON):
//                
//                print(JSON)
//                
//            case .Failure(let error):
//                // Connection failed
//                print(error.localizedDescription)
//                
//            }
//            
//        }
        
    }
    
    // MARK: Read methods
    
    class func getBuildingLOcation(withId bldId: String, completion: @escaping (_ latitude: Double?, _ longitude: Double?) -> Void) {
        let buildingTable = MSTable(name: Entities.building, client: MSClient(applicationURLString: ServiceUrl))
        let query = MSQuery(table: buildingTable)
        query.predicate  = NSPredicate(format: "\(BuildingKeys.id) = '\(bldId)'")
        query.selectFields = [BuildingKeys.latitude, BuildingKeys.longitude]
        
        query.read { (results: MSQueryResult?, error: Error?) in
            if
                error == nil,
                results != nil,
                let items = results!.items as [[AnyHashable: Any]]?
            {
                
                var lat: Double?
                var long: Double?
                
                for values in items {
                    
                    if let lattitude = values[BuildingKeys.latitude] as? Double! {
                        lat = lattitude!
                    }
                    
                    if let longitude = values[BuildingKeys.longitude] as? Double! {
                        long = longitude!
                    }
                    
                }
  
                completion(lat,long)
                
            }
            else {
                completion(nil, nil)
            }
        }
        
    }

    class func getRoom(withId roomId: String, completion:@escaping (_ room: Room?) -> Void) {
        
        let room = Room()
        let building = Building()
        room.building = building
        
        // Getting room information
        
        let roomTable = MSTable(name: Entities.room, client: MSClient(applicationURLString: ServiceUrl))
        
        roomTable.read(withId: roomId) { roomInfo, error in  // ([NSObject : AnyObject]?, NSError?)
            if error == nil {
                
                if roomInfo == nil {
                    completion(nil)
                    return
                }
                
                print(roomInfo)
                
                if let roomID = roomInfo![RoomKeys.id] as? String{
                    room.id = roomID
                }
                
                if let bldId = roomInfo![RoomKeys.buildingId] as? String{
                    room.building.id = bldId
                }
                
                if let flr = roomInfo![RoomKeys.floor] as? String{
                    room.floor = flr
                }
                
                if let desc = roomInfo![RoomKeys.rmDescription] as? String{
                    room.rmDescription = desc
                }
                
                if let roomNum = roomInfo![RoomKeys.roomNum] as? String{
                    room.roomNum = roomNum
                }
                
                if let iconId = roomInfo![RoomKeys.iconId] as? String{
                    room.iconId = iconId
                }
                
                if
                    let lat = roomInfo![RoomKeys.latitude] as? Double,
                    lat != 0
                {
                    room.latitude = lat
                }
                
                if
                    let long = roomInfo![RoomKeys.longitude] as? Double,
                    long != 0
                {
                    room.longitude = long
                }
                
                completion(room)
                
            }
            else {
                print(error?.localizedDescription)
                completion(nil)
                return
            }
        }

    }
    
    
    
    class func getBuilding(withId buildingId: String, completion:@escaping (_ building: Building?) -> Void) {
        
        let building = Building()
        
        building.id = buildingId
        
        // Getting building information
        
        let buildingTable = MSTable(name: Entities.building, client: MSClient(applicationURLString: ServiceUrl))
        
        buildingTable.read(withId: buildingId) { bldInfo, error in  // ([NSObject : AnyObject]?, NSError?)
            if error == nil {
                
                if bldInfo == nil {
                    completion(nil)
                    return
                }
        
                if let acronym = bldInfo![BuildingKeys.acronymName] as? String{
                    building.acronym = acronym
                }
                
                if let name = bldInfo![BuildingKeys.buildingName] as? String{
                    building.name = name
                }
                
                if let longitude = bldInfo![BuildingKeys.longitude] as? Double{
                    building.longitude = longitude
                }
                
                if let latitude = bldInfo![BuildingKeys.latitude] as? Double{
                    building.latitude = latitude
                }
                
                completion(building)

            }
            else {
                print(error?.localizedDescription)
                completion(nil)
                return
            }
        }
        
    }
    
    
    class func getEvent(withId eventId: String, completion:@escaping (_ event: Event?, _ eventAnyData: [AnyHashable : Any]) -> Void) {
        
        // Getting Event information
        
        let eventsTable = MSTable(name: Entities.Event, client: MSClient(applicationURLString: ServiceUrl))
    
        eventsTable.read(withId: eventId) { (eventInfo: [AnyHashable : Any]?, error: Error?) in
            
            if
                error == nil,
                let eventDict = eventInfo
            {
                
                print(eventInfo)
                
                let event = Event()
                
//                Optional([AnyHashable("sDateDotNet"): 2017-09-07 07:05:45 +0000, AnyHashable("buildingId"): <null>, AnyHashable("name"): One, AnyHashable("deleted"): 0, AnyHashable("eDateDotNet"): 2017-09-07 07:05:51 +0000, AnyHashable("createdAt"): 2017-09-07 07:05:50 +0000, AnyHashable("description"): Two, AnyHashable("imageData"): <null>, AnyHashable("latitude"): 30.290037, AnyHashable("id"): alpha_numeric_value, AnyHashable("updatedAt"): 2017-09-07 07:05:50 +0000, AnyHashable("version"): AAAAAAAAIzc=, AnyHashable("sDateEpoch"): 1504767945, AnyHashable("longitude"): -97.735409, AnyHashable("eDateEpoch"): 0, AnyHashable("mainPictureUrl"): <null>])
                
                if let eventId = eventDict[EventKeys.id] as? String {
                    event.id = eventId
                }
                
                if let name = eventDict[EventKeys.name] as? String {
                    event.name = name
                }
                
                if let description = eventDict[EventKeys.description] as? String {
                    event.description = description
                }
                
                if let startEpochTime = eventDict[EventKeys.sDateEpoch] as? Int {
                    event.date = Date(timeIntervalSince1970: Double(startEpochTime))
                }
                
                if let lat = eventDict[EventKeys.latitude] as? Double {
                    event.latitude = lat
                }
                
                if let long = eventDict[EventKeys.longitude] as? Double {
                    event.longitude = long
                }
                
                completion(event, eventInfo!)
            }
            else {
                print(error?.localizedDescription)
                let temp = [AnyHashable : Any]()
                completion(nil, temp)
                return
            }
        }

    }
    
    class func getAvailabeTimes(withRoomId roomId: String, completion:@escaping (_ avTimes: [WeekDay: AvailableTimes]?,  _ listOfTimesID: [String]?) -> Void) {
        
        var avTimes = [WeekDay: AvailableTimes]()
        var listOfId = [String]()
        
        // Getting time information
        
        let idPredicate = NSPredicate(format: "\(RoomTimeKeys.roomId) = '\(roomId)'")
        
        let timesTable = MSTable(name: Entities.roomTime, client: MSClient(applicationURLString: ServiceUrl))
        
        timesTable.read(with: idPredicate) { result, error in   //(MSQueryResult?, NSError?)
            
            if error == nil {
                
                if result == nil {
                    completion(nil, nil)
                    return
                }
                
                let response = result! as MSQueryResult
                
                avTimes = TimesHelper.initWeekDayToAVTimes()
                
                var counter = 0     // The purpose of this counter is to be able to create the .rawTime[counter] = some TimeSet() object. When these times are actually displayed, this counter will be overriden by an actual index (which marks the placement of the time)
                
                for item in response.items! {
                    
                    counter += 1
                    
                    let timeId = item[RoomTimeKeys.timeId] as? String
                    let day = item[RoomTimeKeys.dayOfWeek] as? String
                    let start = item[RoomTimeKeys.start] as? Float
                    let end = item[RoomTimeKeys.end] as? Float
                    
                    
                    if
                        day != nil,
                        start != nil,
                        end != nil,
                        timeId != nil
                        {
                        let weekDay = TimesHelper.weekDayEnum(fromString: day!)
                        avTimes[weekDay]!.rawTimes[counter] = TimeSet(s: start!, e: end!)
                        listOfId.append(timeId!)
                    }
             
                }
                
                completion(avTimes, listOfId)
                
            }
            else {
                print(error?.localizedDescription)
                completion(nil, nil)
                return
            }
            
        }
        
    }
    
    class func _getRoomWithID(_ roomId: String, completion:@escaping (_ room: Room?, _ building: Building?, _ avTimes: [WeekDay: AvailableTimes]?) -> Void) {
        
        // debug stuff //
        let weekDays = [WeekDay.sunday, WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]
        // //
        
        let room = Room()
        var avTimes = [WeekDay: AvailableTimes]()
        let building = Building()
        room.building = building
        
        // Getting room information
        
        let roomTable = MSTable(name: Entities.room, client: MSClient(applicationURLString: ServiceUrl))
        
        roomTable.read(withId: roomId) { roomInfo, error in  // ([NSObject : AnyObject]?, NSError?)
            if error == nil {
                
                if roomInfo == nil {
                    completion(nil, nil, nil)
                    return
                }
                
                if let roomID = roomInfo![RoomKeys.id] as? String{
                    room.id = roomID
                }
                
                if let bldId = roomInfo![RoomKeys.buildingId] as? String{
                    room.building.id = bldId
                }
                
                if let flr = roomInfo![RoomKeys.floor] as? String{
                    room.floor = flr
                }
                
                if let roomNum = roomInfo![RoomKeys.roomNum] as? String{
                    room.roomNum = roomNum
                }
                
                if let iconId = roomInfo![RoomKeys.iconId] as? String{
                    room.iconId = iconId
                }
                
            }
            else {
                print(error?.localizedDescription)
                return
            }
        }
//        Optional([id: alpha_numeric_value, updatedAt: 2017-04-02 19:31:42 +0000, version: AAAAAAAADD4=, roomNumber: 31k32, buildingId: alpha_numeric_value, longitude: 0, buildingName: <null>, latitude: 0, creatorUserID: alpha_numeric_value, deleted: 0, iconId: bank.png, floor: 12654, createdAt: 2017-04-02 19:31:42 +0000])

        // Getting time information
        
        let idPredicate = NSPredicate(format: "\(RoomTimeKeys.roomId) = '\(roomId)'")
        
        let timesTable = MSTable(name: Entities.roomTime, client: MSClient(applicationURLString: ServiceUrl))
        
        timesTable.read(with: idPredicate) { result, error in   //(MSQueryResult?, NSError?)
            if error == nil {
                
                if result == nil {
                    completion(nil, nil, nil)
                    return
                }
                
                let response = result! as MSQueryResult
                
                avTimes = TimesHelper.initWeekDayToAVTimes()
                
                
                for t in weekDays {
                    let g = avTimes[t]?.dayChar
                    let h = avTimes[t]?.dayOfWeek
                    let v = avTimes[t]?.rawTimes
                    print(g)
                    print(h)
                    print(v)
                }
                
                
                var counter = 0     // The purpose of this counter is to be able to create the .rawTime[counter] = some TimeSet() object. When these times are actually displayed, this counter will be overriden by an actual index (which marks the placement of the time)
                
                for item in response.items! {
                    
                    counter += 1
                    
                    let day = item["dayOfWeek"] as? String
                    let start = item["start"] as? Float
                    let end = item["end"] as? Float
                    
                    if day != nil && start != nil && end != nil {
                        let weekDay = TimesHelper.weekDayEnum(fromString: day!)
                        avTimes[weekDay]!.rawTimes[counter] = TimeSet(s: start!, e: end!)
                    }
                    
                    
//                    if let day = item["dayOfWeek"] as? String {
//                        
//                        if let start = item["start"] as? Float {
//                            
//                            if let end = item["end"] as? Float {
//                                
//                                let weekDay = TimesHelper.weekDayEnum(fromString: day)
//                                
//                                avTimes[weekDay]?.rawTimes[counter] = TimeSet(s: start, e: end)
//                                
//                            }
//                            
//                        }
//                        
//                    }

                }
                
            }
            else {
                print(error?.localizedDescription)
                return
            }
            
            
            print("-----------")
            for t in weekDays {
                let g = avTimes[t]?.dayChar
                let h = avTimes[t]?.dayOfWeek
                let v = avTimes[t]?.rawTimes
                print(g)
                print(h)
                print(v)
            }
            print("-----------")
            
        }

        
        
        
//            let d = (avTimes[WeekDay.Wednesday]?.formattedTimesForDisplay())! as [String]
//            print(d)
        
        // Getting building information
        
        let buildingTable = MSTable(name: Entities.building, client: MSClient(applicationURLString: ServiceUrl))
        
        buildingTable.read(withId: "<fake_db_id>") { dict, error in  // ([NSObject : AnyObject]?, NSError?)
            if error == nil {
                print(dict as Any)
            }
            else {
                print(error?.localizedDescription as Any)
                return
            }
        }

        
    }
    
    // Delete single item from back-end table using Microsoft Azure framework
    class func deleteItem(withId itemId: String, entity ent:String, completion:@escaping IsSuccesful) {
        
        let msTable = MSTable(name: ent, client: MSClient(applicationURLString: ServiceUrl))

        msTable.delete(withId: itemId) { (result: Any?, error: Error?) in
            if error == nil {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
}
