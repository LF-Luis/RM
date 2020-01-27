//
//  AddTimeController.swift
//  RM
//
//  Created by Luis Fernandez on 8/1/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//


import UIKit
import Eureka

protocol AddTimesDelegate: class {
    func saveTimesForRoom(_ sender: AddTimeController)
}

class AddTimeController: UIViewController, AddTimesSectionDelegate {
    
    // NOTE: When saving times, roomTime object must have:
    //        var roomId = ""
    //        var weekDay = ""
    //        var start: Float = 0.0
    //        var end: Float = 0.0
    
    var roomTime = RoomTime()
    var avTimes = [WeekDay: AvailableTimes]()
    
    // If this is true, it means that this controller is being used to edit times, i.e.: this room already has times, User is adding and deleting times
    fileprivate var isEditingTimes: Bool = false
    fileprivate var listOfTimesId:  [String]?   // used for storing the id of the old times, to be delted if new times are added
    
    weak var delegate: AddTimesDelegate?
    
    let weekDays = [WeekDay.sunday, WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]
    
    // Setting inital values of view controller
    
    lazy var navHeight: CGFloat = CGFloat(UIApplication.shared.statusBarFrame.size.height) + CGFloat((self.navigationController?.navigationBar.frame.size.height)!)
    
    lazy var timesViewController: AvailableTimesCollectionView = {
        let t = AvailableTimesCollectionView(collectionViewLayout: UICollectionViewFlowLayout())
        t.view.backgroundColor = UIColor.red
        t.adjustTotalHeight = self.navHeight * -1
        self.addChildViewController(t)
        t.didMove(toParentViewController: self)
        return t
    }()
    
    lazy var addFormController: AddTimesSection = {
        let t = AddTimesSection()
        t.delegate = self
        self.addChildViewController(t)
        t.didMove(toParentViewController: self)
        return t
    }()
    
