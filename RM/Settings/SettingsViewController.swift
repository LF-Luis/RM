//
//  SettingsViewController.swift
//  RentABuddy
//
//  Created by Luis Fernandez on 7/1/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka   // CocoaPod

class SettingsViewController: BaseFormVC {
    
    // flags wheather user is using FB profile pic. If not, it allows app to ask for its usage.
    fileprivate var hasFBProfPic = false
    
    var currentUser = RMUser()
    
    let cellContentWidth = 0.909 *  AppSize.screenWidth
    
    // Navigation bar item
    var barTopDoneItem: UIBarButtonItem!
    
    // Form Tags
    let nameTag = "Name"
    let emailTag = "Email"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        
        setUpViewForm()
        setUpDonNavButton()
        DatabaseConnection.getUserID { (idIs) in
            print(idIs)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Settings"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("will disappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpDonNavButton() {
        // Done nav bar button
        barTopDoneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.navDoneAction))
        navigationItem.rightBarButtonItem = barTopDoneItem
    }
    
    func setUpFeedbackNavButton() {
        // Help nav bar button
        let navfeedbackButton = UIBarButtonItem(title: "Feedback", style: UIBarButtonItemStyle.plain, target: self, action: #selector(navHelpAction))
        navigationItem.leftBarButtonItem = navfeedbackButton
        let attributes = [ NSForegroundColorAttributeName : UIColor.red]
        navfeedbackButton.setTitleTextAttributes(attributes, for: UIControlState())
    }
    
    func navDoneAction() {
        self.performSegue(withIdentifier: "UnwindToHomeController", sender: self)
    }
    
    func navHelpAction() {
        navigationController?.pushViewController(HelpViewController(), animated: true)
    }
    
    func setUpViewForm() {
        
        currentUser.firstName = ""
        currentUser.lastName = ""
        currentUser.email = ""
        
        LoadOverlay.showOverlay(forView: view)
        
        DatabaseConnection.getUserInfo { (rmUserInfo) in
            if rmUserInfo != nil {
                self.currentUser = rmUserInfo!
                self.loadForm()
                self.tableView?.reloadData()
                LoadOverlay.endOverlay()
                self.setUpFeedbackNavButton()
            }
            // error will print in .getUserInfo class function
        }
    }
    
    func permissionFBPicAction(_ gesture: UIGestureRecognizer) {
        
        if hasFBProfPic { return }
        
        let alert = UIAlertController(title: "Profile Picture", message: "Allow RM to use your Facebook profile picture?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            // FIXME: Get facebook profile pic url, store to user back end
            // load pic to current view, reload tableview data
            print("// FIXME: Get facebook profile pic url, store to user back end \n// load pic to current view, reload tableview data")
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive) { (action) -> Void in })
        
        self.present(alert, animated: true, completion: nil)
        
//        if let imageView = gesture.view as? UIImageView {}
    }
    
    func logOut() {
        networkService?.logout({ (error) in
            if error == nil {
                print("Succesful log out")
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: logInScreenNotifKey), object: self, userInfo: nil)
            }
            else {
                print("Unsuccesful log out (Add network error connection alert)")
            }
        })
    }

    // MARK: Form
    
    func loadForm() {
        
        form =
            
            Section()
            
            +++ Section()
       
            +++ Section() {
                
                // Template for User picture, will be added later
                
//                var header = HeaderFooterView<ProfilePicView>(.Class)
//                header.onSetupView = { (view: ProfilePicView, section: Section) -> () in
//                    
//                    view.profilePic.image = self.currentUser.squareProfilePic
//                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.permissionFBPicAction(_:)))
//                    view.profilePic.addGestureRecognizer(tapGesture)
//                    view.profilePic.userInteractionEnabled = true
//                    
//                }
//                
//                $0.header = header
                
                 $0.header = HeaderFooterView<RMLogoView>(HeaderFooterProvider.class)
            }
            
            +++ Section() {
                var header = HeaderFooterView<SettingsUserName>(.class)
                header.onSetupView = { (view: SettingsUserName, section: Section) -> () in
                    
                    if let date = self.currentUser.accountCreationDate {
                        let dateFormt = DateFormatter()
                        dateFormt.dateFormat = "MMM dd, yyyy"
                        let strDate: String = dateFormt.string(from: date)
                        view.orText.text = "Member since: " + strDate
                    }
                    
                }
                
                $0.header = header
            }
            
            +++ Section()

            <<< LabelRow (nameTag) {
                $0.title = nameTag
                $0.value = currentUser.firstName! + " " + currentUser.lastName!
            }
            
            <<< LabelRow (emailTag) {
                $0.title = emailTag
                $0.value = currentUser.email!
            }
            
            /*
            <<< ButtonRow("History") {
                $0.title = $0.tag
                $0.presentationMode = PresentationMode.Show(controllerProvider: ControllerProvider.Callback { HistoryViewController()}, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) } )
            }
            // Rooms or buildings this person has created/edited.
            // Rooms or buildings this person has been to.

            <<< ButtonRow("Notifications") {
                $0.title = $0.tag
                $0.presentationMode = PresentationMode.Show(controllerProvider: ControllerProvider.Callback { NotificationsViewController()}, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) } )
            }
            // Asks if user wants to be notified of empty arounds around them
            // Asks if user wants to recieve lock screen notification asking if they are in the room they last viewed (only if location shows they are in that building)
            */
            
            <<< ButtonRow("About") {
                $0.title = $0.tag
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { AboutVC()}, onDismiss: { vc in vc.navigationController?.popViewController(animated: true)
                } )
            }
            
            +++ Section()
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Log Out"
                }
                .cellUpdate { cell, row in
                    cell.textLabel!.textColor = UIColor.red
                }
                .onCellSelection({ (cell, row) in
                    self.logOut()
                })
        
    }
    
}

class SettingsUserName: UIView {
    
    var orText = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        orText = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 12))
        orText.textAlignment = .center
        orText.font = UIFont.boldSystemFont(ofSize: 14)
        orText.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 12)
        orText.contentMode = .scaleAspectFit
        self.addSubview(orText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

