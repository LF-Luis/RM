//
//  Style.swift
//  Project-EmptyRoom
//
//  Created by Luis Fernandez on 7/10/16.
//  Copyright © 2016 Luis Fernandez. All rights reserved.
//

import UIKit

struct Style {
    static let MainColor = UIColor.red  //rgb(171, green: 176, blue: 156)
    static let MainBackgroundColor = UIColor.rgb(239, green: 240, blue: 245)
    static let OverLayColor = UIColor.black
    static let PlaceHolderColor_1 = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.7)
}

struct CellStyle {
    static let BriefCellHeight = CGFloat(100)
    static let BCDividerColor = UIColor.rgb(122, green: 122, blue: 122)
    
    static let TCBackgroundColor = UIColor.rgb(201, green: 224, blue: 245)
    static let TCBorderColor = UIColor.rgb(131, green: 137, blue: 143)
}

struct AppSize {
    static let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.size.height
}

struct DefaultValues {
    static let defaultRoomIconId = "defaultRoomIconId"
}
