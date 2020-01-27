//
//  AddOneRoomController.swift
//  RM
//
//  Created by Luis Fernandez on 7/13/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import MapKit

class OLD____AddOneRoomController: FormViewController, AddTimesDelegate, UITextViewDelegate {
    
    let room = Room()
    
    var VC = UIViewController()
    var addHoursController = AddTimeController()    // Use to add hours
    
    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    var displayBuildingName = [String]()
    var displayBuildingName_toId = Dictionary<String, String>()
    
    // Form Keys
    let buildingId = RoomKeys.buildingId  // from Rooms model
    let floorNum = RoomKeys.floor     // from Rooms model
    let roomNum = RoomKeys.roomNum     // from Rooms model
    let buildingIcon = "bI"
    let saveToFavorites = "SP"
    
    // Form icon picker
    fileprivate let iconSelector = BuildingIconsSelector()
    fileprivate var iconSelected: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addHoursController.delegate = self
        
        navigationItem.title = "Add A Room"
        
        LoadOverlay.showOverlay(forView: view)
        getBuildingName()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if iconSelector.bldSelected != nil {
            iconSelected = iconSelector.bldSelected!
        }
    }

    @objc fileprivate func cancelNavBarAction() {
        performSegue(withIdentifier: "UnwindToHomeController", sender: self)
    }
    
//    private func setEmptyDayAndTimes() {
//        let tempTime = AvailableTimes()
//        room.dayTimesAvailable[.Sunday] = tempTime
//        room.dayTimesAvailable[.Monday] = tempTime
//        room.dayTimesAvailable[.Tuesday] = tempTime
//        room.dayTimesAvailable[.Wednesday] = tempTime
//        room.dayTimesAvailable[.Thursday] = tempTime
//        room.dayTimesAvailable[.Friday] = tempTime
//        room.dayTimesAvailable[.Saturday] = tempTime
//    }
    
    // MARK: - Form Actions and setup
    
    func getBuildingName() {
//        DatabaseConnection.getBuildingsForDisplay { (buildingDisplayName, dictOfDisplayName_toId) in
//            if buildingDisplayName != nil && dictOfDisplayName_toId != nil {
//                self.displayBuildingName = (Array(Set(buildingDisplayName! as [String])) as [String]).sorted()    // alpha. sort
//                self.displayBuildingName_toId = dictOfDisplayName_toId! as Dictionary<String, String>
//                self.loadForm()
//                LoadOverlay.endOverlay()
//            }
//        }
    }

    func addBuilding() {
        VC.navigationController?.pushViewController(AddBuildingController(), animated: true)
    }
    
    fileprivate func addAvailability(_ roomId: String) {
        addHoursController.roomTime.roomId = roomId
        
        navigationController?.pushViewController(addHoursController, animated: true)
    }
    
    // AddTimesDelegate method
    func saveTimesForRoom(_ sender: AddTimeController) {
        
    }
    
    func saveRoom() {
        
        // turn on overlay for view
        LoadOverlay.showOverlay(forView: self.view)
        
        let formValues = form.values()
        
//        var _saveToFavorites: Bool = false
//        
//        if let savFav = formValues[saveToFavorites] as? Bool {
//            _saveToFavorites = savFav
//        }
        
        let _buildingId = formValues[buildingId] as? String
        let _floorNum = formValues[floorNum] as? String
        let _roomNum = formValues[roomNum] as? String
        
        if _buildingId == nil || _floorNum == nil || _roomNum == nil || iconSelected == nil {
            LoadOverlay.endOverlay()
            
            DispatchQueue.main.async(execute: { () -> Void in
                AppDelegate.getAppDelegate().showMessage(self, message:"Please fully complete form.")
            })
            
            return
        }
        
        let building = Building()
        building.id = displayBuildingName_toId[_buildingId!]!
        let room = Room()
        room.floor = _floorNum!
        room.roomNum = _roomNum!
        room.iconId = iconSelected!
        room.building = building
        room.buildingId = building.id
        
        // FIXME: If room already exist, then give user the option to edit the that room's times
        DatabaseConnection.upsert(room: room) { (error: NSError?, DBReturnedItem: [AnyHashable: Any]? ) in

            if error == nil {
                
                if let roomId = DBReturnedItem!["id"] as? String {
                    
                    // save to favorites if needed
                    // open add hours
                    
//                    if _saveToFavorites {
//                        DatabaseConnection.upsertToFavorite(roomID: roomId)
//                    }
                    
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

    // MARK: - Form
    
    func loadForm() {
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form
        
        +++ Section("i.e.: PCL 2.401 or PCL 2.370A.1 would be:")
            
//            <<< SwitchRow(saveToFavorites) {
//                $0.title = "Save to My Favorites"
//                $0.value = false
//            }
            
            <<< PushRow<String>(buildingId) {
                $0.title = "Select Building"
                $0.options = displayBuildingName
//                $0.value = bld
                $0.selectorTitle = "Select Building"
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
            
            <<< NameRow(floorNum) { $0.title = "Floor Number"
                $0.placeholder = "2"
                $0.evaluateDisabled()
            }
            
            <<< NameRow(roomNum) { $0.title = "Room Number"
                $0.placeholder = "401 or 370A.1"
                $0.evaluateDisabled()
            }
            
            <<< ButtonRow() {
                $0.title = "Select Room Icon"
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { self.iconSelector }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
            }
            
            +++ Section()
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Save Room and Add Availability"
                }  .onCellSelection({ (cell, row) in
                    self.saveRoom()
                })
        
//        +++ Section()
//            
//            +++ Section() {
//                var header = HeaderFooterView<UIButton>(.Class)
//                header.onSetupView = { (view: UIButton, section: Section) -> () in
//                    view.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), forState: .Normal)
//                    view.setTitle("Save Room", forState: UIControlState.Normal)
//                    view.addTarget(self, action: (#selector(self.saveRoom)), forControlEvents: UIControlEvents.TouchUpInside)
//                }
//                
//                $0.header = header
//            }
        
    }
    
}

