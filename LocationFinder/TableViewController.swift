//
//  tableViewController.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/18/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    //FIXME: reloadData should block the datasource fetch
    
    //FIXME: what if MAX_HEIGHT > max screen height
    func setTableViewVisibilityAnimated(hidden: Bool)
    {
        UIView.animateWithDuration(0.5) {[weak self] in
            self?.tableViewZeroHeightConstraint.active = hidden
            self?.view.layoutIfNeeded()
            self?.parentViewController?.view.layoutIfNeeded()
        }
    }
    
    func tableViewInit()
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        setupTableViewConstraints()
    }
    
    private func setupTableViewConstraints()
    {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.mapVM.mapAnnotations.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CONSTANT.TABLEVIEW.CELL_IDENTIFIER)
            ?? UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CONSTANT.TABLEVIEW.CELL_IDENTIFIER)
        
        let a = viewModel.mapVM.mapAnnotations.value[indexPath.row]
        cell.textLabel?.text = a.title
        cell.detailTextLabel?.text = "\(Int(a.distance).description) meters away"
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let a = viewModel.mapVM.mapAnnotations.value[indexPath.row]
        a.mapItem.openInMapsWithLaunchOptions(nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let a = viewModel.mapVM.mapAnnotations.value[indexPath.row]
        mapView.selectAnnotation(a, animated: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let a = viewModel.mapVM.mapAnnotations.value[indexPath.row]
        mapView.deselectAnnotation(a, animated: true)
    }
    
}