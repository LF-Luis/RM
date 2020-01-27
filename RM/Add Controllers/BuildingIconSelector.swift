//
//  BuildingIconSelector.swift
//  RM
//
//  Created by Luis Fernandez on 5/30/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit
import Eureka

/// This table vc should be embedded in a navigation controller
class BuildingIconsSelector: UITableViewController {
    
    var bldSelected: String?
    var didSelectIcon: Bool = false
    
    fileprivate let bldImgs: [String] = ["apartments", "bank", "castle", "church", "church2", "church3", "circus", "city", "construction", "factory", "hospital", "hotel", "house", "house2", "house3", "market", "monuments", "officeblock", "officeblock2", "school", "skyscraper", "skyscraper2", "townhouse", "truck"]
    
    fileprivate let cellID = "cId"
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellStyle.BriefCellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        
        let imgName = bldImgs[indexPath.row]
        
        cell.textLabel?.text = imgName
        cell.imageView?.image = UIImage(named: imgName)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bldImgs.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        didSelectIcon = true
        bldSelected = bldImgs[indexPath.row]
        
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        }
        else {
            presentedViewController
        }
    }
    
}

