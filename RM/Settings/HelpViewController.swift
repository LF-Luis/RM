//
//  HelpViewController.swift
//  RentABuddy
//
//  Created by Luis Fernandez on 7/2/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka   // CocoaPod

class HelpViewController: FormViewController {

    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    
    // Form Tag
    let formText: String = "formText"
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        navigationItem.title = "Feedback"
        loadForm()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LoadOverlay.endOverlay()
    }
    
    func sendFormAction() {
        
        LoadOverlay.showOverlay(forView: self.view)
        
        let feedback = Feedback()
        
        if let formVals = form.values()[formText] as! String? {
            
            // Max 250 characters
            let charExceeded = formVals.characters.count - 10
            
            if (charExceeded > 250) {
                
                AppDelegate.getAppDelegate().showMessage(self, message: "Max 250 characters. \nYou exceeded by \(charExceeded) character\(charExceeded != 1 ? "s" : "" ).")
                
                LoadOverlay.endOverlay()
                
                return
            }
            
            feedback.feedbackMsg = formVals
            
        }
        else {
            LoadOverlay.endOverlay()
            return
        }
        
        let (lat, long) = Map.getLocation()
        
        if lat != nil && long != nil {
            feedback.longitude = long!
            feedback.latitude = lat!
        }
        
        DatabaseConnection.sendFeedback(feedback: feedback) { (error) in
            if error == nil {
                let alert = UIAlertController(title: "Thank you", message: "Your message was succesfully sent to RM.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                    
                    LoadOverlay.endOverlay()
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print(error?.localizedDescription)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    AppDelegate.getAppDelegate().showMessage(self, message:"There was a network error. \nPlease try again.")
                })
                LoadOverlay.endOverlay()
            }
        }

        
    }
    
    // MARK: Form
    
    func loadForm() {
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form
        
            +++ Section(header: "Contact RM and tell RM about: \n- Bugs in RM \n- How you mostly use RM \n- How you wish to use RM \n- How great RM is \n- Or just any general feedback for RM", footer: "Limited to 250 characters.")
            
            <<< TextAreaRow(formText) {
                $0.placeholder = "I love RM because..."
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 90)
                
        }
            
            +++ Section()
            
            <<< ButtonRow() { row in
                row.title = "Send to RM"
                row.onCellSelection({ (cell, row) in
                    self.sendFormAction()
                })
        }
        
    }
    
}