    // MARK: Initializing View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpViews()
    }
    
    init(loadBackEndTimes loadTimes: Bool, withRoomId rmID: String?) {
        super.init(nibName: nil, bundle: nil)

        if rmID != nil {
            roomTime.roomId = rmID!
        }
        
        if loadTimes {
            isEditingTimes = true
            getTimesFromBackEnd()
        }
        
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // MARK: Navigation bar set-up
    
    fileprivate func setUpNavBar(){
        navigationItem.title = "Availability"
    }
    
    // MARK: Set Up Views
    
    fileprivate func getTimesFromBackEnd() {
        DatabaseConnection.getAvailabeTimes(withRoomId: roomTime.roomId) { (avTimes :[WeekDay : AvailableTimes]?, listOfId: [String]?) in
            
            if
                avTimes != nil,
                listOfId != nil
            {
                self.avTimes = avTimes!
                var t = [AvailableTimes]()
                
//                self.timesViewController.cellData = t
//                
//                self.timesViewController.collectionView?.reloadData()

                for day in self.weekDays {
                    t.append((avTimes?[day])!)
                }
                
                self.timesViewController.cellData = t
                self.timesViewController.collectionView?.reloadData()
                self.listOfTimesId = listOfId!
            }
            else {
            
            }
        }
    }
    
    fileprivate func setUpViews() {
        
        timesViewController = AvailableTimesCollectionView(collectionViewLayout: UICollectionViewFlowLayout())
        timesViewController.adjustTotalHeight = self.navHeight * -1
        self.addChildViewController(timesViewController)
        timesViewController.didMove(toParentViewController: self)
        
        let formView = addFormController.view!
        view.backgroundColor = Style.MainBackgroundColor
        view.addMultipleSubviews(timesViewController.view!, formView)
        view.setTranslatesAutoresizingMaskIntoConstraintsFalse(timesViewController.view!, formView)
        
        // Set up data
        // Filling up the avTimes object, which will be used to add/delete/change/order times
        let weekDays = [WeekDay.sunday, WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]
        let day = ["S", "M", "T", "W", "T", "F", "S"]
        for i in 0...day.count - 1 {
            let dayTime = AvailableTimes()
            dayTime.dayChar = day[i]
            timesViewController.cellData.append(dayTime)    // FIXME: Needs to initiate with data from server
            avTimes[weekDays[i]] = dayTime
        }
        
        timesViewController.collectionView?.reloadData()

        view.addConstraintsWithVisualFormat("H:|[v0]|", views: timesViewController.view!)
        view.addConstraintsWithVisualFormat("H:|[v0]|", views: formView)
        view.addConstraintsWithVisualFormat("V:|[v0(240)][v1]|", views: timesViewController.view!, formView)
    }
    
    fileprivate func getEmptySetupAvailableTimes() -> AvailableTimes {
        // Set up data
        // Filling up the avTimes object, which will be used to add/delete/change/order times
        let weekDays = [WeekDay.sunday, WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]
        let day = ["S", "M", "T", "W", "T", "F", "S"]
        let dayTime = AvailableTimes()
        for i in 0...day.count - 1 {
            dayTime.dayChar = day[i]
            timesViewController.cellData.append(dayTime)    // FIXME: Needs to initiate with data from server
            avTimes[weekDays[i]] = dayTime
        }
        return dayTime
    }
    

    // MARK: AddTimesSectionDelegate methods
    func didAddTime(_ sender: AddTimesSection) {
        print(sender.days)  // type [WeekDay]()
        print(sender.timeInterval)
        
        let timeInterval: TimeSet = sender.timeInterval
        var errorStr = ""
        
        var shouldExitLoop = false
        var shouldAskToOverrideTimes = false
        
        for day in sender.days {
            
            if shouldExitLoop { break }
            
//            avTimes[day]?.append(rawTimes: [timeInterval], overrideOverlappingTimes: true)
            
            // Times that are overlapping existing times will replace existing times. Later, User will be asked if they want to keep those changes.
            avTimes[day]?.append(rawTimes: [timeInterval], overrideOverlappingTimes: true, completion: { (aTCompletion) in
                
                if aTCompletion.isSuccessful {
                    self.avTimes[day]?.dayOfWeek = day      // Setting day object, after succesfully setting time
                }
                else {
                    
                    switch aTCompletion.timeAppendError! {
                    case .none:
                        errorStr = "No Error."
                    case .networkConnectionFailed:
                        errorStr = "Network Error."
                    case .timeSetExists:
                        errorStr = "Time interval already exist or is being overlapped."
                        
                        // Override times
                        shouldAskToOverrideTimes = true
                        
                    case .timeSetReversed:
                        errorStr = "Check the formatting of time interval."
                         
                        // Time input is wrongly formatted. Proccess will stop, time will not be added, user will be notified
                        shouldExitLoop = true
                        
                    case .noTimeSetWasAdded:
                        errorStr = "No time was defined."
                        
                    }
                }
            })
        }
        
        // Error alert (errors being taken care of are: wrongly formatted times)
        if shouldExitLoop {
            
            let alert = UIAlertController(title: "RM", message: errorStr, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Try Again", style: .default) { (action) in })
            
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
            
            return
        
        }
        
        //------------
        if shouldAskToOverrideTimes {
            
            // Creating error message:
            var timeOverrideMsg_Full: String = ""
            let timeOverrideMsg_Time: String = TimesHelper.formattedTime(start: timeInterval.s, end: timeInterval.e)
            
            for day in weekDays {
                if sender.days.contains(day) {
                    timeOverrideMsg_Full = timeOverrideMsg_Full + String(describing: day) + ": " + timeOverrideMsg_Time + "\n"
                }
            }
            
            let alert = UIAlertController(title: "Override Times", message: "By adding\n" + timeOverrideMsg_Full + "you will replace some existing times.", preferredStyle: .alert)
            
            // no -> take no action, empty temprrary memory:
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                return
            })

            // yes -> override:
            alert.addAction(UIAlertAction(title: "Replace", style: .default) { (action) in
                var t = [AvailableTimes]()
                
                for day in self.weekDays {
                    t.append(self.avTimes[day]!)
                }
                
                self.timesViewController.cellData = t
                
                self.timesViewController.collectionView?.reloadData()
            })
            
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
            
            return
            
        }
        
        var trr = [AvailableTimes]()
        trr.removeAll()
        timesViewController.cellData = trr
        
        timesViewController.collectionView?.reloadData()
        timesViewController.collectionViewLayout.invalidateLayout()
        
        for day in weekDays {
            trr.append(avTimes[day]!)
        }
        
        timesViewController.cellData = trr
        timesViewController.collectionView?.reloadData()
        timesViewController.collectionViewLayout.invalidateLayout()
        
    }
    
    func didCLickTestBtn(_ sender: AddTimesSection) {
        
        // Currently, this test button should clear out all times
        let t = [AvailableTimes]()
        
        timesViewController.cellData = t
        
        timesViewController.collectionView?.reloadData()
    }
    
    func shouldSaveTimes(_ sender: AddTimesSection) {
        
        /*
         if isEditingTimes
         old times and new current times are locally stored
         remove all old times from back-end
         add old times and new current times to backend
         else
         add times to backend
         */
        
        if
            isEditingTimes,
            listOfTimesId != nil
        {
            
            let group = DispatchGroup()
            
            for timeId in listOfTimesId! {
                group.enter()
                DatabaseConnection.deleteItem(withId: timeId, entity: Entities.roomTime, completion: { (isSuccesful: Bool) in
                    group.leave()
                })
            }
            
            
            
            group.notify(queue: .main) {
                self.saveTimesToBackend()   // Save times to back end
            }
            
        }
        else {
            self.saveTimesToBackend()   // Save times to back end
        }
    }
    
    fileprivate func saveTimesToBackend() {
        
        // Save hours added into room instance into backend table
        
        // This variable will serve as a limit (the limit is set by the number of time sets being added) that once reached will exit this view and view controller and move back to the home view controller.
        var limitToExitView = 0
        
        let asyncGroup = DispatchGroup()
        
        LoadOverlay.showOverlay(forView: self.view)
//        
//        if !avTimes.isEmpty {
//            
//            for day in self.weekDays {
//                if let timeArray = avTimes[day]?.rawTimes  {
//                    if timeArray.isEmpty { continue }
//                    for _ in timeArray {
//                        limitToExitView += 1
//                    }
//                }
//            }
//            
//        }
//        else {
//            print("Please add hours for this room")
//            LoadOverlay.endOverlay()
//            return
//            // FIXME: Offer a cancel button
//            // if cancel:
//            // Delete room (using room id)
//            // Return to home controller
//        }
//        
//        var index = 1
//        
        // Upserting multiple raw times to backend tables
        for day in self.weekDays {
            if let timeArray = avTimes[day]?.rawTimes  {        // var avTimes = [WeekDay: AvailableTimes]()
                
                for time in timeArray {
                    let tempRMTime = RoomTime()
                    tempRMTime.roomId = roomTime.roomId
                    tempRMTime.weekDay = TimesHelper.stringDay(fromWeekDay: day)
                    tempRMTime.start = time.1.s
                    tempRMTime.end = time.1.e
                    
                    asyncGroup.enter()
                    
                    DatabaseConnection.upsert(time: tempRMTime) { (error) in
                        
                        if error != nil {
                            print(error)
                        }
                        
                        asyncGroup.leave()
                        
//                        if index == limitToExitView {
//                            // Once this limit is reached it means that all raw-times that needed to be upserted were upserted
//                            DispatchQueue.main.async(execute: {
//                                LoadOverlay.endOverlay()
//                                
//                                // if User is editing times, once User is done editing, pop controller back
//                                if self.isEditingTimes {
//                                    self.navigationController?.popViewController(animated: true)
//                                }
//                                else {
//                                    self.dismiss(animated: true, completion: nil)
//                                }
//                            })
//                        }
//                        
//                        index += 1
                        
                    }
                    
                }
            }
        }
        
        asyncGroup.notify(queue: .main) {
            
            self.delegate?.saveTimesForRoom(self)
            
            LoadOverlay.endOverlay()
            
            // if User is editing times, once User is done editing, pop controller back
            if self.isEditingTimes {
                self.navigationController?.popViewController(animated: true)
            }
            else {   // User is adding times to a new room. Once done, exit to home view
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }

    
    
    //END
}






































// MARK: - Add Times Form

protocol AddTimesSectionDelegate: class {
    func didAddTime(_ sender: AddTimesSection)
    func shouldSaveTimes(_ sender: AddTimesSection)
    func didCLickTestBtn(_ sender: AddTimesSection)
}

class AddTimesSection: FormViewController {
    
    var days = [WeekDay]()
//    lazy
    var timeInterval = TimeSet(s: 0, e: 0)
    
    weak var delegate: AddTimesSectionDelegate?
    
    // This is use to get _hours per day_ out of the form
    fileprivate let weekDays = [WeekDay.sunday, WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]
    
    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    
    // Form keys
    let daysKey: String = "k1"
    let startTime: String = "t1"
    let endTime: String = "t2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadForm()
    }
    
    // MSF: Minute Second Fromatt, which is in float formatt (i.e.: 1:30 PM is 13.5)
    fileprivate func getMSFFromDate(date d: Date) -> Float {
    
        let components: DateComponents = (Calendar.current as NSCalendar).components([.minute, .hour], from: d)
        let min: Int = components.minute!
        let hr: Int = components.hour!
        let timeFtt: Float = Float(hr) + (Float(min) / 60)
        
        return timeFtt
    }
    
    fileprivate func addTimes() {
        
        // check if Start Time is equal to or greater than end time
        // check if any WeekDays were selected
        
        let formValues = form.values()
        print(formValues)
        
        if let formDays = formValues[daysKey] as? Set<WeekDay> {
            for day in formDays {
                days.append(day)
            }
        }
        
        // Setting values of days and hours picked
//        days.append(contentsOf: Array(formValues[daysKey] as! Set<WeekDay>))
        
        timeInterval = TimeSet(s: getMSFFromDate(date: formValues[startTime] as! Date), e: getMSFFromDate(date: formValues[endTime] as! Date))
        
        delegate?.didAddTime(self)
        
        // Setting values back to empty
        days = [WeekDay]()
        timeInterval = TimeSet(s: 0, e: 0)
        
    }
    
    func saveTimes() {
        delegate?.shouldSaveTimes(self)
    }
    
    func testBtn() {
        delegate?.didCLickTestBtn(self)
    }
    
    // MARK: Form
    
    func loadForm() {
        
        // Date that will be displayed in date pickerstart time
        let calendar = Calendar.current
        var components: DateComponents = (calendar as NSCalendar).components([.minute, .hour], from: Date())
        components.minute = (((components.minute! - 8) / 15) * 15) + 15
        let startDefaultTime: Date = (calendar.date(from: components))!
        
        let _calendar = Calendar.current
        var _components: DateComponents = (_calendar as NSCalendar).components([.minute, .hour], from: Date())
        _components.minute = (((_components.minute! - 8) / 15) * 15) + 30
        let endDefaultTime: Date = (_calendar.date(from: _components))!
        
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        form.inlineRowHideOptions = form.inlineRowHideOptions?.union(.AnotherInlineRowIsShown)
        form.inlineRowHideOptions = form.inlineRowHideOptions?.union(.FirstResponderChanges)
        
        form =
        
            Section()
            
            <<< WeekDayRow(daysKey){
                $0.value = [.monday, .wednesday, .friday]
            }
            
            <<< TimeInlineRow(startTime){
                $0.title = "Start Time"
                $0.value = startDefaultTime
                $0.minuteInterval = 15
            }
        
            <<< TimeInlineRow(endTime){
                $0.title = "End Time"
                $0.value = endDefaultTime
                $0.minuteInterval = 15
            }
        
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Add Availability"
                }  .onCellSelection({ (cell, row) in
                    self.addTimes()
                })
            
//            <<< ButtonRow() { (row: ButtonRow) -> Void in
//                row.title = "Test_Button"
//                }  .onCellSelection({ (cell, row) in
//                    self.testBtn()
//                })
            
            +++ Section() {
                var header = HeaderFooterView<UIButton>(.class)
                header.onSetupView = { (view: UIButton, section: Section) -> () in
                    view.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), for: [])
                    view.setTitle("Save", for: [])
                    view.addTarget(self, action: (#selector(self.saveTimes)), for: UIControlEvents.touchUpInside)
                }
                $0.header = header
            }
    }
    
}
