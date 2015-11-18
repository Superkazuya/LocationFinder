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
