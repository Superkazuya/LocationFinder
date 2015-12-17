//
//  MainViewController.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 12/16/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerWithSubVCs: ViewControllerWithDarkStatusBar {
    let mapViewController = MapViewController()
    let searchViewController = UIViewController() //Stub!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubVCs()
        
        searchBar.bottomAnchor.constraintLessThanOrEqualToAnchor(kbLayoutGuide.topAnchor).active = true
        //resolve kb & search bar conflicts here rather than in subVCs
    }
    
    private func setupSubVCs()
    {
        addChildViewController(mapViewController)
        installSubVC(mapViewController)
    }
    
    func installSubVC(subVC: SearchBarTransitionSubVC)
    {
        contentView.addSubview(subVC.view)
        subVC.setupRelationForSearchBar(searchBar)
        contentView.topAnchor.constraintEqualToAnchor(subVC.view.topAnchor).active = true
        contentView.bottomAnchor.constraintEqualToAnchor(subVC.view.bottomAnchor).active = true
        contentView.leadingAnchor.constraintEqualToAnchor(subVC.view.leadingAnchor).active = true
        contentView.trailingAnchor.constraintEqualToAnchor(subVC.view.trailingAnchor).active = true
    }
    
    private func transitionFromSubVC(fromVC: SearchBarTransitionSubVC, toVC: SearchBarTransitionSubVC)
    {
        addChildViewController(toVC)
        fromVC.willMoveToParentViewController(nil)
        
        transitionFromViewController(fromVC,
            toViewController: toVC,
            duration: 0,
            options: [],
            animations: {[weak self] in
                self?.installSubVC(toVC)
            }) { _ in
                fromVC.removeFromParentViewController()
                toVC.didMoveToParentViewController(self)
        }
    }
    
    
}