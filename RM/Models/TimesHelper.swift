//
//  AvailableTimes.swift
//  RM
//
//  Created by Luis Fernandez on 8/3/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

class RMWeekDays {
    static let Sunday = "Sunday"
    static let Monday = "Monday"
    static let Tuesday = "Tuesday"
    static let Wednesday = "Wednesday"
    static let Thursday = "Thursday"
    static let Friday = "Friday"
    static let Saturday = "Saturday"
    static let defaultDay = "NoDaySet"
}

// Class deprecated because functionability will be implemented in backend
struct TimeSet {
    let s, e: Float
    let timeId: String?
//    let s: Float! // start time
//    let e: Float! // end time
//    let timeId: String? // back-end table time id
    init(s: Float, e: Float) {
        self.s = s
        self.e = e
        self.timeId = nil
    }
    
    init(s: Float, e: Float, timeID: String?) {
        self.s = s
        self.e = e
        if timeID != nil {
            self.timeId = timeID!
            return
        }
        self.timeId = nil
    }
    
}

class TimesHelper {
    
    class func absHourDifference(date1: Date, date2: Date) -> Int {
    // This function takes in two Date objects and returns the absolute value difference of them
        return abs(
            Calendar.current.component(.hour, from: date1) - Calendar.current.component(.hour, from: date2)
        )
    }
    
    class func initWeekDayToAVTimes() -> [WeekDay: AvailableTimes] {
    // Returns a dictionary with keys that hold the seven days of the week (.Monday thru .Friday)
    // Each AvailableTimes value is empty (no TimeSets) but does have the day's initials (i.e: "M" for Monday)

        var result = [WeekDay: AvailableTimes]()
        
        let weekDays = [WeekDay.sunday, WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]
        
        let day = ["S", "M", "T", "W", "T", "F", "S"]
        
        for i in 0...(weekDays.count - 1) {
            
            let tempAvTime = AvailableTimes()
            
            tempAvTime.dayChar = day[i]
            tempAvTime.dayOfWeek = weekDays[i]
            
            result[weekDays[i]] = tempAvTime
            
        }
        
        return result
    }
    
    /// Return day as string from WeekDay enum
    class func stringDay(fromWeekDay wd: WeekDay) -> String {
        switch wd {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        }
    }
    
    /// Returns WeekDay enum from week day string
    class func weekDayEnum(fromString s: String) -> WeekDay {
        switch s {
        case "Monday":
            return .monday
        case "Tuesday":
            return .tuesday
        case "Wednesday":
            return .wednesday
        case "Thursday":
            return .thursday
        case "Friday":
            return .friday
        case "Saturday":
            return .saturday
        case "Sunday":
            return .sunday
        default:
            return .monday
        }
    }
    
    class func formattedTimeMeridiem(fromDate day: Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: day)
        
    }
    
    /// Returns Week Day enum result from NSDate passed
    class func weekDay(forDate d: Date) -> WeekDay {
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "EEEE"
        return weekDayEnum(fromString: dFormatter.string(from: d))
    }
    
    // convert raw times [16, 19] to string with correct time formatt: "4-7 PM"
    class func formattedTime(start s: Float, end e: Float) -> String {
        return toTime(from: s) + "-" + toTimeWithMeridiem(from: e)
    }
    
    // returns string in format 1:30 PM from float 13.5
    // if no minutes exist, it will return 1 PM
    // AM or PM is aggregated accordingly
    fileprivate class func toTimeWithMeridiem(from num: Float) -> String {
        let n = Int(num)
        let d = ((num - Float(n)) * 60)
        return String(format: "\(n > 12 ? n - 12 : n)" + "\( d != 0 ? ":" + "%g" : "" )" + "\(n > 11 ? " PM" : " AM")", d)
    }
    
    // returns string in format 1:30 from float 13.5
    // if no minutes exist, it will return 1
    fileprivate class func toTime(from num: Float) -> String {
        let n = Int(num)
        let d = ((num - Float(n)) * 60)
        return String(format: "\(n > 12 ? n - 12 : n)" +  "\( d != 0 ? ":" + "%g" : "" )", d)
    }
    

}
 
enum TimeAppendError {
    // NetworkConnectionFailed: failed to add TimeSet due to network error
    // TimeSetExists: TimeSet being added already exists
    // TimeSetReversed: TimeSet has a starting time greater than ending time. I.e.: TimeSet(s: 3.0, e: 1.0)
    case networkConnectionFailed, timeSetExists, timeSetReversed, noTimeSetWasAdded, none
}

