//
//  EditEventController.swift
//  RM
//
//  Created by Luis Fernandez on 8/1/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation
import Eureka
import MapKit
import GoogleMaps

class EditEventController: BaseFormVC, MapVCDelegate{
    
    // MARK: - Variables
    
    var event = Event()
    var eventAnyData = [AnyHashable: Any]()
    
    // Used to wait on completion of multiple async methods
    fileprivate let dispatch_group: DispatchGroup = DispatchGroup()
    
    // Google maps SDK, for selecting location UI
    fileprivate let mapVC = MapVC()
    
    // Google maps view for embedded maps view
    fileprivate let mapEmbeddedView = MapView(frame: CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: AppSize.screenHeight * 0.35))
    
    // Each must be set independently, as to not send redundant data to backend
    fileprivate var shouldUpdateTitle: Any?
    fileprivate var shouldUpdateDescription: Any?
    fileprivate var shouldUpdateDate: Any?
    fileprivate var shouldUpdateMainPicture: Any?
    
    // Navigation bar item
    fileprivate var barTopDoneItem: UIBarButtonItem!
    
    // Form
    fileprivate let PlaceHolderColor_1 = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.7)   // placeholder color
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapVC.delegate = self
        
        navigationItem.title = "Event"
        
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        
        setUpViewForm() // async proccess, will loadForm() after data is aquired
        setUpNavBar()
        
        // Check if user has location enabled, if not, ask User to enable loaction
        Map.checkToEnableLocation(controller: self, dismissController: true, isAsync: true)
        
    }
    
    // MARK: - View Controller Set Up
    
    fileprivate func setUpNavBar() {
        // Done nav bar button
        barTopDoneItem = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(self.navDoneAction))
        navigationItem.rightBarButtonItem = barTopDoneItem
        
        // Save Changes nav bar button
        let navfeedbackButton = UIBarButtonItem(title: "Save Changes", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveChanges))
        navigationItem.leftBarButtonItem = navfeedbackButton
        let attributes = [ NSForegroundColorAttributeName : UIColor.red]
        navfeedbackButton.setTitleTextAttributes(attributes, for: UIControlState())
    }
    
    fileprivate func setUpViewForm() {
        
        LoadOverlay.showOverlay(forView: view)
        
        if event.id == nil {
            
            print("Event Id was not found")
            
            LoadOverlay.endOverlay()
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        DatabaseConnection.getEvent(withId: event.id!) { (_event: Event?, eventRawData: [AnyHashable : Any]) in
            if _event != nil {
                self.event = _event!
                self.eventAnyData = eventRawData
                LoadOverlay.endOverlay()
                self.loadForm()
            }
            else {
                // error message, nil was returned from API call
                let alert = UIAlertController(title: "RM", message: "Connection error occurred. Please try again.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                })
                
                DispatchQueue.main.async(execute: {
                    LoadOverlay.endOverlay()
                    self.present(alert, animated: true, completion: nil)
                })
                
            }
            
        }
        
    }
    
    // MARK: - Navigation
    
    func saveChanges() {
        
        LoadOverlay.showOverlay(forView: self.view)
        
        // Parsing values, saving them to local objects as well (incase User wants to stay on page)
        
        var updateValues = [String: String]()
        
//        updateValues["id"] = event.id!     // Must include ID
        
        let formValues = form.values()

        if
            shouldUpdateTitle != nil,
            let newTitle = formValues[EventKeys.name] as? String
        {
            updateValues[EventKeys.name] = newTitle
            event.name = newTitle
        }
        
        if
            shouldUpdateDescription != nil,
            let newDesc = formValues[EventKeys.description] as? String
        {
            updateValues[EventKeys.description] = newDesc
            event.description = newDesc
        }
        
        if
            shouldUpdateDate != nil,
            let newDate = formValues[EventKeys.date] as? Date
        {
            updateValues[EventKeys.date] = String(newDate.timeIntervalSince1970)
            event.date = newDate
        }
        
        if
            mapVC.didChangeLocation,
            event.latitude != nil,
            event.longitude != nil
        {
            updateValues[EventKeys.latitude] = String(event.latitude!)
            updateValues[EventKeys.longitude] = String(event.longitude!)
        }
        
        // Updating in database
        
        DatabaseConnection.update(newItems: updateValues, oldEventAnyData: eventAnyData, forEntity: Entities.Event) { (error: Error?) in
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            if error == nil {
                // no error updating values
                alert.title = "RM"
                alert.message = "Event Update Successfully"
                alert.addAction(UIAlertAction(title: "See Changes", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Exit", style: .default) { (action) in
                    self.navDoneAction()
                })
            }
            else {
                // deal with error
                alert.title = "RM"
                alert.message = "Event Failed To Update, Try Again Please"
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            }
            
            DispatchQueue.main.async(execute: {
                LoadOverlay.endOverlay()
                self.present(alert, animated: true, completion: nil)
            })
            
        }
        
    }
    
    func navDoneAction() {
        self.performSegue(withIdentifier: "UnwindToHomeController", sender: self)
    }
    
    // MARK: - Form button functions
    
    fileprivate func editLocation() {
        
        if event.latitude != nil && event.longitude != nil {
            mapVC.setMarker(latitude: event.latitude!, longitude: event.longitude!)
        }
        
        mapVC.markerText = "Hold, Drag and Drop Me"
        mapVC.navigationItem.title = "Hold & Drag to Building Location"
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    fileprivate func delteEvent() {
        
        LoadOverlay.showOverlay(forView: self.view)
        
        DatabaseConnection.deleteItem(withId: event.id!, entity: Entities.Event) { (isSuccessful) in
            if isSuccessful {
                
            }
            else {
                
            }
            LoadOverlay.endOverlay()
            self.navDoneAction()
        }
        
    }
    
    // Moving to Icon selection view
    func mainImageWasTapped(_ gesture: UIGestureRecognizer) {
        
        let imageActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        imageActionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { (action) in
        
        })
        imageActionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { (action) in
        
        })
        
        imageActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(imageActionSheet, animated: true, completion: nil)
        
    }
    
    // MARK: - MapVC Delegate Methods
    
    func didFinishSelectingLocation(_ sender: MapVC) {
        // Getting the cordinates where the user left the marker at
        // Add cordinates to event only if event location was given
        if
            let lat = sender.latitude,
            let long = sender.longitude,
            mapVC.didChangeLocation
        {
            event.latitude = lat
            event.longitude = long
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
            
            +++ Section(footer: "Tap to edit Title, Description, or Date.") {
                var header = HeaderFooterView<MainImage>(.class)
                header.onSetupView = { (view: MainImage, section: Section) -> () in
                    if self.event.uiImage == nil {
                        view.mainPic.image = UIImage(named: "defaultRoomIconId")
                    }
                }
                $0.header = header
            }
            
//            // Icon Selection
//            +++ Section("Tap Image to View or Edit:")
//            +++ Section("Tap Image to View or Edit:") {
//                
//                var header = HeaderFooterView<MainImage>(.class)
//                header.onSetupView = { (view: MainImage, section: Section) -> () in
//                    
//                    if self.event.uiImage != nil {
//                        view.mainPic.image = self.event.uiImage
//                    }
//                    
//                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mainImageWasTapped(_:)))
//                    view.mainPic.addGestureRecognizer(tapGesture)
//                    view.mainPic.isUserInteractionEnabled = true
//                    
//                }
//                
//                $0.header = header
//                
//            }
//            
//            +++ Section("Tap to Edit:")
            
            // Event Title
            <<< TextRow(EventKeys.name) {
                $0.title = "Title"
                if let name = event.name as String? {
                    $0.value = name
                }
                $0.evaluateDisabled()
                $0.placeholderColor = PlaceHolderColor_1
                $0.onChange({ (text) in
                    self.shouldUpdateTitle = text.value  // not nil when value has been changed
                })
            }
            
            // Description
            <<< TextAreaRow(EventKeys.description) {
                if
                    let desc = event.description as String?,
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
            
            // Date and time picker
            <<< DateTimeRow(EventKeys.date) {
                if let date = event.date {
                    $0.value = date
                }
                $0.title = "Date and Time"
                $0.onChange({ (dateTimeRow) in
                    self.shouldUpdateDate = dateTimeRow.value
                })
            }
        
            // Location Map
            +++ Section("Event Location") {
                
                var header = HeaderFooterView<UIView>(.class)
                header.onSetupView = { (view: UIView, section: Section) -> () in
                    
                    view.frame = self.mapEmbeddedView.frame
                    view.addSubview(self.mapEmbeddedView)
                    
                    // if event location exists, use that location
                    if self.event.latitude != nil && self.event.longitude != nil {
                        self.mapEmbeddedView.setMarker(latitude: self.event.latitude!, longitude: self.event.longitude!)
                    }
                    
                }
                
                $0.header = header
            }
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Edit Event Location"
                }.onCellSelection({ (cell, row) in
                    self.editLocation()
                })
            
            +++ Section("This will permanently delete all information about this Event")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Delete Event"
                }.cellUpdate { cell, row in
                    cell.textLabel!.textColor = UIColor.red
                }.onCellSelection({ (cell, row) in
                    self.delteEvent()
                })
        
    }
    
}

