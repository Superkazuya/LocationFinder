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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    //reloadData should block the datasource fetch?
    
    
    func tableViewInit()
    {
        //tableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: CONSTANT.TABLEVIEW.CELL_IDENTIFIER)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.mapAnnotations.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CONSTANT.TABLEVIEW.CELL_IDENTIFIER)
            ?? UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CONSTANT.TABLEVIEW.CELL_IDENTIFIER)
        
        let a = viewModel.mapAnnotations.value[indexPath.row]
        cell.textLabel?.text = a.title
        cell.detailTextLabel?.text = "\(Int(a.distance).description) meters"
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let a = viewModel.mapAnnotations.value[indexPath.row]
        a.mapItem.openInMapsWithLaunchOptions(nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let a = viewModel.mapAnnotations.value[indexPath.row]
        mapView.selectAnnotation(a, animated: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let a = viewModel.mapAnnotations.value[indexPath.row]
        mapView.deselectAnnotation(a, animated: true)
    }
    
}