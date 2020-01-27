//
//  TimesCell.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

class TimesCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let timeLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        return l
    }()
    
    func setupViews() {
//        
//        
//        setTranslatesAutoresizingMaskIntoConstraintsFalse(iconImg, collectionView, title)
//        
//        contentView.addMultipleSubviews(iconImg, collectionView, title)
        
        
//        
//        addConstraintsWithVisualFormat("H:|-15-[v0]-20-[v1]", views: iconImg, title)
//        //        addConstraintsWithVisualFormat("V:|-10-[v0]", views: iconImg)
//        
//        addConstraintsWithVisualFormat("H:|[v0]|", views: collectionView)
//        
//        addConstraintsWithVisualFormat("V:|-7-[v0][v1(20)]-2-|", views: title, collectionView)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderWidth = 1.5
        layer.borderColor = CellStyle.TCBorderColor.cgColor
        
        let bView = UIView()
        bView.backgroundColor = CellStyle.TCBackgroundColor
        bView.alpha = 0.5
        bView.layer.cornerRadius = 7.0
        backgroundView = bView
        
        layer.cornerRadius = 7.0
        
        contentView.addSubview(timeLabel)
        
        addConstraintsWithVisualFormat("V:|[v0]|", views: timeLabel)
        addConstraintsWithVisualFormat("H:|[v0]|", views: timeLabel)
        
    }
    
}
