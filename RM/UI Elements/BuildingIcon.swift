//
//  Icon.swift
//  RM
//
//  Created by Luis Fernandez on 8/17/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import Foundation

class BuildingIcon {
    
    static fileprivate let AllIconsAsImgViews = [ UIImage(named: apartments)!, UIImage(named: bank)!, UIImage(named: castle)!, UIImage(named: church)!, UIImage(named: church2)!, UIImage(named: church3)!, UIImage(named: circus)!, UIImage(named: city)!, UIImage(named: construction)!, UIImage(named: factory)!, UIImage(named: hospital)!, UIImage(named: hotel)!, UIImage(named: house)!, UIImage(named: house2)!, UIImage(named: house3)!, UIImage(named: market)!, UIImage(named: monuments)!, UIImage(named: officeblock)!, UIImage(named: officeblock2)!, UIImage(named: school)!, UIImage(named: skyscraper)!, UIImage(named: skyscraper2)!, UIImage(named: townhouse)!, UIImage(named: truck)! ]
    
    class func getIconsAsImgViews() -> [UIImageView] {
        
        var imgViewArr = [UIImageView]()
        
        for img in AllIconsAsImgViews {
            let t = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            t.image = img
            imgViewArr.append(t)
        }
        
        return imgViewArr
        
    }
    
//        static let AllIconsAsImages = [ UIImage(named: BuildingIcon.apartments), UIImage(named: BuildingIcon.bank), UIImage(named: BuildingIcon.castle), UIImage(named: BuildingIcon.church), UIImage(named: BuildingIcon.church2), UIImage(named: BuildingIcon.church3), UIImage(named: BuildingIcon.circus), UIImage(named: BuildingIcon.city), UIImage(named: BuildingIcon.construction), UIImage(named: BuildingIcon.factory), UIImage(named: BuildingIcon.hospital), UIImage(named: BuildingIcon.hotel), UIImage(named: BuildingIcon.house), UIImage(named: BuildingIcon.house2), UIImage(named: BuildingIcon.house3), UIImage(named: BuildingIcon.market), UIImage(named: BuildingIcon.monuments), UIImage(named: BuildingIcon.officeblock), UIImage(named: BuildingIcon.officeblock2), UIImage(named: BuildingIcon.school), UIImage(named: BuildingIcon.skyscraper), UIImage(named: BuildingIcon.skyscraper2), UIImage(named: BuildingIcon.townhouse), UIImage(named: BuildingIcon.truck) ]
    
    static let apartments = "apartments.png"
    static let bank = "bank.png"
    static let castle = "castle.png"
    static let church = "church.png"
    static let church2 = "church2.png"
    static let church3 = "church3.png"
    static let circus = "circus.png"
    static let city = "city.png"
    static let construction = "construction.png"
    static let factory = "factory.png"
    static let hospital = "hospital.png"
    static let hotel = "hotel.png"
    static let house = "house.png"
    static let house2 = "house2.png"
    static let house3 = "house3.png"
    static let market = "market.png"
    static let monuments = "monuments.png"
    static let officeblock = "officeblock.png"
    static let officeblock2 = "officeblock2.png"
    static let school = "school.png"
    static let skyscraper = "skyscraper.png"
    static let skyscraper2 = "skyscraper2.png"
    static let townhouse = "townhouse.png"
    static let truck = "truck.png"
}
