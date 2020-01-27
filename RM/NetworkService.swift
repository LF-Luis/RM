//
//  NetworkService.swift
//  MobileTasks.iOS
//
//  Created by kevin Ford on 3/30/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

protocol NetworkProtocol {
    func login(_ serviceProvider : String, controller : UIViewController, completion :@escaping IsSuccesful) -> Void
    func hasPreviousAuthentication() -> Bool
    func getClient() -> MSClient
    func logout(_ completion:@escaping (_ error: Error?) -> Void)
    func upsert(building bld:Building, completion:@escaping IsSuccesful) -> Void
}


class NetworkService : NetworkProtocol {
 
    static var microsoftClient : MSClient?
    
    // Start microsoft network connection if it has not been started yet
    init () {
        if (NetworkService.microsoftClient == nil) {
            NetworkService.microsoftClient = MSClient(applicationURLString: ServiceUrl)
        }
    }
    
    func getClient() -> MSClient {
        return NetworkService.microsoftClient!
    }
    
    func login(_ serviceProvider: String, controller: UIViewController, completion: @escaping IsSuccesful) {
//        NetworkService.microsoftClient?.loginViewControllerWithProvider(serviceProvider, completion: { (user: MSUser?, error: NSError?) in
//            if (user != nil) {
//                let currentToken : String = (user?.mobileServiceAuthenticationToken!)!
//                let currentUserId : String = (user?.userId)!
//                
//                NSUserDefaults.standardUserDefaults().setObject(serviceProvider, forKey: LastUsedProvider)
//                //                NSUserDefaults.standardUserDefaults().setObject(currentUserId, forKey: UserId)
//                //                NSUserDefaults.standardUserDefaults().setObject(currentToken, forKey: Token)
//                NSUserDefaults.standardUserDefaults().setObject(currentUserId, forKey: serviceProvider + UserId)
//                NSUserDefaults.standardUserDefaults().setObject(currentToken, forKey: serviceProvider + Token)
//                
//                completion(isSuccesful: true)
//                
//                return
//            }
//            print("Error at login: \(error?.localizedDescription)")
//            completion(isSuccesful: false)
//            return
//        })
        
        
//            NetworkService.microsoftClient?.login(withProvider: serviceProvider,  controller: controller, animated: false, completion: { (user : MSUser?, error : NSError?) -> Void in
//            if (user != nil) {
//                let currentToken : String = (user?.mobileServiceAuthenticationToken!)!
//                let currentUserId : String = (user?.userId)!
//                
//                UserDefaults.standard.set(serviceProvider, forKey: LastUsedProvider)
////                NSUserDefaults.standardUserDefaults().setObject(currentUserId, forKey: UserId)
////                NSUserDefaults.standardUserDefaults().setObject(currentToken, forKey: Token)
//                UserDefaults.standard.set(currentUserId, forKey: serviceProvider + UserId)
//                UserDefaults.standard.set(currentToken, forKey: serviceProvider + Token)
//                completion(true)
//                return
//            }
//            print("Error at login: \(error?.localizedDescription)")
//            completion(false)
//            return
//        })
        
        
        
        
//        NetworkService.microsoftClient?.login(withProvider: serviceProvider,  controller: controller, animated: false, completion: { (user : MSUser?, error : NSError?) -> Void in
//            
//            if (user != nil) {
//                let currentToken : String = (user?.mobileServiceAuthenticationToken!)!
//                let currentUserId : String = (user?.userId)!
//                
//                UserDefaults.standard.set(serviceProvider, forKey: LastUsedProvider)
//                //                NSUserDefaults.standardUserDefaults().setObject(currentUserId, forKey: UserId)
//                //                NSUserDefaults.standardUserDefaults().setObject(currentToken, forKey: Token)
//                UserDefaults.standard.set(currentUserId, forKey: serviceProvider + UserId)
//                
//                UserDefaults.standard.set(currentToken, forKey: serviceProvider + Token)
//                
//                completion(true)
//                
//                return
//            }
//            
//            print("Error at login: \(error?.localizedDescription)")
//            completion(false)
//            return
//            
//        } as? MSClientLoginBlock)
        
        NetworkService.microsoftClient?.login(withProvider: serviceProvider, controller: controller, animated: false, completion: { (user: MSUser?, error: Error?) in
            
            if user != nil {
                let currentToken : String = (user?.mobileServiceAuthenticationToken!)!
                let currentUserId : String = (user?.userId)!
                
                UserDefaults.standard.set(serviceProvider, forKey: LastUsedProvider)
                //                NSUserDefaults.standardUserDefaults().setObject(currentUserId, forKey: UserId)
                //                NSUserDefaults.standardUserDefaults().setObject(currentToken, forKey: Token)
                UserDefaults.standard.set(currentUserId, forKey: serviceProvider + UserId)
                
                UserDefaults.standard.set(currentToken, forKey: serviceProvider + Token)
                
                completion(true)
            }
            else {
                print("Error at login: \(String(describing: error?.localizedDescription))")
                completion(false)
            }
            
        })
        
    }
    
