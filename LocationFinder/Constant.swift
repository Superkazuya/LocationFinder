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
        static let TINT = UIColor.whiteColor()
        struct SEARCHBAR {
            static let TINT = UIColor.whiteColor()
            static let PLACEHOLDER_TEXTCOLOR = UIColor.grayColor()
            static let BG_COLOR = UIColor.blackColor()
        }
        
        struct TOPINFOBAR {
            static let ERROR_BG = SEARCHBAR.BG_COLOR
        }
        
        struct SLIDER {
            static let TINT = UIColor.blackColor()
        }
        
    }
    
    struct SEARCHBAR {
        static let PLACEHOLDER_TEXT = "Enter a place here, e.g. Cafe"
        static let PLACEHOLDER_ATTR_TEXT = NSAttributedString(string: CONSTANT.SEARCHBAR.PLACEHOLDER_TEXT, attributes: [NSForegroundColorAttributeName: COLOR_SCHEME.SEARCHBAR.PLACEHOLDER_TEXTCOLOR])
    }
    
    struct MAP {
        static let ANNOTATION_IDENTIFIER = "ANNOTATION"
        static let DEFAULT_MARGIN = MKCoordinateSpanMake(Meters2DegreeAprox(200), Meters2DegreeAprox(200))
        static let DEFAULT_SEARCH_REGION: Double = Meters2DegreeAprox(2000)
    }
    
    struct TABLEVIEW {
        static let MAX_HEIGHT:CGFloat = 200
        static let DEFAULT_HEIGHT: CGFloat = 200
        static let CELL_IDENTIFIER = "CELL"
    }
    
    struct SLIDER {
        static let TIP_ARROW_HALF_WIDTH: CGFloat = 4
        static let TIP_ARROW_HEIGHT: CGFloat = 4
        static let CORNER_RADIUS: CGFloat = 3
        
        static let TEXT_MARGIN: CGFloat = 6
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