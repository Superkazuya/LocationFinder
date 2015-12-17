//
//  UICustomSlider.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/24/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import UIKit

class UICustomSlider: UISlider {

    var valueView: SliderValueView!
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    //let thumbLayoutGuide = UILayoutGuide()
    var trackRect : CGRect {
        return trackRectForBounds(bounds)
    }
    var thumbRect : CGRect {
        return thumbRectForBounds(bounds, trackRect: trackRect, value: value)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let f = CGRect(origin: CGPoint(x: thumbRect.minX, y: thumbRect.maxY + 8), size: thumbRect.size)
        valueView = SliderValueView(frame: f)
        //setupThumbLayout(thumbLayoutGuide)
        addSubview(valueView)
        updateValueView(valueView)
    }
    
    func updateValueView(valueView: SliderValueView)
    {
        var f = thumbRect
        f.origin.y = thumbRect.maxY + 2
        valueView.frame = f
        
        valueView.textLabel.text =  UInt(Degree2MetersAprox(Double(value))).description
        //layoutIfNeeded()
    }
    
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let r = super.beginTrackingWithTouch(touch, withEvent: event)
        
        updateValueView(valueView)
        
        return r
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let r = super.continueTrackingWithTouch(touch, withEvent: event)
        
        updateValueView(valueView)
        return r
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        updateValueView(valueView)
    }

}


class SliderValueView: UIView {
    private let shape = CAShapeLayer()
    
    var contentFrame: CGRect {
        var b = bounds
        b.origin.y += CONSTANT.SLIDER.TIP_ARROW_HEIGHT
        b.size.height -= CONSTANT.SLIDER.TIP_ARROW_HEIGHT
        return b
    }
    
    let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.blackColor()
        addSubview(textLabel)
        setupTextLabel(textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateOuterBounds()
    }
    
    //MARK: text label
    func setupTextLabel(textLabel: UILabel)
    {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFontOfSize(11)
        textLabel.textColor = UIColor.whiteColor()
        let margin = CONSTANT.SLIDER.TEXT_MARGIN
        textLabel.text = ""
        textLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: margin).active = true
        textLabel.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -margin).active = true
        textLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -margin).active = true
        
        textLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: margin + CONSTANT.SLIDER.TIP_ARROW_HEIGHT).active = true
    }
    
    func updateOuterBounds()
    {
        shape.path = outerBounds(bounds).CGPath
        layer.mask = shape
    }
    
    func outerBounds(bounds: CGRect) -> UIBezierPath
    {
        let cornerRadius = CONSTANT.SLIDER.CORNER_RADIUS
        guard bounds.width-2*cornerRadius > 0 else { return UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)}
        
        let path = UIBezierPath(roundedRect: contentFrame, cornerRadius: CONSTANT.SLIDER.CORNER_RADIUS)
        
        let rectBounds = contentFrame
        let arrowHalfWidth = CONSTANT.SLIDER.TIP_ARROW_HALF_WIDTH
        
        let arrowLeftX = max(rectBounds.minX+cornerRadius, rectBounds.midX-arrowHalfWidth)
        let arrowRightX = rectBounds.midX*2 - arrowLeftX
        
        let arrowPath = UIBezierPath()
        arrowPath.moveToPoint(CGPoint(x: rectBounds.midX, y: bounds.minY))
        arrowPath.addLineToPoint(CGPoint(x: arrowLeftX, y: rectBounds.minY))
        arrowPath.addLineToPoint(CGPoint(x: arrowRightX, y: rectBounds.minY))
        arrowPath.closePath()
        
        path.appendPath(arrowPath)
        //CONSTANT.COLOR_SCHEME.TINT.setFill()
        return path
    }
    

}