    func hasPreviousAuthentication() -> Bool {
        
        let userDefaults : UserDefaults = UserDefaults.standard
        
        if (userDefaults.object(forKey: LastUsedProvider) != nil) {
            let serviceProvider : String = userDefaults.object(forKey: LastUsedProvider) as! String
            let currenttoken : String = userDefaults.object(forKey: serviceProvider + Token) as! String
            if (userDefaults.object(forKey: serviceProvider + Token) != nil) {
                let currentUserId : String = userDefaults.object(forKey: serviceProvider + UserId) as! String
                
//                NetworkService.microsoftClient?.currentUser = MSUser(userId: currentUserId)
//                NetworkService.microsoftClient?.currentUser!.mobileServiceAuthenticationToken = currenttoken
                return true
            }
        }
        return false
    }
    
    func logout(_ completion: @escaping (_ error: Error?) -> Void) {
        
        NetworkService.microsoftClient?.logout(completion: { (error: Error?) in
            if error == nil {
                
                let userDefaults : UserDefaults = UserDefaults.standard
                
                if (userDefaults.object(forKey: LastUsedProvider) != nil) {
                    let serviceProvider = LastUsedProvider
                    let currenttoken = serviceProvider + Token
                    
                    if (userDefaults.object(forKey: currenttoken) != nil) {
                        
                        userDefaults.removeObject(forKey: currenttoken)
                        
                        let currentUserId = serviceProvider + UserId
                        
                        if (userDefaults.object(forKey: currentUserId) != nil) {
                            userDefaults.removeObject(forKey: currentUserId)
                        }
                        
                    }
                    
                    userDefaults.removeObject(forKey: serviceProvider)
                }
                
                // clearing all cookies related to this app so that when user tries to login again, it will haved the user's credentials
                let cookies = HTTPCookieStorage.shared.cookies
                
                if cookies != nil {
                    if !(cookies?.isEmpty)! {
                        for item in cookies! {
                            HTTPCookieStorage.shared.deleteCookie(item)
                        }
                    }
                }
            }
            else {
                print("Error at logout: \(String(describing: error?.localizedDescription))")
            }
            completion(error)
        })
        
//        NetworkService.microsoftClient?.logout(completion: { (error: NSError?) in
//            if (error == nil) {
//                
//                let userDefaults : UserDefaults = UserDefaults.standard
//                
//                if (userDefaults.object(forKey: LastUsedProvider) != nil) {
//                    let serviceProvider = LastUsedProvider
//                    let currenttoken = serviceProvider + Token
//                    
//                    if (userDefaults.object(forKey: currenttoken) != nil) {
//                        
//                        userDefaults.removeObject(forKey: currenttoken)
//                        
//                        let currentUserId = serviceProvider + UserId
//                        
//                        if (userDefaults.object(forKey: currentUserId) != nil) {
//                            userDefaults.removeObject(forKey: currentUserId)
//                        }
//                        
//                    }
//                    
//                    userDefaults.removeObject(forKey: serviceProvider)
//                }
//                
//                // clearing all cookies related to this app so that when user tries to login again, it will haved the user's credentials
//                let cookies = HTTPCookieStorage.shared.cookies
//                
//                if cookies != nil {
//                    if !(cookies?.isEmpty)! {
//                        for item in cookies! {
//                            HTTPCookieStorage.shared.deleteCookie(item)
//                        }
//                    }
//                }
//            }
//            
//            if error != nil {
//                print("Error at logout: \(error?.localizedDescription)")
//            }
//            
//            completion(error)
//            
//        } as! MSClientLogoutBlock)
    }
    
