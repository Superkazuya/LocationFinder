//
//  MapViewDelegate.swift
//  LocationFinder
//
//  Created by Weiyu Huang on 11/18/15.
//  Copyright © 2015 SITA CORP. All rights reserved.
//

import Foundation
import MapKit

extension ViewController {
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let pin = mapView.dequeueReusableAnnotationViewWithIdentifier(CONSTANT.MAP.ANNOTATION_IDENTIFIER) ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: CONSTANT.MAP.ANNOTATION_IDENTIFIER)
        
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let v = view.annotation as? MKPlacemark else { return }
            let mapItem = MKMapItem(placemark: v)
            mapItem.openInMapsWithLaunchOptions(nil)
    }
}