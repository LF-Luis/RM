//
//  LogInViewController.swift
//  RM
//
//  Created by Luis Fernandez on 7/27/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka

class LogInViewController: BaseFormVC, UITextViewDelegate {
    
    // UITextViewDelegate is used for hyperlink
    fileprivate var hyperTextView = UITextView()
    
    // View Controllers this controller open to
    fileprivate let addOneRoomController = AddOneRoomController()
    fileprivate let buildingTableVC = BuildingTableViewController()
    
    var table : MSSyncTable?
    var store : MSCoreDataStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hyperTextView.delegate = self
        setUpTextHyperlink()
        loadForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (networkService!.hasPreviousAuthentication()) {
            print("Has been previously authenticated")//, return to HomeVC")
//            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func testButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    let btn1: String = "Test: GET LIST OF TIME ID " //Update room information"
    let btn2: String = "Test: TRY TO GET TIMES FROM DELETED ROOM"
    let btn3: String = "Test: DELETE LIST OF TIMES"
    let btn4: String = "Test: DELETE ROOM"
    let btn5: String = "Test: Get Rooms"
    
    
    var _TEST_TIMES_ARRAY = [String]()
    
    func testbtn1() {
        
        DatabaseConnection.getAvailabeTimes(withRoomId: "c07a4577953644b9926d8c5f55f55490") { (result:[WeekDay : AvailableTimes]?, listOfTimes: [String]?) in
            if listOfTimes != nil {
                
                self._TEST_TIMES_ARRAY = listOfTimes!
                print("List of times")
                print(listOfTimes!)
            }
            else {
                print("COULD NOT GET TIMES FOR ROOM")
            }
        }
        
    }
    
    var count = 0
    
    func testbtn2() {
        
        let timesTable = MSTable(name: Entities.roomTime, client: MSClient(applicationURLString: ServiceUrl))
        
        for value in _TEST_TIMES_ARRAY {
        
            timesTable.read(withId: value, completion: { (results: [AnyHashable : Any]?, error: Error?) in
                if error == nil {

                    if let start = results![RoomTimeKeys.start] as? Double {
                        print("start: \(start)")
                    }
                    
                    if let end = results![RoomTimeKeys.end] as? Double {
                        print("start: \(end)")
                    }
                    
                }
                else {
                    print("Could not get times from time ID")
                }
            })
            
        }
        
    }
    
    func testbtn3() {

        let deleteList = [AnyHashable: Any]()
        
        for timeSet in _TEST_TIMES_ARRAY {
            DatabaseConnection.deleteItem(withId: timeSet, entity: Entities.roomTime, completion: { (isSuccessfull: Bool) in
                if isSuccessfull {
                    print("time deleteion completed succesfully")
                }
                else {
                    print("failed to delete times")
                }
            })
            
        }
        
    }
    
    func testbtn4() {
        
//        DatabaseConnection.deleteItems(items: ["id":"cbeaed9aa95b49caa483ba9a8fece1d2"], entity: Entities.room) { (success) in
//            if success {
//                print("SUCCESSFUL DELETION")
//            }
//            else {
//                print("deletion failed")
//            }
//        }
//        
        DatabaseConnection.deleteItem(withId: "c07a4577953644b9926d8c5f55f55490", entity: Entities.room) { (success) in
            if success {
                print("SUCCESSFUL DELETION")
            }
            else {
                print("deletion failed")
            }
        }
        
    }
    
    func testbtn5() {
        
//        let bld = Building()
//        DatabaseConnection.upsert(building: bld) { (error) in
//            print(error)
//        }
    }
    
    func logInWithFB() {
    
        networkService!.login(FacebookProvider, controller: self) { (isSuccesful) in
            if isSuccesful {
                print("Succesful Login!")
//                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                // FIXME: Deal with login failure
                print("login failed")
            }
        }
        
    }
    
    // MARK: - Set up methods
    
    fileprivate func setUpTextHyperlink() {
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let textAttributes = [
            NSLinkAttributeName: NSURL(string: "https://www.apple.com")!,
            NSForegroundColorAttributeName: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1),
            NSParagraphStyleAttributeName: style,
            NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)
            ] as [String: Any]
        
        let thankYouBlurb: String = "By adding a Room or Building, you will be contributing to the RM: Study community. Thank you."
        
        let attributedString = NSMutableAttributedString(string: thankYouBlurb)
        
