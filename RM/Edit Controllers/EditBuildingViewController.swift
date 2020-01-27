//
//  EditBuildingViewController.swift
//  RM
//
//  Created by Luis Fernandez on 6/12/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation
import Eureka
import GoogleMaps
import MapKit

class EditBuildingViewController: BaseFormVC, MapVCDelegate{
    
    var buldingId = String()
    
    // MARK: - Variables
    
    // Main data objects
    fileprivate var building = Building()
    
    // Google maps SDK, for selecting location UI
    fileprivate let mapVC = MapVC()
    
    // Google maps view for embedded maps view
    fileprivate let mapEmbeddedView = MapView(frame: CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: AppSize.screenHeight * 0.35))
    
    // Each must be set independently, as to not send redundant data to backend
    fileprivate var shouldUpdateBldAcronym: Any?
    fileprivate var shouldUpdateBldName: Any?
    
    // Navigation bar item
    fileprivate var barTopDoneItem: UIBarButtonItem!
    
    // Form
    fileprivate var _VC_WAS_LOADED: Bool = false
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map
        mapVC.delegate = self
        
        // General set up
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        
        setUpNavBar()
        
        // Check if user has location enabled, if not, ask User to enable loaction
        Map.checkToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpViewForm()
    }
    
    // MARK: - Navigation Set Up
    
    fileprivate func setUpNavBar() {
        
        // Navigation title
        
        navigationItem.title = "Building"
        
        // Help nav bar button
        
        let navfeedbackButton = UIBarButtonItem(title: "Save Changes", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveChanges))
        navigationItem.rightBarButtonItem = navfeedbackButton
        let attributes = [ NSForegroundColorAttributeName : UIColor.red]
        navfeedbackButton.setTitleTextAttributes(attributes, for: UIControlState())
        
    }
    
    
    fileprivate func setUpViewForm() {
        
        LoadOverlay.showOverlay(forView: view)
        
        DatabaseConnection.getBuilding(withId: buldingId) { (bld: Building?) in
            
            if bld != nil {
                // building was received successfully
                self.building = bld!
                
                if self._VC_WAS_LOADED {
                    self.tableView.reloadData()
                }
                else {
                    self.loadForm()
                }
                
            }
            else {
                // error getting building data
                let failedToLoadBldAlert = UIAlertController(title: "RM", message: "Failed to get Building info, please try again.", preferredStyle: .alert)
                
                failedToLoadBldAlert.addAction(UIAlertAction(title: "Exit", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                DispatchQueue.main.async(execute: {
                    LoadOverlay.endOverlay()
                    self.present(failedToLoadBldAlert, animated: true, completion: nil)
                })
            }
            
            LoadOverlay.endOverlay()
            
        }
        
    }
    
    // MARK: - Form Action Functions
    
    @objc fileprivate func saveChanges() {
        
        LoadOverlay.showOverlay(forView: self.view)
        
        // Parsing values, saving them to local objects as well (incase User wants to stay on page)
        
        var updateValues = [String: String]()
        
        updateValues["id"] = buldingId     // Must include ID
        
        let formValues = form.values()
        
        if
            shouldUpdateBldAcronym != nil,
            let _acronym = formValues[BuildingKeys.acronymName] as? String
        {
            updateValues[BuildingKeys.acronymName] = _acronym
            building.acronym = _acronym
        }
        
        if
            shouldUpdateBldName != nil,
            let _bldName = formValues[BuildingKeys.buildingName] as? String
        {
            updateValues[BuildingKeys.buildingName] = _bldName
            building.name = _bldName
        }
        
        if
            mapVC.didChangeLocation,
            building.latitude != nil,
            building.longitude != nil
        {
            updateValues[RoomKeys.latitude] = String(building.latitude)
            updateValues[RoomKeys.longitude] = String(building.longitude)
        }
        
        // Updating in database
        
        DatabaseConnection.update(item: updateValues, forEntity: Entities.building) { (error: Error?) in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            if error == nil {
                // no error updating values
                alert.title = "RM"
                alert.message = "Building Update Successfully"
                alert.addAction(UIAlertAction(title: "See Changes", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Exit", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
            else {
                // deal with error
                alert.title = "RM"
                alert.message = "Building Failed To Update, Try Again Please"
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            }
            
            DispatchQueue.main.async(execute: {
                LoadOverlay.endOverlay()
                self.present(alert, animated: true, completion: nil)
            })
        }
        
    }
    
    fileprivate func editLocation() {
        mapVC.setMarker(latitude: building.latitude, longitude: building.longitude)
        mapVC.markerText = "Hold, Drag and Drop Me"
        mapVC.navigationItem.title = "Hold & Drag to Building Location"
        navigationController?.pushViewController(mapVC, animated: true)
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
            building.latitude = lat
            building.longitude = long
            self.mapEmbeddedView.setMarker(latitude: lat, longitude: long)
        }
    }
    
    func errorGettingAuthorization(_ sender: MapVC) {
        
        // ask User to open Settings to enable location service
        Map.openIphoneSettingsToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    // MARK: - Form
    fileprivate func loadForm() {
        
        self._VC_WAS_LOADED = true
        
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form
            
            +++ Section("Tap to Edit Building's Info:")
            
            <<< TextRow(BuildingKeys.acronymName) {
                $0.title = "Acronym"
                $0.placeholder = building.acronym
                $0.evaluateDisabled()
                $0.placeholderColor = Style.PlaceHolderColor_1
                $0.onChange({ (text) in
                    self.shouldUpdateBldAcronym = text.value  // not nil when value has been changed
                })
            }
            
            <<< TextRow(RoomKeys.roomNum) {
                $0.title = "Name"
                $0.placeholder = building.name
                $0.evaluateDisabled()
                $0.placeholderColor = Style.PlaceHolderColor_1
                $0.onChange({ (text) in
                    self.shouldUpdateBldName = text.value
                })
            }
            
            +++ Section("Location of building")
            +++ Section("Location of building") {
                
                var header = HeaderFooterView<UIView>(.class)
                header.onSetupView = { (view: UIView, section: Section) -> () in
                    view.frame = self.mapEmbeddedView.frame
                        //CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: AppSize.screenHeight * 0.60)
                    self.mapEmbeddedView.setMarker(latitude: self.building.latitude, longitude: self.building.longitude)
                    view.addSubview(self.mapEmbeddedView)
                }
                
                $0.header = header
            }
        
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Edit Building Location"
                }.onCellSelection({ (cell, row) in
                    self.editLocation()
                })
    
        
    }
}
