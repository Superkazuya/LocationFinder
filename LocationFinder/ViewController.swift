import UIKit
import MapKit
import ReactiveCocoa

class ViewController: ViewControllerWithKBLayoutGuide, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!

    var topInfoBar = UIView()
    var topInfoBarText = UILabel()
    var tableView =  UITableView()
    var searchBar =  TintTextField()
    
    var tableViewHeight: NSLayoutConstraint!
    var action: CocoaAction!

    var viewModel = ViewModel()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(topInfoBar)
        topInfoBar.addSubview(topInfoBarText)
        setupTableViewConstraints()
        setupSearchBarConstraints()
        setupTopInfoBar()
        
        //mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //searchBar
        searchBar.alpha = 0
        searchBar.setupTintColor(CONSTANT.COLOR_SCHEME.SEARCHBAR.TINT)
        searchBar.attributedPlaceholder = CONSTANT.SEARCHBAR.PLACEHOLDER_ATTR_TEXT
        searchBar.backgroundColor = UIColor.blackColor()
        searchBar.textAlignment = .Center
        searchBar.keyboardType = .Default
        searchBar.clearButtonMode = .WhileEditing
        
        //location
        locationManager.requestWhenInUseAuthorization()
        //stub
        
        tableViewInit()
        bindViewModel()
    }


    func toggleSearchBarVisibility(animated: Bool)
    {
        let targetAlpha: CGFloat = searchBar.alpha < 0.001 ? 0.9 : 0

        UIView.animateWithDuration(animated ? 0 : 0.3) {[weak self] in self?.searchBar.alpha = targetAlpha }
    }
    
    func topInfoBarShowMessage(message: String, bgColor: UIColor)
    {
        topInfoBarText.text = message
        topInfoBar.backgroundColor = CONSTANT.COLOR_SCHEME.TOPINFOBAR.ERROR_BG
        
        UIView.animateWithDuration(0.5, delay: 0, options: .BeginFromCurrentState,
            animations: { self.topInfoBar.alpha = 0.9 }) {[weak self] _ in
            UIView.animateWithDuration(2, delay: 0.5, options: [], animations: { self?.topInfoBar.alpha = 0 }, completion: nil)
        }
    }
    
    func topInfoBarShowErrorMessage(errorString: String)
    {
        topInfoBarShowMessage(errorString, bgColor: CONSTANT.COLOR_SCHEME.TOPINFOBAR.ERROR_BG)
    }
    
    private func bindViewModel()
    {
        //binding, IN
        viewModel.userLocation <~ signalUserLocation()
            .map(Optional.init)
        
        signalUserLocation().startWithNext{_ in print("user location updated") }
        signalUserLocation()
            .take(1).startWithNext{[weak self] _ in self?.toggleSearchBarVisibility(true)
        }
        
        viewModel.searchText <~ searchBar.rac_text.producer.map(Optional.init)
        
        action = CocoaAction(viewModel.searchAction!) {[weak self] _ in self?.searchBar.text ?? "" }
        searchBar.addTarget(action, action: CocoaAction.selector, forControlEvents: .PrimaryActionTriggered)
        searchBar.tableViewToggleButton.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext{ [weak self] _ in
            self?.searchBar.tableViewToggleButton.toggle()
            self?.toggleTableViewVisibilityAnimated()
        }
        
        //dismiss kb after performing search
        //set visibility toggle button to down
        viewModel.searchAction.events.observe {[weak self] _ in
            self?.searchBar.resignFirstResponder()
            self?.searchBar.tableViewToggleButton.status = .Expanded
        }
        
        //Toggle buttion visibility
        let EditingSignal = SignalProducer<SignalProducer<Bool, NoError>, NoError> {[weak self] sink, disposable in
            sink.sendNext(self!.searchBar.rac_signalForControlEvents(.EditingDidBegin).toSignalProducer().ignoreError().map{_ in true})
            sink.sendNext(self!.searchBar.rac_signalForControlEvents(.EditingDidEnd).toSignalProducer().ignoreError().map{_ in false})
        }.flatten(.Merge)
        searchBar.tableViewToggleButton.rac_hidden <~ SignalProducer<Bool, NoError>(value: true).takeUntilReplacement(EditingSignal)
        
        //error message
        viewModel.errorMessage.producer.ignoreNil()
            .on(event: {print($0)})
        .startWithNext(topInfoBarShowErrorMessage)
        
        //map annotations
        mapView.rac_annotaions <~ viewModel.mapAnnotations.producer.map { $0 as [MKAnnotation] }
        //table view resize
        viewModel.mapAnnotations.producer.startWithNext {[weak self] datasource in
            self?.tableViewHeight.constant = 200
            self?.tableView.layoutIfNeeded()
            self?.tableView.reloadData()
            let h = self?.tableView.contentSize.height > 200 ? 200 : self?.tableView.contentSize.height
            //print(h)
            self?.tableViewHeight.constant = h ?? 0
        }
        
        //map region changes
        mapView.rac_regionAnimated <~ signalUserLocation()
            .map{MKCoordinateRegion(center: $0.coordinate, span: CONSTANT.MAP.DEFAULT_MARGIN)}
            .takeUntilReplacement(viewModel.mapViewRegion.producer.ignoreNil())
    }
    
    func toggleTableViewVisibilityAnimated()
    {
        let h = tableView.contentSize.height > 200 ? 200 : tableView.contentSize.height
        
        UIView.animateWithDuration(0.5) {[weak self] in
            self?.tableViewHeight.constant = self?.tableViewHeight.constant <= 0.01 ? h : 0
            self?.view.layoutIfNeeded()
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) { }
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) { }
    
    
    // MARK: UI Setups
    private func setupTopInfoBar()
    {
        topInfoBar.alpha = 0
        topInfoBar.translatesAutoresizingMaskIntoConstraints = false
        topInfoBar.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        topInfoBar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        topInfoBar.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        let textMargin: CGFloat = 8
        topInfoBarText.text = " "
        topInfoBarText.translatesAutoresizingMaskIntoConstraints = false
        topInfoBarText.topAnchor.constraintEqualToAnchor(topInfoBar.topAnchor, constant: textMargin).active = true
        topInfoBarText.bottomAnchor.constraintEqualToAnchor(topInfoBar.bottomAnchor, constant: -textMargin).active = true
        topInfoBarText.leadingAnchor.constraintGreaterThanOrEqualToAnchor(topInfoBar.leadingAnchor, constant: textMargin).active = true
        topInfoBarText.trailingAnchor.constraintLessThanOrEqualToAnchor(topInfoBar.trailingAnchor, constant: -textMargin).active = true
        topInfoBarText.centerXAnchor.constraintEqualToAnchor(topInfoBar.centerXAnchor).active = true
        topInfoBarText.textColor = UIColor.whiteColor()

    }
    
    private func setupTableViewConstraints()
    {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        
        tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        tableViewHeight = tableView.heightAnchor.constraintEqualToConstant(0)
        tableViewHeight.active = true
    }

    private func setupSearchBarConstraints()
    {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        searchBar.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        searchBar.bottomAnchor.constraintLessThanOrEqualToAnchor(kbLayoutGuide.topAnchor).active = true
        let c = searchBar.bottomAnchor.constraintEqualToAnchor(tableView.topAnchor)
        c.priority = 750
        c.active = true
        //shouldn't be blocked by the keyboard
        //above == negative value
    }
    

}
