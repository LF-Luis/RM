//
//  MapVC.swift
//  RM
//
//  Created by Luis Fernandez on 8/11/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapVCDelegate: class {
    func didFinishSelectingLocation(_ sender: MapVC)
    func errorGettingAuthorization(_ sender: MapVC)
}

class Map: NSObject, CLLocationManagerDelegate {
    
    fileprivate static var locationManager = CLLocationManager()
 
    class func getPermission() {
        // Request permission to use location service
        locationManager.requestWhenInUseAuthorization()
    }
    
    // CLLocationDegrees is Double type
    class func getLocation() -> (latitude : CLLocationDegrees?, longitude : CLLocationDegrees?) {
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            // Start the update of user's location
            locationManager.startUpdatingLocation()
            
            // Set location to start location of view
            let lat = locationManager.location?.coordinate.latitude
            let long = locationManager.location?.coordinate.longitude
            
            locationManager.stopUpdatingLocation()
            
            return(lat, long)
        }
        
        return (nil, nil)
    }
    
    // This class method pops an alert to User asking them to enable Location Service (by going into the iPhone's Setting app) if they have not already
    // dimissController: Bool will exit current view and then open Settings app
    // Use to directly ask to open Settings
    class func openIphoneSettingsToEnableLocation(controller: UIViewController, dismissController: Bool, isAsync: Bool) {
        
        let alert = UIAlertController(title: "Location Service Disabled", message: "This app relies heavily on Location Service, please open Settings to enable it.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { (action) in
            
            if dismissController {
                controller.dismiss(animated: true, completion: nil)
            }
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        })
        
        if isAsync {
            DispatchQueue.main.async(execute: {
                controller.present(alert, animated: true, completion: nil)
            })
        }
        else {
            controller.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // This function is meant to be used to check if location service is avilable. If it is not, the user will be prompted to enable it by going into the iPhone's Settings app.
    // Use to check if location service is authorized, if not function will prompt User
    class func checkToEnableLocation(controller: UIViewController, dismissController: Bool, isAsync: Bool) {
        
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            openIphoneSettingsToEnableLocation(controller: controller, dismissController: dismissController, isAsync: isAsync)
        }
        
        // add: after user selects to "Open Settings", first dimiss controller and then open settings
        
    }
    
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
//        }
//    }
//    
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        
//        print("LocationMaanger:didFailWithError error: \(error.localizedFailureReason) \(error.localizedDescription)")
//        
//        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse {
//
//        }
//        
//    }

}

class MapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    /*
     NOTE:
     
     blue marker: refers to User's location (set automatically is User is allowing app to use location)
     red marker: refers to Marker location (variable name is "marker", set in func setMarker() )
     
     This view controller will launch if either blue or red marker exist. If none exist, this view controller will pop back to its parent view controller and display an Alert asking user to allow this app to use location.
     */
    
    // Marker latitude and longitude
    var latitude: Double?
    var longitude: Double?
    
    var markerText: String?
    
    fileprivate var userLatitude: Double?
    fileprivate var userLongitude: Double?
    
    weak var delegate: MapVCDelegate?
    
    // Used to notify parent view controller that marker location was changed
    var didChangeLocation: Bool = false
    
    fileprivate var _firstLocationUpdate: Bool = false
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate lazy var mapView = GMSMapView()  // Made it a lazy variable because for some reason when declared in this scope otherwise, it throws an error
    fileprivate var marker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        // A minimum distance a device must move before update event generated
        locationManager.distanceFilter = 500
        
        // Set up marker
        marker.isDraggable = true
        marker.map = self.mapView
        
        // Add GMSMapView to current view
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        self.view = mapView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Request permission to use location service
        locationManager.requestWhenInUseAuthorization()
        // Request permission to use location service when the app is run
        //        locationManager.requestAlwaysAuthorization()
        // Start the update of user's location
        locationManager.startUpdatingLocation()
        
        // Set location to start location of view
//        let currLat = locationManager.location?.coordinate.latitude
//        let currLong = locationManager.location?.coordinate.longitude
        
        // Set Marker Text
        if markerText != nil { marker.title = markerText! }
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        
        DispatchQueue.main.async { () -> Void in
            self.mapView.isMyLocationEnabled = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.didFinishSelectingLocation(self)
    }
    
    func setMarker(latitude lat: Double, longitude long: Double) {
        latitude = lat
        longitude = long
        marker.position = CLLocationCoordinate2DMake(lat, long)
        mapView.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 18)
    }
    
    fileprivate func fitBoundsWithUserLocatio(userLatitude userLat: Double, userLongitude userLong: Double) {
        if _firstLocationUpdate { // means that user location was found
            let firstPos = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
            var posBounds = GMSCoordinateBounds()
            let padding: CGFloat = 100.0
            if latitude != nil && longitude != nil {
                let secPos = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                posBounds = GMSCoordinateBounds(coordinate: firstPos, coordinate: secPos)
            }
            else {
                setMarker(latitude: userLat, longitude: userLong)
                posBounds = GMSCoordinateBounds(coordinate: firstPos, coordinate: firstPos)
            }
            let updateCam = GMSCameraUpdate.fit(posBounds, withPadding: padding)
            mapView.moveCamera(updateCam)
        }
//        else {
//            mapView.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 18)
//        }
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
            
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        latitude = marker.position.latitude
        longitude = marker.position.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse)
        {
            mapView.isMyLocationEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("LocationMaanger:didFailWithError error: \(error.localizedDescription)")
        
        if
            CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse,
            (self.longitude == nil || self.latitude == nil)
        {
            delegate?.errorGettingAuthorization(self)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // Moves marker locaion based on movement of user's device
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let newLocation = locations.last
//        mapView.camera = GMSCameraPosition.camera(withTarget: newLocation!.coordinate, zoom: 18.0)
//        mapView.settings.myLocationButton = true
//        self.view = self.mapView
        
        // Create marker and set location
//        marker.position = CLLocationCoordinate2DMake(newLocation!.coordinate.latitude, newLocation!.coordinate.longitude)
//        marker.map = self.mapView
        
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        didChangeLocation = true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        didChangeLocation = true
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        marker.position = CLLocationCoordinate2DMake(latitude!, longitude!)
    }
    
}


