//
//  StatusBar.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/18/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerWithDarkStatusBar: UIViewController{
    
    @IBOutlet weak var statusBarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarView.backgroundColor = CONSTANT.COLOR_SCHEME.TOPINFOBAR.ERROR_BG
    }
}