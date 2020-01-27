//
//  BaseFormVC.swift
//  RM
//
//  Created by Luis Fernandez on 8/12/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka

class BaseFormVC: FormViewController {
    
    var networkService: NetworkProtocol?
    
    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkService = NetworkService()
        
//        // check if user is logged in
//        
//        if (networkService!.hasPreviousAuthentication()) {
//            
//            // User has been authenticated before, trying to restablish connection auth with Facebook log in
//            
//            networkService!.login(FacebookProvider, controller: self) { (isSuccesful) in
//                
//                LoadOverlay.endOverlay()
//                
//                if isSuccesful {
//                    print("In BaseFormVC: auth was assured, Succesful Login! ")
//                }
//                else {
//                    
//                    // at this point, device says that user has been authorized before, but log in could not be established
//                    // app will log user out and prompt user to try and log in later
//                    // LAUNCH WELCOME SCREEN
//                    
//                    print("In BaseFormVC: auth was assured, but login failed")
//                    
//                    self.networkService?.logout({ (error) in
//                        print(error as Any)
//                        
//                        // FIXME: regardless if log out succeded, change/reload UI to non-logged in form and remove all data
//                        
//                    })
//                    
//                    let failedLoginAlert = UIAlertController(title: "RM", message: "Connection to Facebook failed unexpectedly, please try again (Log In using the Settings icon in the top-left corner)", preferredStyle: .alert)
//                    failedLoginAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                    
//                    DispatchQueue.main.async(execute: {
//                        self.present(failedLoginAlert, animated: true, completion: nil)
//                    })
//                }
//            }
//        }
        
        // Form options
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
    }
    
    func handleNetworkCallError(_ error : NSError) -> Void {
        ViewControllerShared.handleNetworkCallError(error, networkService: networkService!, viewController: self)
    }
    
}
