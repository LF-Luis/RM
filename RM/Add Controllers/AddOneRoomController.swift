//
//  AddOneRoomController.swift
//  RM
//
//  Created by Luis Fernandez on 7/4/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import MapKit
import GoogleMaps

class AddOneRoomController: BaseFormVC, MapVCDelegate, AddTimesDelegate, UITextViewDelegate {
    
    // MARK: - Variables
    
    let room = Room()
    private var nearbyBldDict = [String: Building]()    // Building Name string: Building Object
    var addHoursController = AddTimeController()    // Use to add hours
    
    // Google maps SDK
    let mapVC = MapVC()
    fileprivate var getLocationSuccess = false
    fileprivate var lat = CLLocationDegrees()
    fileprivate var long = CLLocationDegrees()
    
    // Form
    private let nearbyBlOptionStr = "Nearby Building"
    private let addBldOptionStr = "Add Building"
    let buildingName = BuildingKeys.buildingName
    let buildingAcronym = BuildingKeys.acronymName
    
    // Form Keys
    private let floorNum = RoomKeys.floor     // from Rooms model
    private let roomNum = RoomKeys.roomNum     // from Rooms model
    private let bldPicker = "bldPicker"
    private let rmLocBool = "rmLocBool"
    private let noBldSelected = "I'll add the Building later."   // This key is used for the item in nearbyBldDict that means to building was selected
    
    // Form icon picker
//    private let buildingIcon = "bI"
//    fileprivate let iconSelector = BuildingIconsSelector()
//    fileprivate var iconSelected: String?
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVC.delegate = self
        addHoursController.delegate = self
        self.setUpNavBar()
        getBuildingsData()  // starting point (form UI is loaded in this function)
        
