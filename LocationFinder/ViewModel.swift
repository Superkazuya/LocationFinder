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
    let mapAnnotations = MutableProperty<[MapAnnotation]>([])
    
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
                    sink.sendFailed(NSError(domain: "Search", code: 420, userInfo: [NSLocalizedDescriptionKey: "Invalid search text"]))
                    return
                }
                req.naturalLanguageQuery = searchString
                guard let validSearchRegion = self.searchRegion.value else {
                    sink.sendFailed(NSError(domain: "Search", code: 322, userInfo: [NSLocalizedDescriptionKey: "Invalid search region"]))
                    return
                }
                req.region = validSearchRegion
                
                let search = MKLocalSearch(request: req)
                disposable.addDisposable { search.cancel() }
                search.startWithCompletionHandler{ response, error  in
                    if let e = error {
                        sink.sendFailed(e)
                        print(e)
                        return
                    }
                    
                    if let res = response {
                        sink.sendNext(LocalSearchResult(request: req, response: res))
                        sink.sendCompleted()
                        return
                    }
                    
                    sink.sendFailed(NSError(domain: "Search", code: 644, userInfo: [NSLocalizedDescriptionKey: "No response data"]))
                    //unkown error
                }
                
            }
        }
        
        errorMessage <~ SignalProducer<Signal<String?, NoError>, NoError> { sink, disposable in
            sink.sendNext(self.searchAction.errors.map{ $0.localizedDescription }.map(Optional.init))
            sink.sendNext(self.searchAction.values.filter{ !$0.hasValidResults }.map{_ in Optional("You search yielded no results")})
        }.flatten(.Merge)
        
        mapViewRegion <~ searchAction.values.filter{$0.hasValidResults}.map { res in Optional(res.boundingRegion) }
        mapAnnotations <~ searchAction.values.filter{$0.hasValidResults}
            .map { res in  res.locations.map{ MapAnnotation(mapItem: $0, currentLocaction: res.userLocationCoordinate)}.sort{a,b in a.distance < b.distance } }

    }
    
}


/*
func CustomErrorHandler(error: NSError) -> String
{
    if let errorMessage = error.userInfo[NSLocalizedDescriptionKey] as? String{
        return errorMessage
    }
    
    guard error.domain == "MKErrorDomain" else { return "Unknown Error" }
    
    switch error {
        case error.userInfo[MKErrorCode.PlacemarkNotFound]
    }
}
*/