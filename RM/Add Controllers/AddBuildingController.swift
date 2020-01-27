//
//  AddBuildingController.swift
//  RM
//
//  Created by Luis Fernandez on 7/17/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//


import Foundation
import UIKit
import Eureka
import GoogleMaps

class AddBuildingController: BaseFormVC, MapVCDelegate {
    
    // Google maps SDK
    let mapVC = MapVC()
    fileprivate var getLocationSuccess = false
    fileprivate var lat = CLLocationDegrees()
    fileprivate var long = CLLocationDegrees()
    
    // Form Keys and to construct dictionary to send to backend
    let buildingName = BuildingKeys.buildingName     // from Building model
    let buildingAcronym = BuildingKeys.acronymName   // from Building model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVC.delegate = self
        setUpNavBar()
        loadForm()
        
        // Check if user has location enabled, if not, ask User to enable loaction
        Map.checkToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    // MARK: - Navigation bar set-up
    
    func setUpNavBar(){
        navigationItem.title = "Add A Building"
    }
    
    // MARK: - Form Actions and setup

    func addNewBuiding() {
        // turn on overlay for view
        LoadOverlay.showOverlay(forView: view)
        
        let formValues = form.values()
        
        let _buildingName = formValues[buildingName] as? String
        let _buildingAcronym = formValues[buildingAcronym] as? String
        
        print("Lat and Long ready:")
        print(lat)
        print(long)
        
        // Ask to fully complete form
        if _buildingName == nil || _buildingAcronym == nil || getLocationSuccess == false {
            LoadOverlay.endOverlay()
            
            DispatchQueue.main.async(execute: { () -> Void in
                AppDelegate.getAppDelegate().showMessage(self, message:"Please fully complete form.")
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
                DispatchQueue.main.async(execute: {
                    LoadOverlay.endOverlay()

                    self.dismiss(animated: true, completion: nil)
                
                })
            }
            
            else {
                print(error?.localizedDescription as Any)
                DispatchQueue.main.async(execute: { () -> Void in
                    AppDelegate.getAppDelegate().showMessage(self, message:"There was a network error. \nPlease try again.")
                })
            }
            
        }
        
        
//        let buildingDict: Dictionary<String, String> = [buildingName: _buildingName!,
//                                                    buildingAcronym: _buildingAcronym!.uppercaseString
//                                                        ]
//        
//        DatabaseConnection.AddBuilding(forItems: buildingDict) { (isSuccesful) in
//            // turn off overlay
//            // return to home screen
//            if isSuccesful {
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    LoadOverlay.endOverlay()
//                    
//                    self.dismissViewControllerAnimated(true, completion: nil)
//                
//                })
//                
//            }
//        }
        
        LoadOverlay.endOverlay()
    }
    
    // MARK: MapVC Delegate Methods
    
    func didFinishSelectingLocation(_ sender: MapVC) {
        // Getting the cordinates where the user left the marker at
        getLocationSuccess = true
        if
            sender.latitude != nil,
            sender.longitude != nil
        {
            lat = sender.latitude!
            long = sender.longitude!
        }
    }
    
    func errorGettingAuthorization(_ sender: MapVC) {
        
        getLocationSuccess = false
        
        // ask User to open Settings to enable location service
        Map.openIphoneSettingsToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    // MARK: - Form
    
    func loadForm() {
        
        form =
            
        Section("I.E: PCL Perry-Castañeda Library")
        
//        Section(header: "I.E: PCL Perry-Castañeda Library", footer: "This information will be added to your personal account. To become public, it will need to be verify by a few other users.")
        
        <<< NameRow(buildingAcronym) { $0.title = "Building acronym"
            $0.placeholder = "PCL"
            $0.evaluateDisabled()
        }.cellSetup({ (cell, row) in
            cell.textField.autocapitalizationType = .allCharacters
        })
        
        <<< NameRow(buildingName) { $0.title = "Building Full Name"
            $0.placeholder = "Perry-Castañeda Library"
            $0.evaluateDisabled()
        }
        
        <<< ButtonRow() {
            $0.title = "Drop Pin on Building's Location"
            mapVC.markerText = "Drag and Drop me to your building"
            mapVC.navigationItem.title = "Hold & Drag to Building Location"
            $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { self.mapVC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
        }
            
        +++ Section()
            
        <<< ButtonRow() {
            $0.title = "Add New Building"
        }.onCellSelection({ (cell, row) in
            self.addNewBuiding()
        })
            
//        +++ Section() {
//            var header = HeaderFooterView<UIButton>(.Class)
//            header.onSetupView = { (view: UIButton, section: Section) -> () in
//                view.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), forState: .Normal)
//                view.setTitle("Add New Building", forState: UIControlState.Normal)
//                view.addTarget(self, action: (#selector(self.addNewBuiding)), forControlEvents: UIControlEvents.TouchUpInside)
//            }
//            
//            $0.header = header
//        }
        
    }
    
}



