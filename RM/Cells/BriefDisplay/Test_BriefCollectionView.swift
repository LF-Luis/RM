//
//  QuickDisplayCell.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Alamofire

class test_BriefCollectionView: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var LFdelegate: BriefCollectionViewDelegate?
    
    var loadingRmsErr = LoadingRoomsError.none
    
    // indexToRMId is use to know which item on the listCellData array was selected
    fileprivate var indexToRMId: [Int : String] = [:]
    
    fileprivate let cellId = "cell"
    
    fileprivate var listCellData : [Room]?
    
    // This variable is used in the get rooms API call to know how many rooms are currently in local memory
    fileprivate var lastRecordCount: Int = 7
    
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
        loadData()
        
        // Subscribing to notification posted by BriefCollectionView
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: loadRoomsNotifKey), object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(){
        
        let (lat, long) = Map.getLocation()
        
        if lat == nil || long == nil {
            
            print("Failed to get location.")
            loadingRmsErr = .failedGettingLocation
            self.refreshControl.endRefreshing()
            return
        }
        
        DatabaseConnection.getRoomsMainDisplay(latitude: lat!, longitude: long!, forDay: TimesHelper.weekDay(forDate: Date()), lastRecordCount: nil) { (rooms) in
            if rooms != nil {
                self.listCellData = rooms! as [Room]
                self.collectionView.reloadData()
            }
            else {
                print("LF: Load of data failed")
                
            }
        }
        
        // This is only used if function was called via re-load of view.
        refreshControl.endRefreshing()
        
    }
    
    // Controller Pull-Down Refresh
    func setUpRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(onRefresh), for: UIControlEvents.valueChanged)
    }
    
    func onRefresh(_ sender: UIRefreshControl!) {
        // Load data again
        loadData()
        //        collectionView.performBatchUpdates({
        ////            collectionView.insertItems(at: [IndexPath])
        //        }, completion: nil)
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
        return listCellData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        // Loading a room cell
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BriefDisplayCell
        
        let currentRoom = listCellData![indexPath.row]
        
        cell.setData(forRoom: currentRoom)
        
        // Store room id with corresponding index number
        
        indexToRMId[indexPath.row] = currentRoom.id
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let lastElement = dataSource.count - 1
//        if indexPath.row == lastElement {
//            // handle your logic here to get more items, add it to dataSource and reload tableview
//        }
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        return CGSizeMake(frame.width, CellStyle.BriefCellHeight)
        return CGSize(width: collectionView.frame.size.width, height: CellStyle.BriefCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        LFdelegate?.didSelectRoom("ddddddd")    // FIXME: Delegation not working between nested collection views. Using NSNotif.
        
        if let rmId = indexToRMId[indexPath.row] as String? {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: briefCollectionViewNotifKey), object: self, userInfo: [notifCellId:rmId])
            
        }
        
    }
    
    
}
