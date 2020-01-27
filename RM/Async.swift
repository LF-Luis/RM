//
//  Async.swift
//  MobileTasks.iOS
//
//  Created by kevin Ford on 3/30/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

typealias ServiceResponse = (NSError?) -> Void
//typealias TaskResponse = (Array<MobileTask>?, NSError?) -> Void
//typealias TaskSaveResponse = (MobileTask?, NSError?) -> Void

typealias ModelResponse = (NSError?) -> Void
typealias ModelSaveResponse = (NSError?) -> Void

// For now let's not pass the error, let's just pass whether the action was succesful or not 
typealias IsSuccesful = (_ isSuccesful: Bool) -> Void