        // Check if user has location enabled, if not, ask User to enable loaction
        Map.checkToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Icon selection logic:
//        if iconSelector.bldSelected != nil {
//            iconSelected = iconSelector.bldSelected!
//        }
    }
    
    fileprivate func addAvailability(_ roomId: String) {
        addHoursController.roomTime.roomId = roomId
        navigationController?.pushViewController(addHoursController, animated: true)
    }
    
    // MARK: - Setup
    
    func setUpNavBar() {
        navigationItem.title = "Add A Room"
    }
    
    private func getBuildingsData() {
        
        LoadOverlay.showOverlay(forView: view)
        
        let (lat, long) = Map.getLocation()
        
        if lat != nil && long != nil {
            
            DatabaseConnection.getBuildingsForLocation(latitude: lat!, longitude: long!) { (bldDictData: [String : Building]?) in
                
                LoadOverlay.endOverlay()
                
                if bldDictData != nil {
                    // Data loaded correctly, load form
                    self.nearbyBldDict = bldDictData!
                    
                    let tempBld = Building()
                    self.nearbyBldDict[self.noBldSelected] = tempBld  // No building selected option (with empty Building object)
                    
                    LoadOverlay.endOverlay()
                    self.loadForm()
                    return
                }
                else {
                    // error: Could not load building data
                        // Show error to user, go back to main view
                    let alert = UIAlertController(title: "RM", message: "There was an error in the connection. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                    
                }
            }
        }

    }
    
    // MARK: - Form Actions
    
    func saveRoomButton() {
        // This function deals only with setting the BUILDING ID and LOCATION for the Room that will be added to the database
            // The Building can either be selected from the list or created by the user
                // When Building is selected from list, the room is given the building's location or the user has the option to let their own location be the room's location
                // When a new Building is created, whatever location was given to that building is also given to the room
        
        // turn on overlay for view
        LoadOverlay.showOverlay(forView: self.view)
        
        let room = Room()
        var building = Building()
        
        let formValues = form.values()
        
        // Get whether user wants to select a building or add a building
        let bldSegmentSelected = formValues["segments"] as? String
        
        if
            bldSegmentSelected == nearbyBlOptionStr,
            let bldSelected = formValues[bldPicker] as? String
        {
            
            if bldSelected == noBldSelected {
                // no building was selected. Using first value of buildings gotten from back-end
                building = (nearbyBldDict.first?.value)!
            }
            else {
                building = nearbyBldDict[bldSelected]!
            }
            
            room.buildingId = building.id   // Setting building ID for room

            if  // Setting location for room
                let setRoomLocToUserLoc = formValues[rmLocBool] as? Bool,
                setRoomLocToUserLoc == true
            {
                // get user's location, set it as room's location
                let (lat, long) = Map.getLocation()
                
                if lat != nil && long != nil {
                    room.latitude = lat!
                    room.longitude = long!
                }
                else {
                    room.longitude = building.longitude
                    room.latitude = building.latitude
                }
            }
            else {
                room.longitude = building.longitude
                room.latitude = building.latitude
            }
            
            self.addRoomToBackend(room: room)
            return
            
        }
        
        if bldSegmentSelected == addBldOptionStr {
            // Parse building info out
                // Give room the location given to the building
            // Add new building
                // Give room the Building ID returned when creating a new Building
                // Create room
                // Move to add times view
        
            let _buildingName = formValues[buildingName] as? String
            let _buildingAcronym = formValues[buildingAcronym] as? String
            
            // Ask to fully complete form
            if _buildingName == nil || _buildingAcronym == nil || getLocationSuccess == false {
                LoadOverlay.endOverlay()
                
                DispatchQueue.main.async(execute: { () -> Void in
                    AppDelegate.getAppDelegate().showMessage(self, message:"Please fully complete Building info.")
                })
                
                return
            }
            
            let building = Building()
            building.name = _buildingName!
            building.acronym = _buildingAcronym!.uppercased()
            building.longitude = Double(long)
            building.latitude = Double(lat)
            
            DatabaseConnection.upsert(building: building) { (error: NSError?, DBReturnedItem: [AnyHashable: Any]? ) in
                if error == nil {
                    
                    if let bldId = DBReturnedItem!["id"] as? String {
                        room.longitude = building.longitude
                        room.latitude = building.latitude
                        room.buildingId = bldId
                        self.addRoomToBackend(room: room)
                        return
                    }
                    else {
                        // error getting building id
                            // show user error and return to main view
                        LoadOverlay.endOverlay()
                        let alert = UIAlertController(title: "RM", message: "There was an error in the connection. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
                            self.navigationController?.popViewController(animated: true)
                        })
                        
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                    }
                    
                }
                else {
                    LoadOverlay.endOverlay()
                    print(error?.localizedDescription as Any)
                    DispatchQueue.main.async(execute: { () -> Void in
                        AppDelegate.getAppDelegate().showMessage(self, message:"There was a network error. \nPlease try again.")
                    })
                    
                }
                
            }
            
        }
    
    }
    
    private func addRoomToBackend(room: Room) {
        
        let formValues = form.values()
        let _floorNum = formValues[floorNum] as? String
        let _roomNum = formValues[roomNum] as? String
        
        if _floorNum == nil || _roomNum == nil { // || iconSelected == nil {
            LoadOverlay.endOverlay()
            
            DispatchQueue.main.async(execute: { () -> Void in
                AppDelegate.getAppDelegate().showMessage(self, message:"Please fully complete Room info.")
            })
            
            return
        }
        
        room.floor = _floorNum!
        room.roomNum = _roomNum!
//        room.iconId = iconSelected!
        room.iconId = DefaultValues.defaultRoomIconId   // Using default room icon
        
        // FIXME: If room already exist, then give user the option to edit the that room's times
        DatabaseConnection.upsert(room: room) { (error: NSError?, DBReturnedItem: [AnyHashable: Any]? ) in
            
            if error == nil {
                
                if let roomId = DBReturnedItem!["id"] as? String {
                    // open add hours
                    LoadOverlay.endOverlay()
                    self.addAvailability(roomId)
                }
                else {
                    
                    LoadOverlay.endOverlay()
                    
                    // alert saying that room was added, and to add times later
                    let alert = UIAlertController(title: "RM", message: "Room was added, but due to a network error please add Availability at another time.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
                        DispatchQueue.main.async(execute: {
                            LoadOverlay.endOverlay()
                            self.dismiss(animated: true, completion: nil)
                        })
                    })
                    
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
                
            }
            else {
                
                LoadOverlay.endOverlay()
                
                print(error?.localizedDescription as Any)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    AppDelegate.getAppDelegate().showMessage(self, message:"There was a network error. \nPlease try again.")
                })
            }
        }

    }
    
    // MARK: - AddTimesDelegate methods
    func saveTimesForRoom(_ sender: AddTimeController) {
        
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
        
        // ask User to open Settings to enable location service
        Map.openIphoneSettingsToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    // MARK: - Form
    
    func loadForm() {
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form
            +++ Section("Room Imformation:")
            
            <<< NameRow(floorNum) { $0.title = "Floor Number"
                $0.placeholder = "2"
                $0.evaluateDisabled()
            }
            
            <<< NameRow(roomNum) { $0.title = "Room Number"
                $0.placeholder = "401 or 370A.1"
                $0.evaluateDisabled()
            }
            
//            <<< ButtonRow() {
//                $0.title = "Select Room Icon"
//                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { self.iconSelector }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
//            }
            
            // Segmented Sections:

            +++ Section("Building:")
            <<< SegmentedRow<String>("segments"){
                $0.options = [nearbyBlOptionStr, addBldOptionStr]
                $0.value = nearbyBlOptionStr
            }
            
            <<< PickerRow<String>(bldPicker) { (row : PickerRow<String>) -> Void in
                row.options = Array(self.nearbyBldDict.keys)
                row.hidden = "$segments != 'Nearby Building'"
                row.value = Array(self.nearbyBldDict.keys).first
            }.cellSetup({ (cell, row) in
                cell.height = ({return (AppSize.screenHeight * 0.2)})
            })
            
            <<< SwitchRow(rmLocBool) {
                $0.hidden = "$segments != 'Nearby Building'"
                $0.title = "Set Room's Location To My Location"
                $0.value = true
            }
            
            <<< NameRow(buildingAcronym) {
                $0.title = "Building acronym"
                $0.hidden = "$segments != 'Add Building'"
                $0.placeholder = "PCL"
                $0.evaluateDisabled()
                }.cellSetup({ (cell, row) in
                    cell.textField.autocapitalizationType = .allCharacters
                })
            
            <<< NameRow(buildingName) { $0.title = "Building Full Name"
                $0.hidden = "$segments != 'Add Building'"
                $0.placeholder = "Perry-Castañeda Library"
                $0.evaluateDisabled()
            }
            
            <<< ButtonRow() {
                $0.hidden = "$segments != 'Add Building'"
                $0.title = "Drop Pin on Building's Location"
                mapVC.markerText = "Drag and Drop me to your building"
                mapVC.navigationItem.title = "Hold & Drag to Building Location"
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { self.mapVC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
            }
            
            +++ Section()
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Save Room and Add Availability"
                }  .onCellSelection({ (cell, row) in
                    self.saveRoomButton()
                })
    }
    
}
