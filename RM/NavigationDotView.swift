//
//  NavigationDotView.swift
//  RM
//
//  Created by Luis Fernandez on 7/29/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

// DEPRECATED
// Initial version of app had three dots at the bottom of the main view.
// The User could swipe the screen left-to-right or vice-versa to move between views, as the User
// navigated views the NavigationDotView would update

class DotView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.width / 2
        backgroundColor = UIColor.gray //Style.MainColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class NavigationDotView: UIView {
    
    // Using static values for this view because it will be the same in all devices
    fileprivate let dotDiam = 10
    
    fileprivate let dotSeparation = 15
    
    fileprivate var colordot0 = true
    
    fileprivate var dot0 = DotView()
    fileprivate var dot1 = DotView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView(){
        self.frame.size.width = CGFloat(dotDiam + dotSeparation)
        self.frame.size.height = CGFloat(dotDiam)
        
        dot0 = DotView(frame: CGRect(x: 0, y: 0, width: dotDiam, height: dotDiam))
        dot1 = DotView(frame: CGRect(x: dotSeparation, y: 0, width: dotDiam, height: dotDiam))
        
        dot0.backgroundColor = Style.MainColor
        
        addMultipleSubviews(dot0, dot1)
        
        self.isUserInteractionEnabled = false
        
    }
    
    func removeView() {
        
        if dot0.backgroundColor == Style.MainColor{
            self.colordot0 = true
        }
        
        dot0.backgroundColor = .clear
        dot1.backgroundColor = .clear
        
    }
    
    func reappearView() {
        
        if colordot0 {
            colordot0 = false
            dot0.backgroundColor = Style.MainColor
            dot1.backgroundColor = .gray
            return
        }
        
        colordot0 = false
        dot0.backgroundColor = .gray
        dot1.backgroundColor = Style.MainColor
        
    }
    
    func updateDot(forDotNumber d: CGFloat) {
        
        if d == 0.0 {
            
            dot0.backgroundColor = Style.MainColor
            dot1.backgroundColor = .gray
            return
            
        }
        
        dot0.backgroundColor = .gray
        dot1.backgroundColor = Style.MainColor
        
    }

}
