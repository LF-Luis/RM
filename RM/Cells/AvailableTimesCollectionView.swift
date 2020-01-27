//
//  AvailableTimesCollectionView.swift
//  RM
//
//  Created by Luis Fernandez on 8/3/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//


import UIKit

class AvailableTimesCollectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    // This view controller will set up multiple lines of times like this, explicitly with day characters
    /*
        S   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
        M   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
        T   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
        W   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
        T   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
        F   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
        S   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
     */
    
    fileprivate let cellId = "cell"
    
    /**
     Use to adjust view's total height.
     See below in :sizeForItemAtIndexPath
     */
    var adjustTotalHeight = CGFloat(0)
    
    var cellData: [AvailableTimes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }
    
    // MARK: Setup
    
    fileprivate func setUpCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.invalidateLayout()
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout) as UICollectionView!
        collectionView!.dataSource = self
        collectionView!.delegate = self
        
        //        collectionView?.alwaysBounceVertical = true
        collectionView!.backgroundColor = Style.MainBackgroundColor
        collectionView!.showsVerticalScrollIndicator = false
        
        collectionView!.register(AvailableHoursCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    // MARK: Collection View Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count 
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AvailableHoursCell
        cell.updateConstraints()
        if cellData.isEmpty { return cell } // exit if empty data
        
        cell.setUpView(withAvailableTimes: cellData[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: (view.frame.height + adjustTotalHeight) / CGFloat(cellData.count))
    }
    
}



