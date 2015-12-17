//
//  MainViewController.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 12/16/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MainViewController: ViewControllerWithSubVCs {
    
    let viewModel = ViewModel()
    private var action: CocoaAction!
    
    override func viewDidLoad() {
        mapViewController.viewModel = viewModel
        super.viewDidLoad()

        bindVM()
        bindVMOutput()
    }
    
   private func bindVM()
    {
        viewModel.searchBarVM.searchText <~ searchBar.rac_text.producer.map(Optional.init)
        viewModel.searchBarVM.searchTextIsEditing <~ SignalProducer<SignalProducer<Bool, NoError>, NoError>
            {[weak self] sink, disposable in
            sink.sendNext(self!.searchBar.rac_signalForControlEvents(.EditingDidBegin).toSignalProducer()
                .ignoreError().map{_ in true})
            sink.sendNext(self!.searchBar.rac_signalForControlEvents(.EditingDidEnd).toSignalProducer()
                .ignoreError().map{_ in false})
        }.flatten(.Merge)
            
        viewModel.searchBarVM.expandArrowClicked <~ searchBar.tableViewToggleButton
            .rac_signalForControlEvents(.TouchUpInside) .toSignalProducer()
            .ignoreError()
            .map{ _ in Void.self }
        
       //action binding
        action = CocoaAction(viewModel.searchAction) {[weak self] _ in self?.searchBar.text ?? "" }
        searchBar.addTarget(action, action: CocoaAction.selector, forControlEvents: .PrimaryActionTriggered)
    }
    
    private func bindVMOutput()
    {
        viewModel.isExpandArrowUpwards.producer
            .skipRepeats()
            .startWithNext{ [weak self] in
            self?.searchBar.tableViewToggleButton.isArrowUpward = $0 }
        
        viewModel.searchBarVM.isSearchBarHidden.producer
            .skipRepeats()
            .startWithNext(setSearchBarVisibilityAnimated)
        
        viewModel.searchAction
            .values.observe{[weak self] _ in
                self?.searchBar.resignFirstResponder() }
        
        searchBar.tableViewToggleButton.rac_hidden <~ viewModel.isExpandArrowHidden
    }
}