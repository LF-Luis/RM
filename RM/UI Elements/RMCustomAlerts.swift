//
//  RMCustomAlerts.swift
//  RM
//
//  Created by Luis Fernandez on 7/23/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation


class RMCustomAlerts {
    
    // Simple user alert that has "Ok" action only. "Ok" action does nothing but warn user.
    class func presentSimpleOkAlert(cotroller ctlr: UIViewController, title: String, message: String, async: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        if async {
            DispatchQueue.main.async(execute: {
                ctlr.present(alert, animated: true, completion: nil)
            })
        }
        else {
            ctlr.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
}
