//
//  EditRoomController.swift
//  RM
//
//  Created by Luis Fernandez on 4/2/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import MapKit
import GoogleMaps

class EditRoomController: BaseFormVC, MapVCDelegate, AddTimesDelegate{
    
    // MARK: - Variables
    
    var ROOMID = String()
    
    // Used to wait on completion of multiple async methods
    fileprivate let dispatch_group: DispatchGroup = DispatchGroup()
    
    // Main data objects
    fileprivate var room = Room()
    fileprivate var building = Building()
    fileprivate var avTimes = [WeekDay: AvailableTimes]()
    
    // Google maps SDK, for selecting location UI
    fileprivate let mapVC = MapVC()
    
    // Google maps view for embedded maps view
    fileprivate let mapEmbeddedView = MapView(frame: CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: AppSize.screenHeight * 0.35))
    
    // Use to add hours
    var addTimeController = AddTimeController()
    
    // Used to edit bulding
    var VC = UIViewController()
    var displayBuildingName = [String]()
    var displayBuildingName_toId = Dictionary<String, String>()
    
    // Each must be set independently, as to not send redundant data to backend
    fileprivate var shouldUpdateFavorite: Any?
    fileprivate var shouldupdateFloor: Any?
    fileprivate var shouldUpdateRoomNum: Any?
    fileprivate var shouldUpdateBuildingId: Any?
    fileprivate var shouldUpdateDescription: Any?
    // iconsId and location are checked if they must be updated via their delegate methods
    
    // Navigation bar item
    fileprivate var barTopDoneItem: UIBarButtonItem!
    
    // Form
    fileprivate let iconSelector = BuildingIconsSelector()  // icon picker
    fileprivate let PlaceHolderColor_1 = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.7)   // placeholder color

    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBuildingName()
        
        mapVC.delegate = self
        
        addTimeController.delegate = self
        
        navigationItem.title = "Room"
        
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        
        setUpViewForm()
        setUpNavBar()
        
        // Check if user has location enabled, if not, ask User to enable loaction
        Map.checkToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let imgStr = iconSelector.bldSelected {
            room.iconId = imgStr
            tableView?.reloadData()
        }
    }
    
    // MARK: - View Controller Set Up
    
    fileprivate func setUpNavBar() {
        // Done nav bar button
        barTopDoneItem = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(self.navDoneAction))
        navigationItem.rightBarButtonItem = barTopDoneItem
        setUpSaveChangesBttn()
    }
    
    fileprivate func setUpSaveChangesBttn() {
        // Help nav bar button
        let navfeedbackButton = UIBarButtonItem(title: "Save Changes", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveChanges))
        navigationItem.leftBarButtonItem = navfeedbackButton
        let attributes = [ NSForegroundColorAttributeName : UIColor.red]
        navfeedbackButton.setTitleTextAttributes(attributes, for: UIControlState())
    }
    
    fileprivate func setUpViewForm() {
        
        var nilWasReturned = false
        
        LoadOverlay.showOverlay(forView: view)
        
        dispatch_group.enter()
        
        DatabaseConnection.getRoom(withId: ROOMID) { (room) in
            
            if room != nil {
                
                // Storing in private global variable, to be used later if needed if updated
                self.room = room!
                // This API has to nested because building id comes from room object
                DatabaseConnection.getBuilding(withId: self.room.building.id, completion: { (building) in
                    if building != nil {
                        self.building = building!
                        
                        // FIXME: get lat and long and get address and show "See and/or Edit Location"
                        
                        self.dispatch_group.leave()
                        
                    }
                    else { nilWasReturned = true}
                })
                
            }
            else { nilWasReturned = true }
            
        }
        
        dispatch_group.notify(queue: DispatchQueue.main) {
            if !nilWasReturned {
                self.loadForm()
                self.tableView?.reloadData()
                LoadOverlay.endOverlay()
            }
            else {
                // error message, nil was returned from API call
            }
        }
        
    }
    
    func getBuildingName() {
        let (userLat, userLong) = Map.getLocation()
        
        if userLat == nil || userLong == nil {
            print("Failed to get location.")
        }
        else {
            DatabaseConnection.getBuildingsForDisplay(latitude: userLat!, longitude: userLong!) { (buildingDisplayName, dictOfDisplayName_toId) in
                if buildingDisplayName != nil && dictOfDisplayName_toId != nil {
                    self.displayBuildingName = (Array(Set(buildingDisplayName! as [String])) as [String]).sorted()    // alpha. sort
                    self.displayBuildingName_toId = dictOfDisplayName_toId! as Dictionary<String, String>
                }
            }
        }
        
    }
    
    // MARK: - Navigation
    
    func saveChanges() {
        
        LoadOverlay.showOverlay(forView: self.view)
        
        // Parsing values, saving them to local objects as well (incase User wants to stay on page)
        
        var updateValues = [String: String]()
        
        updateValues["id"] = ROOMID     // Must include ID
        
        let formValues = form.values()
        
        //        if (shouldUpdateFavorite != nil) {
        //            var _saveToFavorites: Bool = false
        //
        //            if let savFav = formValues[RoomKeys.isFavorite] as? Bool {
        //                _saveToFavorites = savFav
        //            }
        //        }
        
        if
            shouldupdateFloor != nil,
            let _floorNum = formValues[RoomKeys.floor] as? String
        {
            updateValues[RoomKeys.floor] = _floorNum
            room.floor = _floorNum
        }
        
        if
            shouldUpdateRoomNum != nil,
            let _roomNum = formValues[RoomKeys.roomNum] as? String
        {
            updateValues[RoomKeys.roomNum] = _roomNum
            room.roomNum = _roomNum
        }
        
        if
            shouldUpdateBuildingId != nil,
            let bld = formValues[RoomKeys.buildingId] as? String,
            let _buildingId = displayBuildingName_toId[bld]
        {
            updateValues[RoomKeys.buildingId] = _buildingId
            room.buildingId = _buildingId
        }
        
        if
            shouldUpdateDescription != nil,
            let _ = formValues[RoomKeys.rmDescription] as? String
        {
            //
        }
        
        if
            mapVC.didChangeLocation,
            room.latitude != nil,
            room.longitude != nil
        {
            updateValues[RoomKeys.latitude] = String(room.latitude!)
            updateValues[RoomKeys.longitude] = String(room.longitude!)
        }
        
        if
            iconSelector.didSelectIcon,
            iconSelector.bldSelected != nil
        {
            updateValues[RoomKeys.iconId] = iconSelector.bldSelected!
        }
        
        // Updating in database
        
        DatabaseConnection.update(item: updateValues, forEntity: Entities.room) { (error: Error?) in
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            if error == nil {
                // no error updating values
                alert.title = "RM"
                alert.message = "Room Update Successfully"
                alert.addAction(UIAlertAction(title: "See Changes", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Exit", style: .default) { (action) in
                    self.navDoneAction()
                })
            }
            else {
                // deal with error
                alert.title = "RM"
                alert.message = "Room Failed To Update, Try Again Please"
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            }
            
            DispatchQueue.main.async(execute: {
                LoadOverlay.endOverlay()
                self.present(alert, animated: true, completion: nil)
            })
            
        }
        
    }
    
    func navDoneAction() {
        self.exitToHomeView()
    }
    
    func exitToHomeView() {
        self.performSegue(withIdentifier: "UnwindToHomeController", sender: self)
    }
    
    // MARK: - Form button functions
    
    fileprivate func editAvailability() {
//        addTimeController.shouldLoadTimes = true
        addTimeController = AddTimeController(loadBackEndTimes: true, withRoomId: ROOMID)
//        addTimeController.roomTime.roomId =
        navigationController?.pushViewController(addTimeController, animated: true)
    }
    
    fileprivate func editLocation() {
        /*
        
         */
        if room.latitude == nil || room.longitude == nil {
//            mapVC.latitude = building.latitude
//            mapVC.longitude = building.longitude
            mapVC.setMarker(latitude: building.latitude, longitude: building.longitude)
        }
        else {
//            mapVC.latitude = room.latitude
//            mapVC.longitude = room.longitude
            mapVC.setMarker(latitude: room.latitude!, longitude: room.longitude!)
        }
        
        mapVC.markerText = "Hold, Drag and Drop Me"
        mapVC.navigationItem.title = "Hold & Drag to Building Location"
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    fileprivate func deleteRoom() {
        
        LoadOverlay.showOverlay(forView: self.view)
        
        let asyncGroup : DispatchGroup = DispatchGroup()
        
        var listOfTimesId = [String]()
        
        var didDeleteRoom: Bool = false
        
        asyncGroup.enter()
        
        // Get available times that belong to room
    
        DatabaseConnection.getAvailabeTimes(withRoomId: ROOMID) { (avTimes :[WeekDay : AvailableTimes]?, listOfId: [String]?) in
            print("inside get times")
            if listOfId != nil {
                print("did get times")
                listOfTimesId = listOfId!
            }
            else {
                // Could not get list of times
            }
            asyncGroup.leave()
        }
        
        // Delte available times that belong to room
        
        for timeId in listOfTimesId {
            
            asyncGroup.enter()
            
            DatabaseConnection.deleteItem(withId: timeId, entity: Entities.roomTime, completion: { (isSuccessful) in
                print("inside delete time")
                if isSuccessful {
                    // did delete time
                    print("did delete time")
                }
                
                asyncGroup.leave()
                
            })
        }
        
        asyncGroup.enter()
        
        // Delete room
        
        DatabaseConnection.deleteItem(withId: ROOMID, entity: Entities.room) { (isSuccessful) in
            print("inside delete room")
            if isSuccessful {
                print("did delete room")
                // did delete room, segue back to home view
                didDeleteRoom = true
                asyncGroup.leave()
            }
        }
        
        asyncGroup.notify(queue: DispatchQueue.main) {
            print("inside async notify")
            
            LoadOverlay.endOverlay()
            
            if didDeleteRoom {
                // successfuly deleted room
                print("inside async notify _ did delete room")
                self.exitToHomeView()
            }
            else {
                print("inside async notify _ failed to delete room")
                // failed to delete room
                let failedToDeleteRoomAlert = UIAlertController(title: "RM", message: "Room deletion failed, please try again.", preferredStyle: .alert)
                
                failedToDeleteRoomAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                DispatchQueue.main.async(execute: {
                    LoadOverlay.endOverlay()
                    self.present(failedToDeleteRoomAlert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func testButton() {
        // debug stuff //
        
        // THIS WORKS
        let weekDays = [WeekDay.sunday, WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]
        // //
        for day in weekDays {
            
            print(avTimes[day]?.dayChar)
            print(avTimes[day]?.dayOfWeek)
            if let times = avTimes[day]?.rawTimes {
                for timeSet in times {
                    print(timeSet)
                }
            }
            
        }
        
    }
    
    // Moving to Icon selection view
//    func showIconSelection(_ gesture: UIGestureRecognizer) {
//        self.navigationController?.pushViewController(self.iconSelector, animated: true)
//    }
    
    func addBuilding() {
        VC.navigationController?.pushViewController(AddBuildingController(), animated: true)
    }
    
    func buildingChangeInUI() {
        /*
         This method is called when the User has selected a new Building.
         For continuity purposes, when new Building is selescted, the MapView will update to show the location of the new building as the location of the room.
         Since new building is selected, we will set: room.lat = nil and room.long = nil.
         If user wants to give the room a relative location inside the building, room.lat and .long will be set to that.
         */
        
        let formValues = form.values()
        
        if
            shouldUpdateBuildingId != nil,
            let bld = formValues[RoomKeys.buildingId] as? String,
            let _buildingId = displayBuildingName_toId[bld]
        {
            
            DatabaseConnection.getBuildingLOcation(withId: _buildingId, completion: { (latitude: Double?, longitude: Double?) in
                
                if latitude != nil && longitude != nil {
                    
                    self.room.latitude = nil
                    self.room.longitude = nil
                    self.building.latitude = latitude!
                    self.building.longitude = longitude!
                    self.mapEmbeddedView.setMarker(latitude: latitude!, longitude: longitude!)
                }
                
                else {
                    print("failed to get new location values")
                }
                
            })
            
        }
        
    }
    
    // MARK: - AddTimes Delegate method
    
    func saveTimesForRoom(_ sender: AddTimeController) {
    }
    
    // MARK: - MapVC Delegate Methods
    
    func didFinishSelectingLocation(_ sender: MapVC) {
        // Getting the cordinates where the user left the marker at
        // Add cordinates to room only if room location was given
        if
            let lat = sender.latitude,
            let long = sender.longitude,
            mapVC.didChangeLocation
        {
            room.latitude = lat
            room.longitude = long
            self.mapEmbeddedView.setMarker(latitude: lat, longitude: long)
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
            
            +++ Section() {
                var header = HeaderFooterView<MainImage>(.class)
                header.onSetupView = { (view: MainImage, section: Section) -> () in
                    if !self.room.iconId.isEmpty {
                        view.mainPic.image = UIImage(named: self.room.iconId)
                    }
                }
                $0.header = header
            }

            
            // Icon Selection
//            +++ Section("Tap Image to Edit:")
//            +++ Section("Tap Image to Edit:") {
//                
//                var header = HeaderFooterView<MainImage>(.class)
//                header.onSetupView = { (view: MainImage, section: Section) -> () in
//                    
//                    if !self.room.iconId.isEmpty {
//                        view.mainPic.image = UIImage(named: self.room.iconId)
//                    }
//                    
//                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showIconSelection(_:)))
//                    view.mainPic.addGestureRecognizer(tapGesture)
//                    view.mainPic.isUserInteractionEnabled = true
//                    
//                }
//                
//                $0.header = header
//                
//            }
            
            +++ Section("Tap to Edit:")
            
//            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "TEST" }  .onCellSelection({ (cell, row) in self.testButton() })
            
//            <<< SwitchRow(RoomKeys.isFavorite) {
//                $0.title = "Save to My Favorites"
//                $0.value = false
//                $0.onChange({ (text) in
//                    self.shouldUpdateFavorite = text.value
//                })
//            }
            
            <<< TextRow(RoomKeys.floor) {
                $0.title = "Floor"
                if let flr = room.floor as String? {
                    $0.placeholder = flr
                }
                $0.evaluateDisabled()
                $0.placeholderColor = PlaceHolderColor_1
                $0.onChange({ (text) in
                    self.shouldupdateFloor = text.value  // not nil when value has been changed
                })
            }
            
            <<< TextRow(RoomKeys.roomNum) {
                $0.title = "Room"
                if let rmNum = room.roomNum as String? {
                    $0.placeholder = rmNum
                }
                $0.evaluateDisabled()
                $0.placeholderColor = PlaceHolderColor_1
                $0.onChange({ (text) in
                    self.shouldUpdateRoomNum = text.value
                })
            }
            
            <<< PushRow<String>(RoomKeys.buildingId) {
                $0.title = "Building"
                $0.options = displayBuildingName
                if !building.name.isEmpty && !building.acronym.isEmpty
                {
                    $0.value = building.acronym + " " + building.name
                    $0.noValueDisplayText = building.acronym + " " + building.name
                }
                $0.selectorTitle = "Select Building"
                $0.onChange({ (changeValueTo) in
                    self.shouldUpdateBuildingId = changeValueTo.value
                    self.buildingChangeInUI()
                })
                }.onPresent({ (_, presentingVC) -> () in
                    self.VC = presentingVC
                    let topInset = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height
                    
                    presentingVC.view.layoutSubviews()
                    presentingVC.navigationController?.navigationBar.topItem?.title = ""
                    
                    var bttnFrame = self.view.frame
                    bttnFrame.origin.y = topInset
                    bttnFrame.size.height = 50
                    
                    let bttn = UIButton(frame: bttnFrame)
                    bttn.setTitle("Can't find your building? Add it.", for: [])
                    bttn.addTarget(self, action: (#selector(self.addBuilding)), for: .touchUpInside)
                    bttn.backgroundColor = .red
                    
                    presentingVC.view.addSubview(bttn)
                    
            })
            
            <<< TextAreaRow(RoomKeys.rmDescription) {
                if
                    let desc = room.rmDescription as String?,
                    !desc.isEmpty
                {
                    $0.value = desc
                }
                else {
                    $0.placeholder = "Description"
                }
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 60)
                $0.evaluateDisabled()
                $0.onChange({ (text) in
                    self.shouldUpdateDescription = text.value
                })
            }
            
            +++ Section("Room's Relative Location inside its building")
            +++ Section("Room's Relative Location inside its building") {
                
                var header = HeaderFooterView<UIView>(.class)
                header.onSetupView = { (view: UIView, section: Section) -> () in
                    
                    view.frame = self.mapEmbeddedView.frame
                        //CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: AppSize.screenHeight * 0.35)
                    
                    view.addSubview(self.mapEmbeddedView)
                    
                    // if room location exists, use that location
                    // else, use building location
                    if self.room.latitude != nil && self.room.longitude != nil {
                        self.mapEmbeddedView.setMarker(latitude: self.room.latitude!, longitude: self.room.longitude!)
                    }
                    else {
                        self.mapEmbeddedView.setMarker(latitude: self.building.latitude, longitude: self.building.longitude)
                    }
                    
                }
                
                $0.header = header
            }
            
//            +++ Section("Relative location of room is inside its building")
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Edit Room Location"
                }.onCellSelection({ (cell, row) in
                    self.editLocation()
                })
            
            +++ Section("Edit the times when this room is available to college students")
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Edit Availability"
                }.onCellSelection({ (cell, row) in
                    self.editAvailability()
            })
        
            +++ Section("This will permanently delete all information about this room")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Delete Room"
//                row.hidden = true
                }.cellUpdate { cell, row in
                    cell.textLabel!.textColor = UIColor.red
                }.onCellSelection({ (cell, row) in
                    self.deleteRoom()
            })
    }
}