class AvailableTimesCompletion {
    var isSuccessful = false
    var timeAppendError: TimeAppendError?
    
    init (isSuccessful: Bool, timeAppendError: TimeAppendError) {
        self.isSuccessful = isSuccessful
        self.timeAppendError = timeAppendError
    }

}

/**
 This class handles raw times (in 24 hr formatt) and converts them into 12 hr formatt with AM PM as needed.
 This class also sets the times in order, and check that time intervals do not overlap each other.
 */

class AvailableTimes: NSObject {
    
    var rawTimes = [Int: TimeSet]()   // this is used for storing raw values in 24 hour formatt, and used in most logic
    
    var roomId = ""
    
    var dayOfWeek: WeekDay?
    
    /**
     First character of the day. I.e.: T for tuesday
     */
    var dayChar: String?
    
    override init() {
        super.init()
    }
    
    /**
     Use when this object is being mutated. For safety that hours do not overlap and that they are in range of 0...24
     */
    func append(rawTimes s: [TimeSet], overrideOverlappingTimes: Bool, completion:((_ aTCompletion: AvailableTimesCompletion) -> Void)) {
        
        var _aTCompletion = AvailableTimesCompletion(isSuccessful: false, timeAppendError: .noTimeSetWasAdded)
        let origTimeSet = Array(rawTimes.values)    // Original array of TimeSets
        
        if s.count < 1 {
            completion(_aTCompletion)
            return
        }
        
        var fixedTimeSet = [TimeSet]()
        
        for timeSet in s {
            if timeSet.e <= timeSet.s {
                // member is s is notformatted correctly
                _aTCompletion.timeAppendError = .timeSetReversed
                completion(_aTCompletion)
                return
            }
            
            for origSet in origTimeSet {
                
                if (timeSet.s >= origSet.s && timeSet.s <= origSet.e) || (timeSet.e >= origSet.s && timeSet.e <= origSet.e) || (timeSet.s <= origSet.s && timeSet.e >= origSet.e) {
                    
                    // fails because timeSet overlaps origset
                    _aTCompletion.timeAppendError = .timeSetExists
                    
                    if !overrideOverlappingTimes {
                        completion(_aTCompletion)
                        return
                    }
                }
                else {
                    fixedTimeSet.append(origSet)
                }
            }
        }
        
        var ttt = [TimeSet]()
        rawTimes.removeAll()
        
        if overrideOverlappingTimes {
            // In this case, even if the new times overlapped the old times, the old times were deleted and only new times kept.
            ttt = fixedTimeSet + s
        }
        else {
            // In this case, new times are set if they did not overlap old times.
            ttt = origTimeSet + s
        }
        
        //        let t = s + Array(rawTimes.values)
//        
//        if t.count < 1 {
//            completion(aTCompletion: _aTCompletion)
//            return
//        }
//        
//        // note:
//        // s is start time
//        // e is end time
//        
//        // Edit (later, this works fine): Use the Dictionary key to loop through them
//        for i in 0...(t.count - 1) {
//            if t[i].s >= t[i].e || t[i].s > 24 || t[i].e > 24 || t[i].s < 0 || t[i].e < 0 {
//                // fails to add because greater time put first or times times were the same
//                _aTCompletion.timeAppendError = .TimeSetReversed
//                completion(aTCompletion: _aTCompletion)
//                return
//            }
//            
//            for j in i...(t.count - 1) {
//                if j == (t.count - 1) { break }
//                let k = j + 1
//                
//                if t[i].s <= t[k].s {
//                    if t[i].e > t[k].s {
//                        // fails because set overlaps or they are the same
//                        _aTCompletion.timeAppendError = .TimeSetExists
//                        completion(aTCompletion: _aTCompletion)
//                        return
//                    }
//                }
//                
//                if t[i].s > t[k].s && t[i].s < t[k].e {
//                    // fails because times overlap or they are the same
//                    _aTCompletion.timeAppendError = .TimeSetExists
//                    completion(aTCompletion: _aTCompletion)
//                    return
//                }
//            }
//            
//        }
        
        giveRandomKey(valuesFromBackend: ttt)
        
        sortRawTimes()
        
        _aTCompletion = AvailableTimesCompletion(isSuccessful: true, timeAppendError: .none)
        
        completion(_aTCompletion)
        
    }
    
