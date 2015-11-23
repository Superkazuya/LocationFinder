//
//  AnnotationView.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/21/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import UIKit
import MapKit

class AnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 18, height: 40)
        opaque = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let radius = rect.width / 2
        let arc = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: 0, endAngle: CGFloat(M_PI), clockwise: false)
        arc.addLineToPoint(CGPoint(x: rect.midX, y: rect.maxY))
        UIColor.blackColor().setFill()
        arc.fill()
        
    }

}
