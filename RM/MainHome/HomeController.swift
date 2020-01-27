//
//  ViewController.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

class HomeController: BaseCollectionVC, BriefCollectionViewDelegate {
    
    private let numberOfScrollViews = 1     // number of slides from NavBarTitles
    
    let cellId = "cell"
    fileprivate var topNavHeight: CGFloat = 0.0
    
    // This variable is used in conjunction to an NSNotification to load the data for the cells within these cells
    private var didLoadCellData = false
    
    // Use to check if user's authentication needs to be checked again
    private var lastViewDate: Date?
    
    let briefCollectionView = BriefCollectionView()
    
    var centerNavTitleAnchorConstraint: NSLayoutConstraint?
    var widthNavBracketConstraint: NSLayoutConstraint?
    
    let titles = RMCustomNavBar()
    let bracket = NavBracketView()

    // Navigation bar item
    var settingNavButton = UIBarButtonItem()
    var addNavButton = UIBarButtonItem()
    var infoNavButton = UIBarButtonItem()
    
    var navDotView = NavigationDotView()
    
    // MARK: - Controller's Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        briefCollectionView.LFdelegate = self
        
        setUpNavBarButtons()
        setUpCollectionView()
        askForLogInAuthAndLoadData()

        /*
         Put to use when favorites or multiple scroll-views are being used:
//        setUpNavBarAndDot()
         */
//        navigationController?.navigationBar.addSubview(gradient)
        navigationItem.title = "Rooms Near Me"
        
        // Subscribing to notification posted by BriefCollectionView
        NotificationCenter.default.addObserver(self, selector: #selector(openEditRoomVC), name: NSNotification.Name(rawValue: briefCollectionViewNotifKey), object: nil)
        
        // Subscribing to notification posted by anyone that Log In Screen should be presented
        NotificationCenter.default.addObserver(self, selector: #selector(askForLogInAuthAndLoadData), name: NSNotification.Name(rawValue: logInScreenNotifKey), object: nil)
        
        Map.getPermission()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpNavBarButtons()
        
        // If lastViewDate is not nil (which means that this is not the first time this VC pops into view
        //      and the difference in time is greater than 3 hours
        if
            lastViewDate != nil,
            TimesHelper.absHourDifference(date1: lastViewDate!, date2: Date()) > 3
        {
            // check if user is logged in
            
            if (networkService!.hasPreviousAuthentication()) {
                
                // User has been authenticated before, trying to restablish connection auth with Facebook log in
                
                networkService!.login(FacebookProvider, controller: self) { (isSuccesful) in
                    
                    LoadOverlay.endOverlay()
                    
                    if isSuccesful {
                        print("In BaseFormVC: auth was assured, Succesful Login! ")
                    }
                    else {
                        
                        // at this point, device says that user has been authorized before, but log in could not be established
                        // app will log user out and prompt user to try and log in later
                        // LAUNCH WELCOME SCREEN
                        
                        print("In BaseFormVC: auth was assured, but login failed")
                        
                        let failedLoginAlert = UIAlertController(title: "RM", message: "Connection to Facebook for logging in failed unexpectedly, please try again.", preferredStyle: .alert)
                        failedLoginAlert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
                            DispatchQueue.main.async(execute: {
                                
                                let onboardPresentation = AppOnboarding()
                                
                                onboardPresentation.onboardingViewController(skipAllowed: false, skipHandle: nil, logInHandle: {
                                    onboardPresentation.dismiss(animated: true, completion: nil)
                                    self.askForLogInAuthAndLoadData()
                                })
                                
                                self.present(onboardPresentation, animated: true, completion: nil)
                            })
                        })
                        
                        DispatchQueue.main.async(execute: {
                            self.present(failedLoginAlert, animated: true, completion: nil)
                        })
                    }
                }
            }
        }
        
