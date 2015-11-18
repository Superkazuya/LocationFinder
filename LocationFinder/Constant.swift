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
        }
        
        struct TOPINFOBAR {
            static let ERROR_BG = UIColor.blackColor()
        }
    }
    
    struct SEARCHBAR {
        static let PLACEHOLDER_TEXT = "Enter a place here, e.g. Cafe"
    }
    
    struct MAP {
        static let ANNOTATION_IDENTIFIER = "ANNOTATION"
        static let DEFAULT_MARGIN = MKCoordinateSpanMake(Meters2DegreeAprox(200), Meters2DegreeAprox(200))
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