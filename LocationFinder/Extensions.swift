//
//  UIColorExtension.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/24/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    static func imageFromColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension String {
    func strip() -> String
    {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}