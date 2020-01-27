//
//  BriefCollectionView.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Alamofire

enum LoadingRoomsError {
    // FailedGettingLocation: failed to get the location of the user
    case failedGettingLocation
    case none
}

enum DisplayCellType {
    case Room
    case Event
}

struct DisplayCellIdentification {
    let idStr: String?
    let cellType: DisplayCellType
}

protocol BriefCollectionViewDelegate: class {
    func didFailTorefreshData(_ sender: BriefCollectionView)
    func didSelectRoom(_ roomId: String)
}

class BriefCollectionView: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var LFdelegate: BriefCollectionViewDelegate?
    
    var loadingRmsErr = LoadingRoomsError.none
    
    // This is use to know which item on the allDisplayData was selected and what type of data it is
    fileprivate var indexToIdentification = [Int: DisplayCellIdentification]()
    
    fileprivate var roomData = [Room]()
    fileprivate var eventData =  [Event]()
    fileprivate var allDisplayData = [Any]()    // this collection holds both Rooms and Events (and more if needed)
    
    fileprivate var userLat: Double?
    fileprivate var userLong: Double?
    
    fileprivate let cellId = "cell"
    
    // These values will prevent user's scrolling from constantly calling API when there is nothing more to call for
    fileprivate var attempsToLoadMoreData = 0
        // will be set to 0 again everytime data is gotten from the backend succesfully
    fileprivate let allowedAttempsToLoadMoreData = 3
    
    fileprivate let refreshControl = UIRefreshControl()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpRefresh()
        setUpCollectionView()
