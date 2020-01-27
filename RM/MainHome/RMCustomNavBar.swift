//
//  test.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/11/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Foundation

class LineView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Style.MainColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class NavBracketView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBracket()
    }
    
    func setBracket() {
        
        // bracket thickness |
        let bt = 2.5
        
        // bracket width _
        let bw = 7
        
        // Left Bracket (LB)
        let LBtop = LineView()
        let LBcenter = LineView()
        let LBbottom = LineView()
        
        setTranslatesAutoresizingMaskIntoConstraintsFalse(LBtop, LBcenter, LBbottom)
        addMultipleSubviews(LBtop, LBcenter, LBbottom)
        
        addConstraintsWithVisualFormat("H:|[v0(\(bw))]", views: LBtop)
        addConstraintsWithVisualFormat("V:|[v0(\(bt))]", views: LBtop)
        
        addConstraintsWithVisualFormat("H:|[v0(\(bt))]", views: LBcenter)
        addConstraintsWithVisualFormat("V:|[v0]|", views: LBcenter)
        
        addConstraintsWithVisualFormat("H:|[v0(\(bw))]", views: LBbottom)
        addConstraintsWithVisualFormat("V:[v0(\(bt))]|", views: LBbottom)
        
        // Right Bracket (RB)
        let RBtop = LineView()
        let RBcenter = LineView()
        let RBbottom = LineView()
        
        setTranslatesAutoresizingMaskIntoConstraintsFalse(RBtop, RBcenter, RBbottom)
        addMultipleSubviews(RBtop, RBcenter, RBbottom)
        
        addConstraintsWithVisualFormat("H:[v0(\(bw))]|", views: RBtop)
        addConstraintsWithVisualFormat("V:|[v0(\(bt))]", views: RBtop)
        
        addConstraintsWithVisualFormat("H:[v0(\(bt))]|", views: RBcenter)
        addConstraintsWithVisualFormat("V:|[v0]|", views: RBcenter)
        
        addConstraintsWithVisualFormat("H:[v0(\(bw))]|", views: RBbottom)
        addConstraintsWithVisualFormat("V:[v0(\(bt))]|", views: RBbottom)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TitleFormatt: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
        font = .boldSystemFont(ofSize: 18) //font.fontWithSize(24)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class NavBarGradient: UIView{
    
    var gradientLayer: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = frame
    }
    
    func setGradient() {
        let navColor = UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1).cgColor
        let clearColor = UIColor.white.withAlphaComponent(0).cgColor

        gradientLayer = CAGradientLayer()

        gradientLayer.frame = frame
        gradientLayer.colors = [navColor, navColor, clearColor, clearColor, navColor, navColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = [0, 0.24, 0.3, 0.7, 0.76, 1]
        self.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class RMCustomNavBar: UIView {
    
    var txtBarSize = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let title1: UILabel = {
        let v = TitleFormatt()
        v.text = "Near Me"
        return v
    }()
    
    let title2: UILabel = {
        let v = TitleFormatt()
        v.text = "My Favorites"
        return v
    }()
    
    func setupTitles(){
        
        let stringWidth = Int(title2.intrinsicContentSize.width) + 10
        txtBarSize = stringWidth
        
        setTranslatesAutoresizingMaskIntoConstraintsFalse(title1, title2)
        addMultipleSubviews(title1, title2)
        addConstraintsWithVisualFormat("V:|[v0]|", views: title1)
        addConstraintsWithVisualFormat("V:|[v0]|", views: title2)

        addConstraintsWithVisualFormat("H:[v0(\(stringWidth))]", views: title1)
        addConstraintsWithVisualFormat("H:[v0(\(stringWidth))]", views: title2)
        
        let a = NSLayoutConstraint(item: title1, attribute: .right, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: CGFloat(stringWidth) * 0.5)
        let b = NSLayoutConstraint(item: title2, attribute: .left, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: CGFloat(stringWidth) * 0.5)
        addConstraints([a, b])
    }
    
}