        // done so that "Thank you." is clickable
        let stringCount: Int = thankYouBlurb.characters.count - 1
        let intial: Int = (stringCount - 10)
        attributedString.setAttributes(textAttributes, range: NSMakeRange(intial, 10))
        
        hyperTextView.isEditable = false
        hyperTextView.backgroundColor = Style.MainBackgroundColor
        hyperTextView.attributedText = attributedString
        
    }
    
    // MARK: - Form action methods
    
    fileprivate func openAddARoomVC() {
        self.navigationController?.pushViewController(addOneRoomController, animated: true)
    }
    
    fileprivate func openAddEditBuildingVC () {
        self.navigationController?.pushViewController(buildingTableVC, animated: true)
    }
    
    // MARK: - TextView Delegate Methods
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("Go to website!")
        return true
    }


    
    // MARK: Form
    
    var gg = AvailableTimesCollectionView()
    
    func loadForm() {
        
        form
            
            +++ Section()
            
            +++ Section() { $0.header = HeaderFooterView<WelcomeText>(HeaderFooterProvider.class) }
            
            +++ Section()
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "Sign In With Facebook" }  .onCellSelection({ (cell, row) in self.logInWithFB() })
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "TEST: Go Back" }  .onCellSelection({ (cell, row) in self.testButton() })

            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = btn1 }  .onCellSelection({ (cell, row) in self.testbtn1() })
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = btn2 }  .onCellSelection({ (cell, row) in self.testbtn2() })
        
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = btn3 }  .onCellSelection({ (cell, row) in self.testbtn3() })
        
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = btn4 }  .onCellSelection({ (cell, row) in self.testbtn4() })
        
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = btn5 }  .onCellSelection({ (cell, row) in self.testbtn5() })

            +++ Section("Add a room near you where students can study or relax.")
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Add a Room"
                }  .onCellSelection({ (cell, row) in
                    self.openAddARoomVC()
                })
            
            +++ Section("Add a building near you.")
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Add or Edit a Building"
                }  .onCellSelection({ (cell, row) in
                    self.openAddEditBuildingVC()
                })
            
            +++ Section() {
                var header = HeaderFooterView<UIView>(.class)
                header.onSetupView = { (view: UIView, section: Section) -> () in
                    view.frame = CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: 50)
                    self.hyperTextView.frame = view.frame
                    view.addSubview(self.hyperTextView)
                }
                $0.header = header
        }

        
    
    }
    
}

// Welcome Text
class WelcomeText: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let orText: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 16))
        orText.text = "To use our awesome app, please log in:"
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




















//class LogInViewController: BaseFormVC {
//    
//    var table : MSSyncTable?
//    var store : MSCoreDataStore?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let client = MSClient(applicationURLString: "https://<sensitive_url>.azurewebsites.net")
//        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//        self.store = MSCoreDataStore(managedObjectContext: managedObjectContext)
//        client.syncContext = MSSyncContext(delegate: nil, dataSource: self.store, callback: nil)
//        
//        self.table = client.syncTableWithName("Building")
//        
//        loadForm()
//    }
//    
//    
//    func testButton() {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func logInWithFB() {
//                
//        print("Should log in with FB")
//
//        let logInIsSuccesful = true
//
//        if logInIsSuccesful {
//
//        }
//
//        guard let client = self.table?.client where client.currentUser == nil else {
//            return
//        }
//
//        client.loginWithProvider("facebook", controller: self, animated: true) { (user, error) in
//            print(user)
//            print(error)
//        }
//
//    }
//    
//    // MARK: Form
//    
//    func loadForm() {
//        
//        form
//            
//            +++ Section()
//            
//            +++ Section() { $0.header = HeaderFooterView<WelcomeText>(HeaderFooterProvider.Class) }
//            
//            +++ Section()
//            
//            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "Sign In With Facebook" }  .onCellSelection({ (cell, row) in self.logInWithFB() })
//        
//            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "TEST: Go Back" }  .onCellSelection({ (cell, row) in self.testButton() })
//    
//    }
//    
//}
//
//// Welcome Text
//class WelcomeText: UIView {
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        let orText: UILabel = UILabel(frame: CGRectMake(0, 0, 320, 16))
//        orText.text = "To use our awesome app, please log in:"
//        orText.textAlignment = .Center
//        orText.font = UIFont.boldSystemFontOfSize(14)
//        orText.autoresizingMask = .FlexibleWidth
//        self.frame = CGRect(x: 0, y: 0, width: 320, height: 12)
//        orText.contentMode = .ScaleAspectFit
//        self.addSubview(orText)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
