//
//  Address.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/9/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

class Address : NSObject {
    
    var street : String?
    var state : String?
    var zipCode : String?
    var city : String?
    var country : String?
    
    override init() {
        super.init()
    }

    init(street: String?, state: String?, zipCode: String?, city: String?, country: String?){
        self.street = street
        self.state = state
        self.zipCode = zipCode
        self.city = city
        self.country = country
    }
    
    /**
     Get the address of Person in U.S. postal format.
     
     - returns:
     Address formatted as: street, city, state, zip code, country
     
     - important:
     Will only return formatted address if address.street, address.city, address.state, address.zipCode, and address.country are specified for ths object. Else, this will return nil.
     */
    func getUSAddress() -> String? {
        if street != nil && state != nil && zipCode != nil && city != nil && country != nil {
            return String(street! + " " + city! + " " + state! + " " + zipCode! + " " + country!)
        }
        
        return nil
    }
    
}

class LongLatPoint: NSObject {
    
    var long: Int?
    var lat: Int?
    
    func sentValues(_ longitude: Int?, latitude: Int?) {
        long = longitude
        lat = latitude
    }
}

