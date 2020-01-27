//
//  RoomDaysHoursView.swift
//  RM
//
//  Created by Luis Fernandez on 8/1/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

class AvailableHoursCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    // This view controller will set up times like this:
        // 1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
    // or, if needed, with day character
        // T   1 - 2 PM   3:30 - 5 PM   6 - 7:45 PM
    
    fileprivate let _cellId = "cell"
    
    let charLength = Int(20)
    
    fileprivate var times: [String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TimesCell.self, forCellWithReuseIdentifier: _cellId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    fileprivate func setData(_ dayTimes: [String]?) {
        times = dayTimes //type: [String]?
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView.reloadData()
//        })
    }
    
    fileprivate let dayChar: UILabel = {
        let s = UILabel()
        s.textAlignment = .center
        return s
    }()
    
    func setUpView(withAvailableTimes td: AvailableTimes) {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        td.sortRawTimes()
        setData(td.formattedTimesForDisplay())
        
        if td.dayChar == nil {
            contentView.addMultipleSubviews(collectionView)
            setTranslatesAutoresizingMaskIntoConstraintsFalse(collectionView)
            
            addConstraintsWithVisualFormat("V:|[v0]|", views: collectionView)
            addConstraintsWithVisualFormat("H:|[v0]|", views: collectionView)
            
            return
        }
        
        contentView.addMultipleSubviews(collectionView, dayChar)
        setTranslatesAutoresizingMaskIntoConstraintsFalse(collectionView, dayChar)
        
        dayChar.text = td.dayChar as String!
        
        addConstraintsWithVisualFormat("V:|[v0]|", views: collectionView)
        addConstraintsWithVisualFormat("V:|[v0]|", views: dayChar)
        addConstraintsWithVisualFormat("H:|[v0(\(charLength))][v1]|", views: dayChar, collectionView)
//        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return times?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _cellId, for: indexPath) as! TimesCell
        
        cell.timeLabel.text = times![indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let str = NSAttributedString(string: times![indexPath.row])
        
        let strWidth = str.size().width + 40
        
        return CGSize(width: strWidth, height: frame.height)
    }
    
}



