//
// Created by Weiyu Huang on 11/18/15.
// Copyright (c) 2015 SITA CORP. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    func distanceTo(another: CLLocationCoordinate2D) -> CLLocationDistance {
        
        let a = CLLocation(latitude: latitude, longitude: longitude)
        let b = CLLocation(latitude: another.latitude, longitude: another.longitude)
        
        return a.distanceFromLocation(b)
    }
}

extension MKCoordinateRegion {
    var topMost: CLLocationDegrees { return center.latitude + span.latitudeDelta }
    var botMost: CLLocationDegrees { return center.latitude - span.latitudeDelta }
    var leftMost: CLLocationDegrees { return center.longitude - span.longitudeDelta }
    var rightMost: CLLocationDegrees { return center.longitude + span.longitudeDelta }


    func contains(point: CLLocationCoordinate2D) -> Bool
    {
        guard case (botMost ... topMost) = point.latitude else { return false }
        guard case (leftMost ... rightMost) = point.longitude else { return false }

        return true
    }
}

struct LocalSearchResult {
    let request: MKLocalSearchRequest
    let response: MKLocalSearchResponse

    var userLocationCoordinate: CLLocationCoordinate2D   {
        return request.region.center
    }

    //nil indicates no location found within the target region
    var boundingRegion: MKCoordinateRegion!

    var locations: [MKMapItem] = []
    //all locations with in the boundingRegion
    
    var hasValidResults: Bool { return locations.count > 1 }

    init(request: MKLocalSearchRequest, response: MKLocalSearchResponse)
    {
        self.request = request
        self.response = response

        boundingRegion = getBoundingRegion()
        locations = response.mapItems.filter { boundingRegion.contains($0.placemark.coordinate) }
    }
    
    private func getBoundingRegion() -> MKCoordinateRegion
    //Or use request.region ???
    {
        let c = (self.response.mapItems.map { $0.placemark.coordinate } + [self.request.region.center])

        let coord = c.filter(self.request.region.contains)
        /*
        guard coord.count > 1 else {
            return nil
        }*/

        let lats = coord.map{ $0.latitude }
        let longs = coord.map{ $0.longitude }

        let center = CLLocationCoordinate2D(latitude: (lats.maxElement()! + lats.minElement()!)/2, longitude: (longs.maxElement()! + longs.minElement()!)/2)

        let latMarginDegree = CONSTANT.MAP.DEFAULT_MARGIN.latitudeDelta*2
        let longMarginDegree = CONSTANT.MAP.DEFAULT_MARGIN.longitudeDelta*2
        let span = MKCoordinateSpanMake(latMarginDegree + lats.maxElement()! - lats.minElement()!, longMarginDegree + longs.maxElement()! - longs.minElement()!)

        return MKCoordinateRegion(center: center, span: span)
    }
}

//has to be class. feels bad man
class MapAnnotation: NSObject, MKAnnotation{
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let distance: CLLocationDistance
    let mapItem: MKMapItem
    
    init(mapItem: MKMapItem, currentLocaction: CLLocationCoordinate2D) {
        self.mapItem = mapItem
        self.coordinate = mapItem.placemark.coordinate
        self.title = mapItem.name
        self.subtitle = mapItem.placemark.title
        self.distance = mapItem.placemark.coordinate.distanceTo(currentLocaction)
    }
}

func == (a: MapAnnotation, b: MapAnnotation)->Bool
{
    guard a.title == b.title else { return false }
    
    guard a.coordinate.distanceTo(b.coordinate) < 0.01 else {return false}
    
    return true
}
