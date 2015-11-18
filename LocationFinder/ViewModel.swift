import Foundation
import ReactiveCocoa
import MapKit

struct ViewModel {
    //nil indicates not available for now
    
    //MARK: Input
    let userLocation = MutableProperty<MKUserLocation?>(nil)
    let searchText = MutableProperty<String?>(nil)
    
    let searchRegionSpan = ConstantProperty(MKCoordinateSpanMake(0.05, 0.05))
    //using a stepper/slider is possible
    
    let searchRegion = MutableProperty<MKCoordinateRegion?>(nil)
    //stub
    
    //Action
    let searchActionEnableSignal =  MutableProperty<Bool>(false)
    
    var searchAction: Action<String, LocalSearchResult, NSError>!
    
    //MARK: Output
    let errorMessage = MutableProperty<String?>(nil)
    let mapViewRegion = MutableProperty<MKCoordinateRegion?>(nil)
    let mapItems = MutableProperty<[MKMapItem]>([])
    
    
    init() {
        searchRegion <~ userLocation.producer
            .ignoreNil()
            .combineLatestWith(searchRegionSpan.producer)
            .map {region in MKCoordinateRegion(center: region.0.coordinate, span: region.1) }
        
        searchActionEnableSignal <~ userLocation.producer.ignoreNil().combineLatestWith(searchText.producer.ignoreNil()).map { _ in true }
        
        searchAction = Action<String, LocalSearchResult, NSError>(enabledIf: searchActionEnableSignal){ searchString in
            SignalProducer<LocalSearchResult, NSError> { sink, disposable in
                let req = MKLocalSearchRequest()
                if searchString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
                    sink.sendError(NSError(domain: "Search", code: 420, userInfo: [NSLocalizedDescriptionKey: "Invalid search text"]))
                    return
                }
                req.naturalLanguageQuery = searchString
                guard let validSearchRegion = self.searchRegion.value else {
                    sink.sendError(NSError(domain: "Search", code: 322, userInfo: [NSLocalizedDescriptionKey: "Invalid search region"]))
                    return
                }
                req.region = validSearchRegion
                
                let search = MKLocalSearch(request: req)
                disposable.addDisposable { search.cancel() }
                search.startWithCompletionHandler{ response, error  in
                    if let e = error {
                        sink.sendError(e)
                        return
                    }
                    
                    if let res = response {
                        sink.sendNext(LocalSearchResult(request: req, response: res))
                        sink.sendCompleted()
                        return
                    }
                    
                    sink.sendError(NSError(domain: "Search", code: 644, userInfo: [NSLocalizedDescriptionKey: "Unknown Error While Searching"]))
                    //unkown error
                }
                
            }
        }
        
        errorMessage <~ searchAction.errors.map{ $0.userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown Error" }
        .map(Optional.init)
        
        mapViewRegion <~ searchAction.values.map { res in Optional(res.boundingRegion) }
        mapItems <~ searchAction.values.map { res in res.locations }

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
        
        let marginDegree: CLLocationDegrees = 0.01
        let span = MKCoordinateSpanMake(marginDegree*2 + lats.maxElement()! - lats.minElement()!, marginDegree*2 + longs.maxElement()! - longs.minElement()!)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
}