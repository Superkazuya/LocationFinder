//
//  ExpandCollapseButton.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/21/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import UIKit

@IBDesignable class ExpandButton: UIButton {
    var isArrowUpward = false {
        didSet { setNeedsDisplay() }
    }

    func toggle() {
        isArrowUpward = !isArrowUpward
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if !isArrowUpward {
            let path = UIBezierPath(ovalInRect: rect)
            CONSTANT.COLOR_SCHEME.SEARCHBAR.TINT.setFill()
            path.fill()
        }
        
        let arrow = UIBezierPath()
        (isArrowUpward ? CONSTANT.COLOR_SCHEME.SEARCHBAR.TINT : CONSTANT.COLOR_SCHEME.SEARCHBAR.BG_COLOR).setStroke()
        arrow.lineWidth = 3
        
        let lowerY = rect.midY + (rect.maxY - rect.midY)/4
        let upperY = rect.midY - (rect.midY - rect.minY)/4
        let left = CGPoint(x: (rect.midX + rect.minX)/2, y: isArrowUpward ? lowerY : upperY)
        let right = CGPoint(x: (rect.midX + rect.maxX)/2, y: isArrowUpward ? lowerY : upperY)
        
        let arrowPoint = CGPoint(x: rect.midX, y:  isArrowUpward ? upperY : lowerY)
        arrow.moveToPoint(left)
        
        arrow.addLineToPoint(arrowPoint)
        arrow.addLineToPoint(right)
        arrow.stroke()
    }

}
