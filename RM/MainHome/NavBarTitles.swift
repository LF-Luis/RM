//
//  NavBarTitles.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/11/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//


import UIKit

/* Not in use */
class _NavBarTitles: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    let navTitle = ["Near Me", "My Favorites"]
    
    
    var layoutInsetSize = CGFloat()
    var navTextTotalWidth = CGFloat()
    let titlesExtraPadding: CGFloat = 100.0
    
    let cellWidth = CGFloat(400)
    let cellHeight = CGFloat(50)
    
    let _cellId = "cell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLengths()
        
        print("frame: \(frame.size.width)")
        print("layoutinset: \(layoutInsetSize)")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        //        collectionView.contentInset = UIEdgeInsets(top: 0, left: 150, bottom: 0, right: 150)
        ////        layout.sectionInset = UIEdgeInsets(top: 0, left: 150, bottom: 0, right: 150)
        
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var homeController: HomeController = {
        let hC = HomeController()
//        hC.w = self
        return hC
    }()
    
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal        
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: self.layoutInsetSize, bottom: 0, right: self.layoutInsetSize)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    
    func setLengths(){
        
        
        var lenght: CGFloat = 0.0
        var maxlength: CGFloat = 0.0
        
        for item in navTitle {
            let stringWidth = NSAttributedString(string: item).size().width
            
            if stringWidth > maxlength {
                maxlength = stringWidth
            }
            
            lenght = lenght + stringWidth + titlesExtraPadding
            
        }
        
        print("maxLength: \(maxlength)")
        print("frame__: \(frame.size.width)")
        print("extrapadding: \(titlesExtraPadding)")
        
        layoutInsetSize = ( frame.size.width - maxlength + titlesExtraPadding) / 2
        navTextTotalWidth = lenght
        
    }
    
    func scrollNavTitle(_ toMenuIndex: CGFloat) {
        var rect = collectionView.frame
        
        rect.origin.x = navTextTotalWidth * toMenuIndex
        
        collectionView.scrollRectToVisible(rect, animated: true)
    }
    
    
    let titleBracket: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()
    
    func setUpViews() {
        
        backgroundColor = .clear
        
        collectionView.register(NavBarTitlesCell.self, forCellWithReuseIdentifier: _cellId)
        
        addSubview(collectionView)
        
        setTranslatesAutoresizingMaskIntoConstraintsFalse(collectionView)

        addConstraintsWithVisualFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithVisualFormat("V:|[v0]|", views: collectionView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return navTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _cellId, for: indexPath) as! NavBarTitlesCell
        
        cell.title.text = navTitle[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let str = NSAttributedString(string: navTitle[indexPath.row])
        
        let strWidth = str.size().width + titlesExtraPadding
        
        return CGSize(width: strWidth, height: cellHeight)
    }
    
    //    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //
    //        collectionView?.collectionViewLayout.invalidateLayout()
    //    }
    
    
    
}


class NavBarTitlesCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let title:UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        return l
    }()
    
    func setupViews() {
        //        backgroundColor = .clearColor()
//        backgroundColor = .blueColor()
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(title)
        
        addConstraintsWithVisualFormat("V:|[v0]|", views: title)
        addConstraintsWithVisualFormat("H:|[v0]|", views: title)
        
    }
    
}
