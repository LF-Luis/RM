//
//  InterAppNotificationKeys.swift
//  RM
//
//  Created by Luis Fernandez on 7/8/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import Foundation

// DO NOT ERASE
// These keys are used within this App to kick-off various events useing NSNotificationCenter

// Keys for Notification posted in: BriefCollectionView
let briefCollectionViewNotifKey = "briefCollectionViewNotifKey"
    // Subscribed by:
        // HomeControler
let notifCellId = "notifCellId"     // Used as key for briefCollectionViewNotifKey notification
let notifCellType = "notifCellType"

// Keys for Notification posted in: HomeControler
let loadRoomsNotifKey = "loadRoomsNotifKey"
    // Subscribed by:
        // BriefCollectionView

// Subscribed by: HomeControler
let logInScreenNotifKey = "logInScreenNotifKey"
    // posted by anyone who wants log in onboarding to be presented
