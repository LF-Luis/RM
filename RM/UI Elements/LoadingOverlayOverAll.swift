//
//  LoadingOverlayOverAll.swift
//  RentABuddy
//
//  Created by Luis Fernandez on 6/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
/*
public class LoadingOverlayOverAll {
    
    var overlayView: UIView?
    var activityIndicator: UIActivityIndicatorView?
    
    class var shared: LoadingOverlayOverAll {
        struct Static {
            static let instance: LoadingOverlayOverAll = LoadingOverlayOverAll()
        }
        return Static.instance
    }

    public func showOverlay() {
        let currentScreenBounds = UIScreen.mainScreen().bounds
        
        overlayView = UIView(frame: currentScreenBounds)
        overlayView!.backgroundColor = UIColor.blackColor()
        overlayView!.alpha = 0.55
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 100, 100))
        activityIndicator!.center = overlayView!.center
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        overlayView!.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
        
        UIApplication.sharedApplication().keyWindow?.addSubview(overlayView!)
    }
    
    func endOverlay() {
        activityIndicator?.stopAnimating()
        overlayView?.removeFromSuperview()
    }
}
 */


class LoadOverlay: NSObject{
    
    fileprivate static var overlayView: UIView?
    fileprivate static var activityIndicator: UIActivityIndicatorView?
    
    class func showOverlay(forView v: UIView){
        
        v.addSubview(getOverlay(forFrame: v.frame))
    
    }
    
    class func showOverlayOverAppWindow() {
        let currentScreenBounds = UIScreen.main.bounds
        
        UIApplication.shared.keyWindow?.addSubview(getOverlay(forFrame: currentScreenBounds))
    }
    
    class func endOverlay() {
        activityIndicator?.stopAnimating()
        overlayView?.removeFromSuperview()
    }
    
    fileprivate class func getOverlay(forFrame frame:CGRect) -> UIView {
        
        overlayView = UIView(frame: frame)
        overlayView!.backgroundColor = Style.OverLayColor
        overlayView!.alpha = 0.55
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 100, height: 100))
        activityIndicator!.center = overlayView!.center
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        overlayView!.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
        
        return overlayView!
        
    }
    
}

