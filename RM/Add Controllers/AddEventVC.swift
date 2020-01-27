//
//  AddEventVC.swift
//  RM
//
//  Created by Luis Fernandez on 7/22/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka
import MapKit
import ImageRow

class AddEventVC: BaseFormVC, MapVCDelegate {
    
    // MARK: - Variables
    
    private let event = Event()
    
    // Google maps SDK
    let mapVC = MapVC()
    fileprivate var getLocationSuccess = false
    fileprivate var lat = CLLocationDegrees()
    fileprivate var long = CLLocationDegrees()
    
    // Form
    private let locationSwitchKey = "locationSwitch"
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapVC.delegate = self
        setUpNavBar()
        loadForm()
        
        // Check if user has location enabled, if not, ask User to enable loaction
        Map.checkToEnableLocation(controller: self, dismissController: true, isAsync: true)
    }
    
    // MARK: - Setup
    
    func setUpNavBar() {
        navigationItem.title = "Add Event"
    }
    
    // MARK: - Form Actions
    
    func saveEvent() {

//        let (lat, long) = Map.getLocation()
        
//        let lat = 30.290037
//        let long = -97.735409
//        
//        DatabaseConnection.getRoomsMainDisplay(latitude: lat, longitude: long, forDay: TimesHelper.weekDay(forDate: Date()), lastRecordCount: 0) { (rooms: [Room]?) in
//            if rooms != nil {
//                for r in rooms! {
//                    print("\(r.floor)    \(r.roomNum)")
//                }
//            }
//        }
//        return
        
//        DatabaseConnection.getRoom(withId: "bdd7dc491d6d4591896df99904ea9acd") { (room: Room?) in
//            if room != nil {
//                print("\(room!.floor)    \(room!.roomNum)")
//            }
//        }
//        
//        return
        
//        Optional([AnyHashable("buildingId"): bdd7dc491d6d4591896df99904ea9acd, AnyHashable("deleted"): 0, AnyHashable("createdAt"): 2017-09-12 00:09:35 +0000, AnyHashable("roomNumber"): 31312121, AnyHashable("buildingName"): <null>, AnyHashable("latitude"): 30.290037, AnyHashable("id"): d558ee8a0e5d4b0ba753477bb2a1f66c, AnyHashable("updatedAt"): 2017-09-12 00:09:35 +0000, AnyHashable("version"): AAAAAAAAJ1Q=, AnyHashable("longitude"): -97.735409, AnyHashable("floor"): 1212123, AnyHashable("creatorUserID"): 0280f75971fb4b059b6bd8e2d22ca3cd, AnyHashable("iconId"): defaultRoomIconId])
            
//        Optional([AnyHashable("buildingId"): bdd7dc491d6d4591896df99904ea9acd, AnyHashable("deleted"): 0, AnyHashable("createdAt"): 2017-09-12 00:05:07 +0000, AnyHashable("roomNumber"): 3331, AnyHashable("buildingName"): <null>, AnyHashable("latitude"): 30.290037, AnyHashable("id"): 6090af4b89464a499e0839898fb5f1ba, AnyHashable("updatedAt"): 2017-09-12 00:05:07 +0000, AnyHashable("version"): AAAAAAAAJ0w=, AnyHashable("longitude"): -97.735409, AnyHashable("floor"): 2222, AnyHashable("creatorUserID"): 0280f75971fb4b059b6bd8e2d22ca3cd, AnyHashable("iconId"): defaultRoomIconId])
            
            
            
//
//        DatabaseConnection.getEventsForMainDisplay(latitude: lat!, longitude: long!, forDayAndTime: Date(), lastRecordCount: 0) { (events) in
//            print(events)
//            for event in events! {
//                print("\(event.name)   \(event.description)   \(event.id)")
//            }
//        }
//        
//        return
        
        // turn on overlay for view
        LoadOverlay.showOverlay(forView: self.view)
        
        let formValues = form.values()
        
        // Switch field (non-optional): location
        if let switchVal = formValues[locationSwitchKey] as? Bool {
            
            if !switchVal {
                // false: require user to input a location
                
                if lat != 0 && long != 0 && getLocationSuccess {
                    // User succesfully selected the locations
                    event.latitude = self.lat
                    event.longitude = self.long
                }
                else {
                    // error: "The Event's location neeeds to be added."
                    RMCustomAlerts.presentSimpleOkAlert(cotroller: self, title: "RM", message: "The Event's location neeeds to be added.", async: false)
                    LoadOverlay.endOverlay()
                    return
                }
                
            }
            else {
                // true: use current user's location
                let (lat, long) = Map.getLocation()
                
                if lat != nil && long != nil {
                    event.latitude = lat
                    event.longitude = long
                }
                else {
                    // error: "Could not get your location."
                    RMCustomAlerts.presentSimpleOkAlert(cotroller: self, title: "RM", message: "RM could not get your location, please try again.", async: false)
                    LoadOverlay.endOverlay()
                    return
                }
            }
            
        }
        
        // Optional field: Image
        if let img = formValues[EventKeys.imageData] as? UIImage {
            event.uiImage = img
        }
        else {
            event.uiImage = nil
        }
        
        // Required fields:
        if
            let name = formValues[EventKeys.name] as? String,
            let description = formValues[EventKeys.description] as? String,
            let date = formValues[EventKeys.date] as? Date
        {
            event.name = name
            event.description = description
            event.date = date
        }
        else {
            // error: "Event title, description, and date"
            RMCustomAlerts.presentSimpleOkAlert(cotroller: self, title: "RM", message: "The Event's title, description, and date are required.", async: false)
            LoadOverlay.endOverlay()
            return
        }
        
        DatabaseConnection.upsert(event: event) { (error: NSError?) in
            LoadOverlay.endOverlay()
            print(error as Any)
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                RMCustomAlerts.presentSimpleOkAlert(cotroller: self, title: "RM", message: "Could not add event at this time. Please try again.", async: true)
            }
            
        }
        
    }
    
    // MARK: MapVC Delegate Methods
    
    func didFinishSelectingLocation(_ sender: MapVC) {
        // Getting the cordinates where the user left the marker at
        if
            sender.latitude != nil,
            sender.longitude != nil
        {
            getLocationSuccess = true
            lat = sender.latitude!
            long = sender.longitude!
        }
    }
    
    func errorGettingAuthorization(_ sender: MapVC) {
        
        getLocationSuccess = false
        
        // this is async because this error handling via delegation is not in the main thread
        Map.openIphoneSettingsToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    // MARK: - Form
    
    func loadForm() {
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form
            +++ Section("Event Imformation:")
            
            <<< NameRow(EventKeys.name) { $0.title = "Title"
                $0.placeholder = "RM Seminar"
                $0.evaluateDisabled()
            }
            
            <<< TextAreaRow(EventKeys.description) {
                $0.placeholder = "DESCRIPTION: At the RM building, room 21. Learn how useful RM is! It'll last two hours."
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 60)
                $0.evaluateDisabled()
            }
            
            // Date and time picker
            <<< DateTimeRow(EventKeys.date) {
                $0.value = Date();
                $0.title = "Date and Time"
            }
            
            // take or select pic
//            <<< ImageRow(EventKeys.uiImage) { row in
//                
//                row.title = "Event Image or Flyer"
//                row.sourceTypes = [ .Camera, .PhotoLibrary]
//                row.clearAction = .yes(style: UIAlertActionStyle.destructive)
//            }
            
            // Switch based on what location to use
            +++ Section("Event Location:")
            <<< SwitchRow(locationSwitchKey){
                $0.title = "Use My Current Location"
                $0.value = true
            }

            <<< ButtonRow() {
                $0.title = "Drop Pin on Building's Location"
                mapVC.markerText = "Drag and Drop me to your building"
                mapVC.navigationItem.title = "Hold & Drag to Building Location"
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { self.mapVC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
//                $0.evaluateDisabled()
                $0.evaluateHidden()
                $0.hidden = .function([locationSwitchKey], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: self.locationSwitchKey)
                    return row.value ?? true == true
                })
            }
            
            +++ Section()
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Add Event"
                }  .onCellSelection({ (cell, row) in
                    self.saveEvent()
                })
    
    }
    
}
