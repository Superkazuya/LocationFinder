//
//  GoodViewController.swift
//  SwiftPort
//
//  Created by Weiyu Huang on 11/15/15.
//  Copyright © 2015 Kappa. All rights reserved.
//

import UIKit

class ViewControllerWithKBLayoutGuide: UIViewController {
    @IBInspectable var kbLayoutGuide = UILayoutGuide()
    private weak var kbTop: NSLayoutConstraint!
    private weak var kbHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addLayoutGuide(kbLayoutGuide)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameWillChange:", name: UIKeyboardWillChangeFrameNotification , object: view.window)
        setupLayoutConstraints()
    }
    
    private func setupLayoutConstraints()
    {
        kbLayoutGuide.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        kbLayoutGuide.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        kbTop = kbLayoutGuide.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: view.frame.height)
        kbHeight = kbLayoutGuide.heightAnchor.constraintEqualToConstant(0)
        kbTop.active = true
        kbHeight.active = true
    }
    
    func keyboardFrameWillChange(notification: NSNotification)
    {
        let userInfo = notification.userInfo!
        //let beginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let end = self.view.convertRect(endFrame, fromCoordinateSpace: self.view.window!)
        
        let options = UIViewAnimationOptions(rawValue: UInt(animationCurve << 16))
        UIView.animateWithDuration(animationDuration, delay: 0, options: options, animations:
            {[weak self] in
                self?.kbTop.constant = end.origin.y
                self?.kbHeight.constant = end.height
                self?.view.layoutIfNeeded()
            }, completion: nil)
    }
}

//protocol version
protocol HasKBLayoutGuide: class {
    var view: UIView! { get set }
    weak var kbTop: NSLayoutConstraint! {get set}
    weak var kbHeight: NSLayoutConstraint! {get set }
    
    var kbLayoutGuide: UILayoutGuide { get set }
    func setupKBLayoutGuide()
}

extension HasKBLayoutGuide {
    func setupKBLayoutGuide()
    {
        view.addLayoutGuide(kbLayoutGuide)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameWillChange:", name: UIKeyboardWillChangeFrameNotification , object: view.window)
        setupLayoutConstraints()   
    }
    
    private func setupLayoutConstraints()
    {
        kbLayoutGuide.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        kbLayoutGuide.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        kbTop = kbLayoutGuide.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: view.frame.height)
        kbHeight = kbLayoutGuide.heightAnchor.constraintEqualToConstant(0)
        kbTop.active = true
        kbHeight.active = true
    }
    
    func keyboardFrameWillChange(notification: NSNotification)
    {
        let userInfo = notification.userInfo!
        //let beginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let end = self.view.convertRect(endFrame, fromCoordinateSpace: self.view.window!)
        
        let options = UIViewAnimationOptions(rawValue: UInt(animationCurve << 16))
        UIView.animateWithDuration(animationDuration, delay: 0, options: options, animations:
            {[weak self] in
                self?.kbTop.constant = end.origin.y
                self?.kbHeight.constant = end.height
                self?.view.layoutIfNeeded()
            }, completion: nil)
    }   
}