        lastViewDate = Date() // Every time the view appears, the timestamp is reset
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View dissappeared")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navDotView.removeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navDotView.reappearView()
    }
    
    // MARK: - Load cell's embedded cells data
    
    // Posting NSNotification to load data inside of BriefCollectionView.swift
    private func loadCellDataViaNotification() {
        if !didLoadCellData {
            didLoadCellData = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: loadRoomsNotifKey), object: self, userInfo: nil)
        }
    }
    
    // MARK: - Notifications from briefCollectionView cells
    
    func openEditRoomVC(_ n:Notification) {
//        notifCellType:itemType])
        // This is a notification action to pass the room ID selected onto a view to edit that room
        
        if
            let itemID = n.userInfo![notifCellId] as? String,
            let cellType = n.userInfo![notifCellType] as? DisplayCellType
        {
            var segueStr = ""
            switch cellType {
            case .Room:
                segueStr = "SegueToEditRoom"
            case .Event:
                segueStr = "SegueToEditEvent"
            }
            // room Id is passed as the sender to be prepared and send in prepare(for segue:_) method
            self.performSegue(withIdentifier: segueStr, sender: itemID)
        }

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if
            let cellID = sender as? String,
            !cellID.isEmpty,
            let nav = segue.destination as? UINavigationController
        {
            
            if
                segue.identifier == "SegueToEditRoom",
                let nextVC = nav.topViewController as? EditRoomController
            {
                nextVC.ROOMID = cellID
            }
            
            if
                segue.identifier == "SegueToEditEvent",
                let nextVC = nav.topViewController as? EditEventController
            {
                nextVC.event.id = cellID
            }
            
        }
        
    }

    func askForLogInAuthAndLoadData() {
        
        LoadOverlay.showOverlayOverAppWindow()
        
        if !(networkService!.hasPreviousAuthentication()) {
            
            // User has not been previously authenticated
                // Ask user to log in to use app
            
            LoadOverlay.endOverlay()
            
            let onboardPresentation = AppOnboarding()
            
            onboardPresentation.onboardingViewController(skipAllowed: false, skipHandle: nil, logInHandle: {
                
                onboardPresentation.dismiss(animated: true, completion: nil)
                
                // Trying to log in with facebook. If user has previously logged in, the user will be re-logged in
                // if User has never been logged in, user will be prompted to the facebook log in screen
                self.networkService!.login(FacebookProvider, controller: self) { (isSuccesful) in
                    
                    if isSuccesful {
                        print("Succesful initial Login! DISPLAY CELLS")
                        self.loadCellDataViaNotification()
                    }
                    else {
                        print("initial login failed")
                        // RE-LAUNCH WELCOME SCREEN
                        
                        let failedLoginAlert = UIAlertController(title: "RM", message: "Log In failed unexpectedly, please try again.", preferredStyle: .alert)
                        
                        failedLoginAlert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
//                            DispatchQueue.main.async(execute: {
                                self.askForLogInAuthAndLoadData()
                                return
//                            })
                        })
                        
                        DispatchQueue.main.async(execute: { 
                            self.present(failedLoginAlert, animated: true, completion: nil)
                        })
                        
                    }
                }
                
            })
            
            self.present(onboardPresentation, animated: true, completion: nil)
            
        }
        else {
            
            // User has been authenticated before, trying to restablish connection auth with Facebook log in
            
            networkService!.login(FacebookProvider, controller: self) { (isSuccesful) in
                
                LoadOverlay.endOverlay()
                
                if isSuccesful {
                    print("auth was assured, Succesful Login! RELOAD DATA")
                    self.loadCellDataViaNotification()
                }
                else {
                    
                    // at this point, device says that user has been authorized before, but log in could not be established
                        // app will log user out and prompt user to try and log in later
                        // LAUNCH WELCOME SCREEN
                    
                    print("auth was assured, but login failed")
                    
//                    self.networkService?.logout({ (error) in
//                        print(error as Any)
//                        
//                        // FIXME: regardless if log out succeded, change/reload UI to non-logged in form and remove all data
//                        
//                    })
                    
                    let failedLoginAlert = UIAlertController(title: "RM", message: "Connection to Facebook failed unexpectedly, please try again.", preferredStyle: .alert)
                    
                    failedLoginAlert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in

                        LoadOverlay.endOverlay()
                        
                        let onboardPresentation = AppOnboarding()
                        
                        onboardPresentation.onboardingViewController(skipAllowed: false, skipHandle: nil, logInHandle: {
                            
                            onboardPresentation.dismiss(animated: true, completion: nil)
                            
                            self.askForLogInAuthAndLoadData()
                            return
                            
                        })
                        
                        self.present(onboardPresentation, animated: true, completion: nil)
                        
                    })
                    
                    DispatchQueue.main.async(execute: {
                        self.present(failedLoginAlert, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    // MARK: - Setup
    
    func setUpCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.invalidateLayout()
        
        topNavHeight = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        
        var fr = view.frame
        fr.origin.y = topNavHeight
        
        collectionView = UICollectionView(frame: fr, collectionViewLayout: layout)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        collectionView?.backgroundColor = Style.MainBackgroundColor
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
  
        collectionView?.register(briefCollectionView.classForKeyedArchiver, forCellWithReuseIdentifier: cellId)
        
//        collectionView?.registerClass(BriefCollectionView.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.isPagingEnabled = true
        
    }
    
    fileprivate func setUpNavBarAndDot() {
        let navBounds = (self.navigationController?.navigationBar.bounds)!
        
        // Adding Gradient
        
        let gradient = NavBarGradient(frame: navBounds)
        navigationController?.navigationBar.setTranslatesAutoresizingMaskIntoConstraintsFalse(titles)
        navigationController?.navigationBar.addSubview(titles)
        centerNavTitleAnchorConstraint = titles.centerXAnchor.constraint(equalTo: (navigationController?.navigationBar.centerXAnchor)!, constant: 1)
        centerNavTitleAnchorConstraint?.isActive = true
        titles.bottomAnchor.constraint(equalTo: (navigationController?.navigationBar.bottomAnchor)!).isActive = true
        titles.widthAnchor.constraint(equalTo: (navigationController?.navigationBar.widthAnchor)!, multiplier: 1).isActive = true
        titles.heightAnchor.constraint(equalTo: (navigationController?.navigationBar.heightAnchor)!).isActive = true
        
        navigationController?.navigationBar.addSubview(gradient)
        
        // Adding adjustable bracket
        
        navigationController?.navigationBar.setTranslatesAutoresizingMaskIntoConstraintsFalse(bracket)
        navigationController?.navigationBar.addSubview(bracket)
        
        widthNavBracketConstraint = bracket.widthAnchor.constraint(equalTo: titles.title1.widthAnchor, multiplier: 0.7, constant: 1)
        widthNavBracketConstraint?.isActive = true
        
        bracket.centerXAnchor.constraint(equalTo: (navigationController?.navigationBar.centerXAnchor)!).isActive = true
        bracket.bottomAnchor.constraint(equalTo: (navigationController?.navigationBar.bottomAnchor)!, constant: -7.5).isActive = true
        bracket.heightAnchor.constraint(equalTo: (navigationController?.navigationBar.heightAnchor)!, multiplier: 0.6).isActive = true
        
        navigationController?.navigationBar.addSubview(bracket)
        
        // Adding navigation dot (this is at the bottom of screen
        
        let appDelegate = AppDelegate.getAppDelegate() //UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.setTranslatesAutoresizingMaskIntoConstraintsFalse(navDotView)
        appDelegate.window?.addSubview(navDotView)
        
        let sideWidth = Int((AppSize.screenWidth - 25) / 2)
        
        
        // FIXME: Error. Might be given insets error
        appDelegate.window?.addConstraintsWithVisualFormat("H:|-\(sideWidth)-[v0]-\(sideWidth)-|", views: navDotView)
        appDelegate.window?.addConstraintsWithVisualFormat("V:[v0(10)]-10-|", views: navDotView)
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let sizeOfText = titles.txtBarSize
        
        let xOffSet = scrollView.contentOffset.x / (navigationController?.navigationBar.frame.size.width)!
        
        // For nav dots
        if xOffSet == 0.0 || xOffSet == 1.0 {
            navDotView.updateDot(forDotNumber: xOffSet)
        }
        
        // For adjustable brackets
        centerNavTitleAnchorConstraint?.constant = -xOffSet * CGFloat(sizeOfText) //* halfSizeOfTitle
        
        widthNavBracketConstraint?.constant = xOffSet * 37 // CGFloat(sizeOfText) + 4
    }
    
    func setUpNavBarButtons() {
        
        // Left bar button:
        let settingIconSize = CGFloat((navigationController?.navigationBar.frame.size.height)!) * 0.60
        
        let settingImg = UIImageView(frame: CGRect(x: 0, y: 0, width: settingIconSize, height: settingIconSize))
        settingImg.image = UIImage(named: "SettingsI8")
        // making image clickable:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.navSettingsAction))
        settingImg.addGestureRecognizer(tapGesture)
        settingImg.isUserInteractionEnabled = true
        
        settingNavButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.navSettingsAction))
        settingNavButton.customView = settingImg
        
        // Right bar buttons
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(self.navInfoAction), for: .touchUpInside)
        
        infoNavButton = UIBarButtonItem(customView: infoButton)
        
        addNavButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.navAddAction))
        
        navigationItem.leftBarButtonItem = settingNavButton
        navigationItem.rightBarButtonItems = [addNavButton, infoNavButton]
        
    }
    
    // MARK: - Navigation
    
    @IBAction func UnwindToHomeController(_ segue: UIStoryboardSegue) {}
    
    func navSettingsAction() {
        self.performSegue(withIdentifier: "SegueToSettingsVC", sender: self)
    }
    
    func navAddAction() {
        self.performSegue(withIdentifier: "SegueToAddRMVC", sender: self)
    }
    
    func navInfoAction() {
        let onboardPresentation = AppOnboarding()

        onboardPresentation.onboardingViewController(skipAllowed: true, skipHandle: { 
            onboardPresentation.dismiss(animated: true, completion: nil)
        }, logInHandle: nil)
        
        self.present(onboardPresentation, animated: true, completion: nil)
    }
    
    // MARK: - Collection View Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfScrollViews
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! BriefCollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - topNavHeight)
    }
    
    // MARK: - Collection View Delegate Methods
    // FIXME: Delegate method only works once when app is launched
    func didFailToLoadData(_ sender: BriefCollectionView) {
        
        var errorStr: String = ""
        
        switch sender.loadingRmsErr {
        case .none:
            return
        case .failedGettingLocation:
            errorStr = "Network Error."
        }
        
        let alert = UIAlertController(title: "RM", message: errorStr, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    func didSelectRoom(_ roomId: String) { }
    func didFailTorefreshData(_ sender: BriefCollectionView) {}
}