    /**
     Use for ease of appending using arrays. I.e.: [ [1, 2], [4, 6] ]
     This goes through append(rawTimes t: [TimeSet], completion:((isSuccesful: Bool) -> Void))
     */
    func append(usingArray s: [[Float]], completion:@escaping ((_ isSuccesful: Bool) -> Void)) {
        
        var timeSet = [TimeSet]()
        
        for item in s {
            let temp = TimeSet(s: item[0], e: item[1])
            timeSet.append(temp)
        }
        
        self.append(rawTimes: timeSet, overrideOverlappingTimes: false) { (aTCompletion) in
            completion(aTCompletion.isSuccessful)
        }
        
    }
    
////     Not safe, only use when appending from an API call which should be have times in order and not overlapping
//        func unsafeAppend(usingString s: String) {
//            let arrOfS = s.componentsSeparatedByString(",")
//            let max = 0...arrOfS.count - 1
//    
//            if max.count < 1 { return }
//    
//            for i in max where (i % 2 == 0) {
//                rawTimes[i/2] = TimeSet(s: Float(arrOfS[i]), e: Float(arrOfS[i+1]))
//            }
//    
//        }
    
    /**
     Should only be used when it is known that the times do not overlap, and are correctly formatted.
     */
    fileprivate func giveRandomKey(valuesFromBackend s: [TimeSet]) {
        
        let max = s.count - 1
        
        if max < 0 { return }
        
        for i in 0...max {
            rawTimes[i] = s[i]
        }
        
    }
    
    /**
     Returns as array of strings formatted (in our way): [ "9-10 AM" "1-2 PM", "4-5 PM" ]
     */
    func sortRawTimes() {
        
        var newDict = [Int: TimeSet]()
        
        var i: Int = 0
        
        for (_,v) in (Array(rawTimes).sorted {$0.1.s < $1.1.s}) {
            newDict[i] = v
            i += 1
        }
        
        rawTimes = newDict
    }
    
    // returns string in format 1:30 PM from float 13.5
    // if no minutes exist, it will return 1 PM
    // AM or PM is aggregated accordingly
    fileprivate func toTimeWithMeridiem(from num: Float) -> String {
        let n = Int(num)
        let d = ((num - Float(n)) * 60)
        return String(format: "\(n > 12 ? n - 12 : n)" + "\( d != 0 ? ":" + "%g" : "" )" + "\(n > 11 ? " PM" : " AM")", d)
    }
    
    // returns string in format 1:30 from float 13.5
    // if no minutes exist, it will return 1
    fileprivate func toTime(from num: Float) -> String {
        let n = Int(num)
        let d = ((num - Float(n)) * 60)
        return String(format: "\(n > 12 ? n - 12 : n)" +  "\( d != 0 ? ":" + "%g" : "" )", d)
    }
    
    fileprivate func formattedTimeRange(_ timeSet: TimeSet) -> String {
        return toTime(from: timeSet.s) + "-" + toTimeWithMeridiem(from: timeSet.e)
    }
    
    // These functions returned values that can be used to teporarly display data that is being edited, as well as return data in a formatt to create/override model instances in the backend
    
    // All of these will be formatted properly and in order
    
    func formattedTimesForDisplay() -> [String] {
        
        var retStr = [String]()
        
        let maxItems = Array(rawTimes.keys).count
        if !rawTimes.isEmpty {
            print("is not empty")
        }
        if maxItems > 0 {
            
            for i in 0...(maxItems - 1) {
                let p = i
                let y: Float = (rawTimes[0]?.s)!
                let j = rawTimes[i]?.e
//                let k = rawTimes[i].s
                if rawTimes[i]!.e == nil || rawTimes[i]!.s == nil { continue }
                retStr.append(formattedTimeRange(rawTimes[i]!))
            }
            
        }
        
        return retStr
        
    }
    
    //    func formattedTimesForAPI() -> String {
    //        var retStr = String()
    //
    //        let maxItems = Array(rawTimes.keys).count - 1
    //
    //        if maxItems < 1 { return retStr }
    //
    //        for i in 0...maxItems {
    //            retStr.appendContentsOf(formattedTimeRange(rawTimes[i]!) + "\( i == maxItems ? "" : "," )")
    //        }
    //
    //        return retStr
    //    }
    //
    //    func rawTimesForAPI() -> String {
    //        var retStr = String()
    //
    //        let maxItems = Array(rawTimes.keys).count - 1
    //
    //        if maxItems < 1 { return retStr }
    //
    //        for i in 0...maxItems {
    //            let t = rawTimes[i]!
    //            retStr.appendContentsOf(String(format: "%g,%g\( i == maxItems ? "" : "," )", t.s, t.e))
    //        }
    //        
    //        return retStr
    //    }
    
}


