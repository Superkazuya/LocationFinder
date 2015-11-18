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
    private weak var top: NSLayoutConstraint!
    private weak var height: NSLayoutConstraint!
    
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
        top = kbLayoutGuide.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: view.frame.height)
        height = kbLayoutGuide.heightAnchor.constraintEqualToConstant(0)
        top.active = true
        height.active = true
    }
    
    func keyboardFrameWillChange(notification: NSNotification)
    {
        let userInfo = notification.userInfo!
        //let beginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let options = UIViewAnimationOptions(rawValue: UInt(animationCurve << 16))
        UIView.animateWithDuration(animationDuration, delay: 0, options: options, animations:
            {[weak self] in
                self?.top.constant = endFrame.origin.y
                self?.height.constant = endFrame.height
                self?.view.layoutIfNeeded()
            }, completion: nil)
    }
}
