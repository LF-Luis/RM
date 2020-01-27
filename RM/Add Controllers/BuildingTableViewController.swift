//
//  BuildingTableViewController.swift
//  RM
//
//  Created by Luis Fernandez on 6/12/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation

class BuildingTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Variables
    
    // variables for tableview
    private let tableView = UITableView()
    private let cellId = "cellId"
    
    // variables for data management
    private var displayBuildingName = [String]()
    private var displayBuildingName_toId = Dictionary<String, String>()
    
    // Refrech data control
    var refreshControl = UIRefreshControl()
    
    // controller to add a building
    fileprivate let addBuildingVC = AddBuildingController()
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Style.MainBackgroundColor
        navigationItem.title = "Buildings Near You"
        
        // table is also initiated here, upon successful data loading
        getTableData()
        
        // Refresh set up
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: (#selector(self.onRefresh)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: - Getting Table Data
    
    fileprivate func getTableData() {
        
        /*
         if succesful: load table
         else: don't load table, show error to user
             once error is dismissed, pop-back to previous controller
        */
        
        LoadOverlay.showOverlay(forView: self.view)
        
        // Loading data from backend tables
        // FIXME: - Method no longer being used, look at DatabaseConnection class for new method to get building data
//        DatabaseConnection.getBuildingsForDisplay { (buildingDisplayName, dictOfDisplayName_toId) in
//            
//            // Successful load
//            if buildingDisplayName != nil && dictOfDisplayName_toId != nil {
//                self.displayBuildingName = (Array(Set(buildingDisplayName! as [String])) as [String]).sorted()    // alpha. sort
//                self.displayBuildingName_toId = dictOfDisplayName_toId! as Dictionary<String, String>
//                
//                self.tableViewSetUp()   // Set up table view
//                
//                LoadOverlay.endOverlay()
//            }
//            else {
//                // failed to load data
//                let failLoadDataAlert = UIAlertController(title: "RM", message: "Failed to load Buildings, please try again.", preferredStyle: .alert)
//                
//                failLoadDataAlert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
//                    self.navigationController?.popViewController(animated: true)
//                })
//                
//                DispatchQueue.main.async(execute: {
//                    LoadOverlay.endOverlay()
//                    self.present(failLoadDataAlert, animated: true, completion: nil)
//                })
//                
//            }
//            
//        }
        
    }
    
    // MARK: - Refresh Data
    // If this method fails, old data is kept. User is not told if refreshing fails.
    func onRefresh() {

        // FIXME: - Method no longer being used, look at DatabaseConnection class for new method to get building data
//        DatabaseConnection.getBuildingsForDisplay { (buildingDisplayName, dictOfDisplayName_toId) in
//            // Successful load
//            if buildingDisplayName != nil && dictOfDisplayName_toId != nil {
//                self.displayBuildingName = (Array(Set(buildingDisplayName! as [String])) as [String]).sorted()    // alpha. sort
//                self.displayBuildingName_toId = dictOfDisplayName_toId! as Dictionary<String, String>
//                
//                self.tableView.reloadData()
//                self.refreshControl.endRefreshing()
//                
//            }
//        }
        
    }
    
    // MARK: - Add/Edit Building Methods
    
    @objc fileprivate func addBuilding() {
        navigationController?.pushViewController(addBuildingVC, animated: true)
    }
    
    fileprivate func editBuilding(withId bldId: String) {
        
        // Controller to edit buildings
        let editBuildingVC = EditBuildingViewController()
        editBuildingVC.buldingId = bldId
        navigationController?.pushViewController(editBuildingVC, animated: true)
        
    }
    
    // MARK: - Table View Setup and Delegate Methods
    
    fileprivate func tableViewSetUp() {
        
        // Add Building Button
        
        let topInset = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height
        
        var bttnFrame = self.view.frame
        bttnFrame.origin.y = topInset
        bttnFrame.size.height = 50
        
        let bttn = UIButton(frame: bttnFrame)
        bttn.setTitle("Can't find your building? Add it.", for: [])
        bttn.addTarget(self, action: (#selector(self.addBuilding)), for: .touchUpInside)
        bttn.backgroundColor = .red
        
        let frameOffset = 50 + bttnFrame.origin.y
        
        // Tableview
        
        tableView.frame = CGRect(x: 0, y: frameOffset, width: view.frame.width, height: view.frame.height - frameOffset)
        tableView.backgroundColor = Style.MainBackgroundColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)
        self.view.addSubview(bttn)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let bldId = displayBuildingName_toId[displayBuildingName[indexPath.row]] {
            self.editBuilding(withId: bldId)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayBuildingName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath as IndexPath)
        cell.textLabel!.text = "\(displayBuildingName[indexPath.row])"
        return cell
    }
    
}




