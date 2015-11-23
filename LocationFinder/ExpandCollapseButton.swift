//
//  ExpandCollapseButton.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/21/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import UIKit

@IBDesignable class ExpandButton: UIButton {
    enum Status { case Expanded, Folded }
    var status = Status.Expanded {
        didSet { setNeedsDisplay() }
    }

    func toggle() {
        status = status == .Expanded ? .Folded : .Expanded
    }
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let isUpwards = status == .Folded
        if !isUpwards {
            let path = UIBezierPath(ovalInRect: rect)
            CONSTANT.COLOR_SCHEME.SEARCHBAR.TINT.setFill()
            path.fill()
        }
        
        let arrow = UIBezierPath()
        (isUpwards ? CONSTANT.COLOR_SCHEME.SEARCHBAR.TINT : CONSTANT.COLOR_SCHEME.SEARCHBAR.BG_COLOR).setStroke()
        arrow.lineWidth = 3
        
        let lowerY = rect.midY + (rect.maxY - rect.midY)/4
        let upperY = rect.midY - (rect.midY - rect.minY)/4
        let left = CGPoint(x: (rect.midX + rect.minX)/2, y: isUpwards ? lowerY : upperY)
        let right = CGPoint(x: (rect.midX + rect.maxX)/2, y: isUpwards ? lowerY : upperY)
        
        let arrowPoint = CGPoint(x: rect.midX, y:  isUpwards ? upperY : lowerY)
        arrow.moveToPoint(left)
        
        arrow.addLineToPoint(arrowPoint)
        arrow.addLineToPoint(right)
        arrow.stroke()
    }

}
