import Foundation
import ReactiveCocoa
import MapKit

struct MapViewModel {
    //input
    let userLocation = MutableProperty<MKUserLocation?>(nil)
    
    let mapViewRegion = MutableProperty<MKCoordinateRegion?>(nil)
    let mapAnnotations = MutableProperty<[MapAnnotation]>([])
}

struct SearchBarViewModel {
    //MARK: input
    let searchText = MutableProperty<String?>(nil)
    let searchTextIsEditing = MutableProperty(false)
    let expandArrowClicked = MutableProperty(Void)
    
    //MARK: output
    let isHintHidden = MutableProperty(true)
    let hintString = MutableProperty<[String]>([])
    
    let searchBarHeight = MutableProperty<CGFloat>(0)
    let isSearchBarHidden = MutableProperty(true)
}

struct ViewModel {
    //subViewModels
    let searchBarVM = SearchBarViewModel()
    let mapVM = MapViewModel()
    
    //nil indicates not available for now
    //MARK: Input
    let searchRadius = ConstantProperty(CONSTANT.MAP.DEFAULT_SEARCH_REGION)
    
    //Action
    var searchAction: Action<String, LocalSearchResult, NSError>!
    
    //MARK: Output
    let isExpandArrowUpwards = MutableProperty(false)
    let isExpandArrowHidden = MutableProperty(true)
    let errorMessage = MutableProperty<String?>(nil)
    let isTableViewHidden = MutableProperty(false)
    
    init() {
        
        let searchRegion = MutableProperty<MKCoordinateRegion?>(nil)
        let searchRegionSpan = MutableProperty(MKCoordinateSpanMake(0.05, 0.05))
        
        searchRegion <~ mapVM.userLocation.producer
            .ignoreNil()
            .combineLatestWith(searchRegionSpan.producer)
            .map {region in MKCoordinateRegion(center: region.0.coordinate, span: region.1) }
        
        searchRegionSpan <~ searchRadius.producer.map {MKCoordinateSpanMake($0, $0)}
        
        
        let searchActionEnableSignal =  MutableProperty<Bool>(false)
        
        searchActionEnableSignal <~ mapVM.userLocation.producer
            .ignoreNil().combineLatestWith(searchBarVM.searchText.producer.ignoreNil())
            .map { _ in true }
        
        searchAction = Action<String, LocalSearchResult, NSError>(enabledIf: searchActionEnableSignal){ searchString in
            SignalProducer<LocalSearchResult, NSError> { sink, disposable in
                let req = MKLocalSearchRequest()
                if searchString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
                    sink.sendFailed(NSError(domain: "Search", code: 420, userInfo: [NSLocalizedDescriptionKey: "Invalid search text"]))
                    return
                }
                req.naturalLanguageQuery = searchString
                guard let validSearchRegion = searchRegion.value else {
                    sink.sendFailed(NSError(domain: "Search", code: 322, userInfo: [NSLocalizedDescriptionKey: "Invalid search region"]))
                    return
                }
                req.region = validSearchRegion
                
                let search = MKLocalSearch(request: req)
                disposable.addDisposable { search.cancel() }
                
                //test test test
                let d = UIApplication.sharedApplication().delegate as! AppDelegate
                d.searchHistory.insert(req.naturalLanguageQuery!.characters)
                
                search.startWithCompletionHandler{ response, error  in
                    if let e = error {
                        sink.sendFailed(e)
                        //print(e)
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

        //map
        mapVM.mapViewRegion <~ searchAction.values.filter{$0.hasValidResults}.map { res in Optional(res.boundingRegion) }
        mapVM.mapAnnotations <~ searchAction.values.filter{$0.hasValidResults}
            .map { res in  res.locations.map{ MapAnnotation(mapItem: $0, currentLocaction: res.userLocationCoordinate)}.sort{a,b in a.distance < b.distance } }
        
        //searchBar
        searchBarVM.isHintHidden <~ searchBarVM.searchTextIsEditing.producer
            .combineLatestWith(searchBarVM.isSearchBarHidden.producer)
            .map {a, b in !a || b }
            .combineLatestWith(searchBarVM.searchText.producer.ignoreNil())
            .map{ a, b in a && b.strip() == ""}
            
        searchBarVM.hintString <~ searchBarVM.searchText.producer
                .ignoreNil()
                .combineLatestWith(searchBarVM.isHintHidden.producer)
            .filter{ $0.0.strip() != nil && !$0.1} .map { $0.0 }
            .map(Completion.getSearchHintForInput)
        
        searchBarVM.isSearchBarHidden <~ SignalProducer<Bool, NoError>(value: true)
            .takeUntilReplacement(mapVM.userLocation.producer
                .ignoreNil()
                .map{ _ in false }.skipRepeats())
        
        isExpandArrowHidden <~ mapVM.mapAnnotations.producer
            .map { $0.isEmpty }.combineLatestWith(searchBarVM.searchTextIsEditing.producer)
            .map{ $0.0 || $0.1 }
        
        isExpandArrowUpwards <~ SignalProducer<SignalProducer<Bool?, NoError>, NoError> {sink, disposable in
            sink.sendNext(self.mapVM.mapAnnotations.producer.map{ _ in false })
            sink.sendNext(self.searchBarVM.expandArrowClicked.producer.map{ _ in nil })
            }.flatten(.Merge).scan(false) {sum, i in
                i != nil ? i! : !sum }
        
        isTableViewHidden <~ isExpandArrowUpwards
        
        errorMessage <~ SignalProducer<Signal<String?, NoError>, NoError> { sink, disposable in
            sink.sendNext(self.searchAction.errors.map{ $0.localizedDescription }.map(Optional.init))
            sink.sendNext(self.searchAction.values.filter{ !$0.hasValidResults }.map{_ in Optional("Your search yielded no results")})
        }.flatten(.Merge)
    }
    
}