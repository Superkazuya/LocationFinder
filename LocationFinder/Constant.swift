//
//  Constant.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/18/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import Foundation
import MapKit

struct CONSTANT {
    
    struct COLOR_SCHEME {
        struct SEARCHBAR {
            static let TINT = UIColor.whiteColor()
            static let PLACEHOLDER_TEXTCOLOR = UIColor.grayColor()
            static let BG_COLOR = UIColor.blackColor()
        }
        
        struct TOPINFOBAR {
            static let ERROR_BG = SEARCHBAR.BG_COLOR
        }
    }
    
    struct SEARCHBAR {
        static let PLACEHOLDER_TEXT = "Enter a place here, e.g. Cafe"
        static let PLACEHOLDER_ATTR_TEXT = NSAttributedString(string: CONSTANT.SEARCHBAR.PLACEHOLDER_TEXT, attributes: [NSForegroundColorAttributeName: COLOR_SCHEME.SEARCHBAR.PLACEHOLDER_TEXTCOLOR])
    }
    
    struct MAP {
        static let ANNOTATION_IDENTIFIER = "ANNOTATION"
        static let DEFAULT_MARGIN = MKCoordinateSpanMake(Meters2DegreeAprox(200), Meters2DegreeAprox(200))
    }
    
    struct TABLEVIEW {
        static let MAX_HEIGHT:CGFloat = 200
        static let CELL_IDENTIFIER = "CELL"
    }
    
}

//MARK: Helpers
func Degree2MetersAprox(degree: CLLocationDegrees) -> CLLocationDistance
{
    return degree * 111_000
}

func Meters2DegreeAprox(distance: CLLocationDistance) -> CLLocationDegrees
{
    return distance / 111_000
}