    func printDebugData() {
        let t = NetworkService.microsoftClient?.currentUser
        let g = t!.mobileServiceAuthenticationToken
        
        print("*** MSUser content ***")
        print("MS current user: \(String(describing: t))")
        print("MS token: \(String(describing: g))\n")
        
        print("*** Stored login data ***")
        let userDefaults : UserDefaults = UserDefaults.standard
        
        if (userDefaults.object(forKey: LastUsedProvider) != nil) {
            let serviceProvider = LastUsedProvider
            let currenttoken = serviceProvider + Token
            
            if (userDefaults.object(forKey: currenttoken) != nil) {
                
                print("Current token: \(String(describing: userDefaults.object(forKey: currenttoken)))")
                
                let currentUserId = serviceProvider + UserId
                
                if (userDefaults.object(forKey: currentUserId) != nil) {
                    
                }
                
            }
            
        }
        
        print("\n****************")
    }
    
//    func getTasks(completion: TaskResponse) -> Void {
//        NetworkService.microsoftClient?.invokeAPI("task", body: nil, HTTPMethod: "GET", parameters: nil, headers: nil, completion: {(result : AnyObject?,
//            response : NSHTTPURLResponse?,
//            error : NSError?) -> Void in
//            if (error == nil) {
//                let returnValue : Array<MobileTask> = self.decodeJsonList(result!)
//                completion(returnValue, nil)
//            } else {
//                completion(nil, error!)
//            }
//            
//        })
//    }
    

//    func decodeJsonList(target: AnyObject) -> Array<MobileTask> {
//        var returnValue : Array<MobileTask> = Array<MobileTask>()
//        
//        let dictionary : [NSDictionary] = target as! [NSDictionary]
//        
//        for task in dictionary {
//            let mobileTask = decodeJson(task)
//            returnValue.append(mobileTask)
//        }
//        return returnValue;
//    }
    
//    func decodeJson(task: NSDictionary) -> MobileTask {
//        let mobileTask : MobileTask = MobileTask()
//        mobileTask.id = task["id"] as! Int
//        mobileTask.sid = task["sid"] as! String
//        mobileTask.taskDescription = task["description"] as! String
//        mobileTask.dateCreated = task["dateCreated"] as? NSDate
//        mobileTask.dateDue = task["dateDue"] as? NSDate
//        mobileTask.dateCompleted = task["dateCompleted"] as? NSDate
//        mobileTask.isCompleted = task["isCompleted"] as! Bool
//        return mobileTask
//    }
    
//    func encodeJson(source: MobileTask) -> NSMutableDictionary {
//        let jsonObject: NSMutableDictionary = [
//            "id" : source.id,
//            "sid" : source.sid,
//            "description" : source.taskDescription,
//            "isCompleted": source.isCompleted
//        ]
//        if (source.dateCreated != nil) {
//            jsonObject.setValue(source.dateCreated!, forKey: "dateCreated")
//        }
//        if (source.dateDue != nil) {
//            jsonObject["dateDue"] = source.dateDue!
//        }
//        if (source.dateCompleted != nil) {
//            jsonObject["dateCompleted"] = source.dateCompleted!
//        }
//
//        return jsonObject
//    }
    
//    func upsertTask(task: MobileTask, completion: TaskSaveResponse) -> Void {
//        
//        let jsonTask : NSMutableDictionary = self.encodeJson(task) as NSMutableDictionary
//        NetworkService.microsoftClient?.invokeAPI("task", body: jsonTask, HTTPMethod: "POST", parameters: nil, headers: nil, completion: { (result : AnyObject?, response: NSHTTPURLResponse?, error : NSError?) in
//            if (error == nil) {
//                completion(self.decodeJson(result! as! NSDictionary), nil)
//            } else {
//                completion(nil, error)
//            }
//        })
//    }
    
    func encodeJson(forBuilding source: Building) -> NSMutableDictionary {
        
        let jsonObject: NSMutableDictionary = [
            BuildingKeys.acronymName : source.acronym,
            BuildingKeys.buildingName : source.name //,
//            BuildingKeys.latitude : source.latitude,
//            BuildingKeys.longitude: source.longitude
        ]
        
        return jsonObject
    }
    
    func upsert(building bld:Building, completion: @escaping IsSuccesful) {
        
        let jsonBuilding: NSMutableDictionary = encodeJson(forBuilding: bld) as NSMutableDictionary
        
        NetworkService.microsoftClient?.invokeAPI("BuildingApi", body: jsonBuilding, httpMethod: "POST", parameters: nil, headers: nil, completion: { (result: AnyObject?, response: HTTPURLResponse?, error: NSError?) in
            
            if result != nil {
                print("------ Result -------")
                print(result)
            }
            
            if response != nil {
                print("------ Response -------")
                print(response)
                print("-----------------------")
            }
            
            if error == nil {
                completion(true)
            }
            else {
                print("Error upserting building: \(error?.localizedDescription)")
                completion(false)
            }
        } as! MSAPIBlock)
        
    }
    
    func upsert(room rm:Room, completiong: IsSuccesful) {
        
    }
    
    
}
