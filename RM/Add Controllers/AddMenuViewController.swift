//
//  AddMenuViewController.swift
//  RM
//
//  Created by Luis Fernandez on 6/12/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//


import Foundation
import UIKit
import Eureka

class AddMenuViewController: FormViewController, UITextViewDelegate{
    
    // UITextViewDelegate is used for hyperlink
    fileprivate var hyperTextView = UITextView()
    
    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hyperTextView.delegate = self
        setUpNavBar()
        setUpTextHyperlink()
        loadForm()
        
    }
    
    // MARK: - Set up methods
    
    func setUpNavBar() {
        navigationItem.title = "Add To RM"
        
        // Nav bar cancel button
        let navDoneButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelNavBarAction))
        navigationItem.rightBarButtonItem = navDoneButton
        let attributes = [ NSForegroundColorAttributeName : UIColor.red]
        navDoneButton.setTitleTextAttributes(attributes, for: UIControlState())
    }

    @objc fileprivate func cancelNavBarAction() {
        performSegue(withIdentifier: "UnwindToHomeController", sender: self)
    }
    
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
        let addOneRoomController = AddOneRoomController()
        self.navigationController?.pushViewController(addOneRoomController, animated: true)
    }
    
    fileprivate func openAddEventVC () {
        let addEventVC = AddEventVC()
        self.navigationController?.pushViewController(addEventVC, animated: true)
    }
    
    // MARK: - TextView Delegate Methods
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
    
    // MARK: - Form
    
    func loadForm() {
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form
            
            +++ Section()
            +++ Section()
            
            +++ Section("Add a room near you where students can study or relax.")
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Add a Room"
                }  .onCellSelection({ (cell, row) in
                    self.openAddARoomVC()
                })
            
            +++ Section("Add an EVENT that students like you would love to attend, but have no idea about it yet.")
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Add Event"
                }  .onCellSelection({ (cell, row) in
                    self.openAddEventVC()
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

