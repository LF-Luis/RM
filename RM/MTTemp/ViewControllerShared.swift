//
//  ViewControllerShared.swift
//  RM
//
//  Created by Luis Fernandez on 8/12/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import Foundation

class ViewControllerShared  {
    static func handleNetworkCallError(_ error : NSError, networkService : NetworkProtocol, viewController : UIViewController) -> Void {
        print("Error: handleNetWorkCallError-------")
//        if (error.localizedDescription == "{\"message\":\"Authorization has been denied for this request.\"}") {
//            networkService.logout({ (error : NSError?) in
//                if (error == nil) {
//                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
//                    
//                    let controller : UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
//                    
//                    viewController.presentViewController(controller, animated: false, completion: nil)
//                }
//            })
//        } else {
//            ViewControllerShared.showMessage("Error", message: "The following error occurred calling the server: " + error.localizedDescription, viewController: viewController)
//        }
    }
    
//    static func showMessage(title : String, message : String, viewController : UIViewController) -> Void {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//        viewController.presentViewController(alert, animated: true, completion: nil)
//    }
}
