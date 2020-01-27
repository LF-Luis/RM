//
//  CustomImgViews.swift
//  RM
//
//  Created by Luis Fernandez on 4/30/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import GoogleMaps

class RMLogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "RMIcon.png"))
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfilePicView : UIView {
    
    let profilePic = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let circPicDiam = CGFloat(130)
        let cirPicXOrig = (AppSize.screenWidth - circPicDiam) / 2
        
        profilePic.frame = CGRect(x: cirPicXOrig, y: 0, width: circPicDiam, height: circPicDiam)
        
        profilePic.layer.cornerRadius =  profilePic.frame.size.width / 2
        
        profilePic.clipsToBounds = true
        profilePic.contentMode = UIViewContentMode.scaleAspectFill
        
        // Add Frame to pic
        profilePic.layer.borderWidth = 3.0
        profilePic.layer.borderColor = Style.MainColor.cgColor //UIColor.whiteColor().CGColor
        
        self.frame = CGRect(x: 0, y: 0, width: 330, height: 130)
        
        self.addSubview(profilePic)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainImage : UIView {
    
    let mainPic = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let appWidth = AppSize.screenWidth
        let imgWidth = appWidth / 3
        let imgHeight = imgWidth //+ 20
        let imgXPoint =  (appWidth - imgWidth) / 2
        mainPic.frame = CGRect(x: imgXPoint, y: 0, width: imgWidth, height: imgHeight)
        mainPic.clipsToBounds = true
        mainPic.contentMode = UIViewContentMode.scaleAspectFill
        self.frame = CGRect(x: 0, y: 0, width: 500, height: imgHeight)
        self.addSubview(mainPic)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MapView : UIView, GMSMapViewDelegate {
    
    fileprivate var latitude = Double()
    fileprivate var longitude = Double()
    fileprivate var userLatitude: Double?
    fileprivate var userLongitude: Double?
    fileprivate var marker = GMSMarker()
    fileprivate var _firstLocationUpdate: Bool = false
    fileprivate var mapView = GMSMapView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // map view set-up
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 18)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
//        self.frame = CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: AppSize.screenHeight * 0.35)
        mapView.frame = self.frame
        self.addSubview(mapView)
        
        // Marker set-up
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.isDraggable = false
        marker.map = mapView
        
        // get user location set-up
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        DispatchQueue.main.async { () -> Void in
            self.mapView.isMyLocationEnabled = true
        }
        
    }
    
    func setMarker(latitude lat: Double, longitude long: Double) {
        latitude = lat
        longitude = long
        marker.position = CLLocationCoordinate2DMake(lat, long)
        mapView.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 18)
        
        // Update the marker, after userLaitude and userLongitude have been set
        if userLatitude != nil && userLongitude != nil {
            fitBoundsWithUserLocatio(userLatitude: userLatitude!, userLongitude: userLongitude!)
        }
    }
    
    fileprivate func fitBoundsWithUserLocatio(userLatitude userLat: Double, userLongitude userLong: Double) {
        if _firstLocationUpdate { // means that user location was found
            let firstPos = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
            let secPos = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let posBounds = GMSCoordinateBounds(coordinate: firstPos, coordinate: secPos)
//            let positions = [firstPos, secPos]
//            for pos in positions {
//                posBounds.includingCoordinate(pos)
//            }
            let updateCam = GMSCameraUpdate.fit(posBounds, withPadding: 50.0)
            mapView.moveCamera(updateCam)
        }
        else {
            mapView.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 18)
        }
    }
    
    // User obesever location
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if
            !_firstLocationUpdate,
            change != nil,
            let userLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as? CLLocation
        {
            userLatitude = userLocation.coordinate.latitude
            userLongitude = userLocation.coordinate.longitude
            if userLatitude == nil || userLongitude == nil {
                return
            }
            _firstLocationUpdate = true
            fitBoundsWithUserLocatio(userLatitude: userLatitude!, userLongitude: userLongitude!)
//            let userLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
//            mapView.camera = GMSCameraPosition.camera(withTarget: userLocation.coordinate, zoom: 18)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

