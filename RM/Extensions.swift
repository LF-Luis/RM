//
//  Extensions.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    
    /**
     For one or multiple views, set translatesAutoresizingMaskIntoConstraints to false.
     This is usually done before using addConstraintsWithFormat()
     
     -Author:
     Luis Fernandez
     
     -Returns:
     Your view with translatesAutoresizingMaskIntoConstraints set to false.
     
     -Parameters:
     One or multiple views.
     */
    
    func setTranslatesAutoresizingMaskIntoConstraintsFalse(_ views: UIView...) {
        for viewI in views {
            viewI.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func addConstraintsWithVisualFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }

    func addMultipleSubviews(_ views: UIView...) {
        for viewI in views {
            addSubview(viewI)
        }
    }
    
}


