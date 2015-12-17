//
//  UIValueSlider.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/25/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import UIKit

@IBDesignable class UIValueSlider: UIControl {

    let trackLayer = CALayer()
    let thumbLayer = ThumbView()
    
    var minimumValue: CGFloat = 0
    var maximumValue: CGFloat = 10
    
    var thumbXOffsetConstraint: NSLayoutConstraint!
    
    var value: CGFloat {
        get {
            return (maximumValue - minimumValue)/(bounds.width - thumbLayer.frame.width)*(thumbLayer.frame.minX - bounds.minX)
        }
        set {
            let validValue = max(minimumValue, min(maximumValue, newValue))
            //guard validValue != value else { return }
            thumbLayer.frame.origin.x = (validValue-minimumValue)/(maximumValue - minimumValue)*(bounds.width - thumbLayer.frame.width) + bounds.minX
            
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupLayers()
    }
    
    private func setup()
    {
        //layer.backgroundColor = UIColor.clearColor().CGColor
        layer.addSublayer(trackLayer)
        addSubview(thumbLayer)
        thumbLayer.userInteractionEnabled = false
    }
    
    func setupLayers()
    {
        let trackHeight = CGFloat(2)
        let thumbHeight = CGFloat(6)
        let thumbWidth = CGFloat(16)
        trackLayer.frame = CGRect(x: bounds.minX + thumbWidth/2, y: bounds.midY - trackHeight/2, width: bounds.width - thumbWidth, height: trackHeight)
        
        trackLayer.backgroundColor = UIColor.blackColor().CGColor
        
        //thumbLayer.frame = CGRect(x: bounds.minX, y: bounds.midY - thumbHeight/2, width: thumbWidth, height: thumbHeight)
        thumbXOffsetConstraint = thumbLayer.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 0)
        thumbXOffsetConstraint.active = true
        
        thumbLayer.topAnchor.constraintEqualToAnchor(centerYAnchor, constant: thumbHeight/2).active = true
        
        //thumbLayer.backgroundColor = UIColor.blackColor()
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if thumbLayer.frame.contains(touch.locationInView(self)) {
            thumbLayer.selected = true
        }
        return thumbLayer.selected
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let newLoc = touch.locationInView(self)
        
        if newLoc.x >= bounds.minX && newLoc.x <= bounds.maxX && thumbLayer.selected {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            thumbXOffsetConstraint.constant = newLoc.x
            layoutIfNeeded()
            CATransaction.commit()
        }
        
        return thumbLayer.selected
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        thumbLayer.selected = false
    }

}

class ThumbView: UIView {
    
    var selected = false
    var textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        backgroundColor = UIColor.clearColor()
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = UIColor.whiteColor()
        textLabel.text = "0 M"
        textLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 8).active = true
        textLabel.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant:  -8).active = true
        textLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: 8+CONSTANT.SLIDER.TIP_ARROW_HEIGHT).active = true
        textLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -8).active = true
    }
    
    override func drawRect(rect: CGRect) {
        let path = outerBounds(rect)
        //CONSTANT.COLOR_SCHEME.TINT.setFill()
        UIColor.blackColor().setFill()
        path.fill()
    }
    
    func outerBounds(bound: CGRect) -> UIBezierPath
    {
        let cornerRadius = CONSTANT.SLIDER.CORNER_RADIUS
        guard bound.width-2*cornerRadius > 0 else { return UIBezierPath(roundedRect: bound, cornerRadius: cornerRadius)}
        
        var contentRect = bound
        contentRect.origin.y += CONSTANT.SLIDER.TIP_ARROW_HEIGHT
        contentRect.size.height -= CONSTANT.SLIDER.TIP_ARROW_HEIGHT
        let path = UIBezierPath(roundedRect: contentRect, cornerRadius: CONSTANT.SLIDER.CORNER_RADIUS)
        
        let arrowHalfWidth = CONSTANT.SLIDER.TIP_ARROW_HALF_WIDTH
        
        let arrowLeftX = max(contentRect.minX+cornerRadius, contentRect.midX-arrowHalfWidth)
        let arrowRightX = contentRect.midX*2 - arrowLeftX
        
        let arrowPath = UIBezierPath()
        arrowPath.moveToPoint(CGPoint(x: contentRect.midX, y: bounds.minY))
        arrowPath.addLineToPoint(CGPoint(x: arrowLeftX, y: contentRect.minY))
        arrowPath.addLineToPoint(CGPoint(x: arrowRightX, y: contentRect.minY))
        arrowPath.closePath()
        
        path.appendPath(arrowPath)
        return path
    }
}

class ThumbLayer: CALayer {
    var selected = false
}