//        refreshData()
        
        // Subscribing to notification posted by BriefCollectionView
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: loadRoomsNotifKey), object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data Management
    
    func refreshData(){
        
        var shouldReloadView = false
        
        // This function removes all current data and gets new data
        
        (userLat, userLong) = Map.getLocation()
        
        if userLat == nil || userLong == nil {
            
            print("Failed to get location.")
            loadingRmsErr = .failedGettingLocation
            self.refreshControl.endRefreshing()
            return
        }
        
        let asyncGroup = DispatchGroup()
        
        asyncGroup.enter()
        
        DatabaseConnection.getRoomsMainDisplay(latitude: userLat!, longitude: userLong!, forDay: TimesHelper.weekDay(forDate: Date()), lastRecordCount: nil) { (rooms: [Room]?) in
            
            self.attempsToLoadMoreData = 0   // Count starts again
            
            if rooms != nil {
                self.roomData = rooms!
                shouldReloadView = true
            }
            else {
                print("LF: Load of ROOM data failed")
            }
            
            asyncGroup.leave()
            
        }
        
        asyncGroup.enter()
        
        DatabaseConnection.getEventsForMainDisplay(latitude: userLat!, longitude: userLong!, forDayAndTime: Date(), lastRecordCount: nil) { (events: [Event]?) in
            
            if events != nil {
                self.eventData = events!
                shouldReloadView = true
            }
            else {
                print("LF: Load of EVENT data failed")
            }
            
            asyncGroup.leave()
        }
        
        asyncGroup.notify(queue: .main) {
            
            if shouldReloadView {
                self.allDisplayData = self.eventData as [Any] + self.roomData as [Any]
                self.collectionView.reloadData()
            }
            
            // This is only used if function was called via re-load of view.
            self.refreshControl.endRefreshing()
            
        }
        
    }
    
    fileprivate func loadMoreData() {
        // This function appends to the current data in local memory
        // Should only be called after refreshData() has been called at least once
        // This function assumes that user's location is already stored in current class
        
        if userLat == nil || userLong == nil {
            // User's location was not stored in class
            return
        }
    
        var shouldUpdateView = false
        
        let asyncGroup = DispatchGroup()
        
        asyncGroup.enter()
        
        DatabaseConnection.getRoomsMainDisplay(latitude: userLat!, longitude: userLong!, forDay: TimesHelper.weekDay(forDate: Date()), lastRecordCount: roomData.count) { (rooms: [Room]?) in
            
            if
                rooms != nil,
                !(rooms!.isEmpty)
            {
                
                self.attempsToLoadMoreData = 0   // Count starts again
                
                // Appending API data to data source
                self.roomData.append(contentsOf: rooms!)
                
                shouldUpdateView = true
                
            }
            
            asyncGroup.leave()
            
        }
        
        asyncGroup.enter()
        
        DatabaseConnection.getEventsForMainDisplay(latitude: userLat!, longitude: userLong!, forDayAndTime: Date(), lastRecordCount: eventData.count) { (events: [Event]?) in
            
            if
                events != nil,
                !(events!.isEmpty)
            {
                // Appending API data to data source
                self.eventData.append(contentsOf: events!)
                
                shouldUpdateView = true
            }
            
            asyncGroup.leave()
            
        }
        
        asyncGroup.notify(queue: .main) {
            
            if shouldUpdateView {
                
                let initialDataCount = self.allDisplayData.count  // this will become old count
                
                self.allDisplayData.append(contentsOf: self.eventData as [Any] + self.roomData as [Any])
                
                let endIndex = self.allDisplayData.count - 1
                
                self.collectionView.performBatchUpdates({
                    
                    let newIndicies = Array(initialDataCount...endIndex)
                    
                    var indiciesToInsert = [IndexPath]()
                    
                    for index in newIndicies {
                        print(index)
                        indiciesToInsert.append(IndexPath(row: index, section: 0))
                    }
                    
                    self.collectionView.insertItems(at: indiciesToInsert)
                }, completion: nil)

            }
            
        }

    }

    // Controller Pull-Down Refresh
    func setUpRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(onRefresh), for: UIControlEvents.valueChanged)
    }
    
    func onRefresh(_ sender: UIRefreshControl!) {
        // refresh data
        refreshData()
    }
    
    func setUpCollectionView() {
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.backgroundColor = Style.MainBackgroundColor
        
        collectionView.register(BriefDisplayCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        
        setTranslatesAutoresizingMaskIntoConstraintsFalse(collectionView)
        addConstraintsWithVisualFormat("H:|-7.5-[v0]-7.5-|", views: collectionView)
        addConstraintsWithVisualFormat("V:|[v0]|", views: collectionView)
    }
    
    // MARK: - Collection View Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allDisplayData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Loading a room cell
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BriefDisplayCell

        let currentCell = allDisplayData[indexPath.row]
        
        if let cellItem = currentCell as? Room {    // cell item is a Room
            cell.setData(forRoom: cellItem)
            indexToIdentification[indexPath.row] = DisplayCellIdentification(idStr: cellItem.id, cellType: .Room)
        }
        
        if let cellItem = currentCell as? Event {   // cell item is an Event
            cell.setData(forEvent: cellItem)
            indexToIdentification[indexPath.row] = DisplayCellIdentification(idStr: cellItem.id, cellType: .Event)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: CellStyle.BriefCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let indexItem = indexToIdentification[indexPath.row]
        
        if
            let itemId = indexItem?.idStr,
            let itemType = indexItem?.cellType
        {

            NotificationCenter.default.post(name: Notification.Name(rawValue: briefCollectionViewNotifKey), object: self, userInfo: [notifCellId:itemId, notifCellType:itemType])
//            switch itemType{
//            case .Room:
//                
//                
//            case .Event:
//                print("LF: Event selected")
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        if
            allDisplayData.count > 0,
            indexPath.row == (allDisplayData.count - 1) && attempsToLoadMoreData < allowedAttempsToLoadMoreData
        {
            
            print(indexPath.row)
            print(allDisplayData.count)
            
            attempsToLoadMoreData = 1 + attempsToLoadMoreData
            
            // get more data
            self.loadMoreData()
        }
        
    }
    
    
}

