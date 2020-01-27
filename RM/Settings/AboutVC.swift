//
//  AboutVC.swift
//  RM
//
//  Created by Luis Fernandez on 7/30/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka   // CocoaPod

class AboutVC: FormViewController {

    let cellContentWidth = 0.909 * AppSize.screenWidth
    
    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "About"
        
        // load a JSON holding all the web sites we need
        
        self.loadForm()
        
    }
    
    // MARK: Form
    
    func loadForm() {
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
        
        form =
            
            Section()
            
            <<< LabelRow () {
                $0.title = "Version"
                if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    $0.value = text
                }
            }

            +++ Section()
            
            <<< ButtonRow() {
                $0.title = "Like us on Facebook"
                }.cellUpdate({ (cell, row) in
                    cell.textLabel!.textColor = .black
                    cell.textLabel?.textAlignment = .left
                }).onCellSelection({ (cell, row) in
                    UIApplication.shared.openURL(URL(string: "https://www.facebook.com/pages/Apple-Inc/105596369475033")!)
                })
            
            <<< ButtonRow() {
                $0.title = "Rate us in the App Store"
            }.cellUpdate({ (cell, row) in
                cell.textLabel!.textColor = .black
                cell.textLabel?.textAlignment = .left
//                cell.accessoryType = .DisclosureIndicator
//                cell.editingAccessoryType = cell.accessoryType
            }).onCellSelection({ (cell, row) in
                UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/us/app/uber/id368677368")!)
            })
            
            <<< ButtonRow() {
                $0.title = "Official Website"
                }.cellUpdate({ (cell, row) in
                    cell.textLabel!.textColor = .black
                    cell.textLabel?.textAlignment = .left
                }).onCellSelection({ (cell, row) in
                    UIApplication.shared.openURL(URL(string: "http://findrm.com/")!)
                })
            
            +++ Section()
            
            <<< ButtonRow() {
                $0.title = "Terms of Service"
                let vC = WebVC()
                vC.setUp(navTitle: "Terms of Service", ViewURL: "https://www.google.com")
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { vC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
            }
        
 /*
        
            <<< ButtonRow() {
                $0.title = "Privacy Policy"
                $0.presentationMode = PresentationMode.Show(controllerProvider: ControllerProvider.Callback { WebVC()}, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) } )
            }
        
            <<< ButtonRow() {
                $0.title = "Lincenses"
                $0.presentationMode = PresentationMode.Show(controllerProvider: ControllerProvider.Callback { WebVC()}, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) } )
            }
        
            <<< ButtonRow() {
                $0.title = "Copyright"
                $0.presentationMode = PresentationMode.Show(controllerProvider: ControllerProvider.Callback { WebVC()}, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) } )
            }
 */
        
    }
    
    
}


class WebVC: UIViewController {
    
    fileprivate var navTitle = ""
    fileprivate var pageURL = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: 0, width: AppSize.screenWidth, height: AppSize.screenHeight)
        view.backgroundColor = Style.MainBackgroundColor
        
    }
    
    func setUp(navTitle nv: String, ViewURL link: String) {
        
        if let urlStr = link as String? {
            if let url = URL(string: urlStr) {
                let webView = UIWebView(frame: view.frame)
                
                UIWebView.loadRequest(webView)(URLRequest(url: url))
                
                view.addSubview(webView)
            }
        }
        
        setUpNavBar(nv)
    }
    
    fileprivate func setUpNavBar(_ title: String) {
        
        navigationItem.title = title
    }
    
}


