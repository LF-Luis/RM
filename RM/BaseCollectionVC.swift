//
//  BaseCollectionVC.swift
//  RM
//
//  Created by Luis Fernandez on 6/15/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation

class BaseCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var networkService: NetworkProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkService = NetworkService()
    }
    
    func handleNetworkCallError(_ error : NSError) -> Void {
        ViewControllerShared.handleNetworkCallError(error, networkService: networkService!, viewController: self)
    }
    
}
