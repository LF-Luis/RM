//
//  BriefDisplayCell.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit


class BriefDisplayCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    fileprivate let cellWidth = CGFloat(400)
    fileprivate let cellHeight = CGFloat(25)
    
    fileprivate let _cellId = "cell"
    
    fileprivate var times: [String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        setUpViews()
    }
    
    override func prepareForReuse() {
        self.collectionView.reloadData()
        super.prepareForReuse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    func setData(forRoom room: Room) {
        titleLabel.text = room.building.name
        subTitleLabel.text = room.floor + "." + room.roomNum
        times = room.todayFormattedTimes
        iconImg.image = UIImage(named: room.iconId)
    }
    
    func setData(forEvent event: Event) {
        titleLabel.text = event.name
        subTitleLabel.text = event.description
        
        if event.date != nil {
            times = [ TimesHelper.formattedTimeMeridiem(fromDate: event.date!) ]
        }
        
        if event.uiImage != nil {
            iconImg.image = event.uiImage!
        }
        else {
            // event has no image, use default app icon
            iconImg.image = UIImage(named: DefaultValues.defaultRoomIconId)
        }
        
    }
    
    fileprivate let titleLabel: UILabel = {
        let l = UILabel()
        l.font = l.font.withSize(18) //.boldSystemFontOfSize(17) //l.font.fontWithSize(24)
        return l
    }()
    
    fileprivate let subTitleLabel: UILabel = {
        let l = UILabel()
        l.font = l.font.withSize(18) //.boldSystemFontOfSize(17) //l.font.fontWithSize(24)
        return l
    }()
    
    fileprivate let iconImg: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    fileprivate func setUpViews() {
        
        backgroundColor = .white
        
        collectionView.register(TimesCell.self, forCellWithReuseIdentifier: _cellId)
        
        contentView.addMultipleSubviews(iconImg, collectionView, titleLabel, subTitleLabel)
        
        setTranslatesAutoresizingMaskIntoConstraintsFalse(iconImg, collectionView, titleLabel, subTitleLabel)
        
        addConstraintsWithVisualFormat("V:|-8-[v0]-8-|", views: iconImg)
        
        addConstraintsWithVisualFormat("H:|-20-[v0]-25-[v1]", views: iconImg, titleLabel)
        addConstraintsWithVisualFormat("H:[v0]-25-[v1]|", views: iconImg, subTitleLabel)
        addConstraintsWithVisualFormat("H:[v0]-25-[v1]|", views: iconImg, collectionView)
        
        addConstraintsWithVisualFormat("V:|-8-[v0]-7-[v1]-8-[v2(25)]-8-|", views: titleLabel, subTitleLabel, collectionView)
        
        let iconWidthEqualToHeight = NSLayoutConstraint(item: iconImg, attribute: .width, relatedBy: .equal, toItem: iconImg, attribute: .height, multiplier: 1.0, constant:0)
        
        addConstraints([iconWidthEqualToHeight])
        
    }
    
    // Available times collection view in cell:
    
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
        
        //        return CGSizeMake(strWidth, cellHeight)
        
        return CGSize(width: strWidth, height: collectionView.frame.size.height)
    }
    
    //    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //
    //        collectionView?.collectionViewLayout.invalidateLayout()
    //    }
    
}

