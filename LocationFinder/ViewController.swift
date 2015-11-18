import UIKit
import MapKit
import ReactiveCocoa

class ViewController: ViewControllerWithKBLayoutGuide, MKMapViewDelegate{
    @IBOutlet weak var mapView: MKMapView!

    var topInfoBar = UIView()
    var topInfoBarText = UILabel()
    var tableView =  UITableView()
    var searchBar =  TintTextField()
    
    var tablewViewHeight: NSLayoutConstraint!
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
        searchBar.attributedPlaceholder = NSAttributedString(string: CONSTANT.SEARCHBAR.PLACEHOLDER_TEXT, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        searchBar.backgroundColor = UIColor.blackColor()
        //searchBar.textColor = UIColor.whiteColor()
        searchBar.textAlignment = .Center
        searchBar.keyboardType = UIKeyboardType.Default
        searchBar.clearButtonMode = .WhileEditing
        
        //location
        locationManager.requestWhenInUseAuthorization()
        //stub
        
        bindViewModel()
    }


    func toggleSearchBarVisibility(animated: Bool)
    {
        let targetAlpha: CGFloat = searchBar.alpha < 0.001 ? 0.9 : 0

        UIView.animateWithDuration(animated ? 0 : 0.3) {
            self.searchBar.alpha = targetAlpha
        }
    }
    
    func topInfoBarShowMessage(message: String, bgColor: UIColor)
    {
        topInfoBarText.text = message
        topInfoBar.backgroundColor = CONSTANT.COLOR_SCHEME.TOPINFOBAR.ERROR_BG
        
        UIView.animateWithDuration(0.5, delay: 0, options: .BeginFromCurrentState,
            animations: { self.topInfoBar.alpha = 0.9 }) { _ in
            UIView.animateWithDuration(2, delay: 0.5, options: [], animations: { self.topInfoBar.alpha = 0 }, completion: nil)
        }
    }
    
    func topInfoBarShowErrorMessage(errorString: String)
    {
        topInfoBarShowMessage(errorString, bgColor: CONSTANT.COLOR_SCHEME.TOPINFOBAR.ERROR_BG)
    }
    
    private func bindViewModel()
    {
        viewModel.userLocation <~ signalUserLocation()
            .map(Optional.init)
        
        signalUserLocation()
            .take(1).startWithNext{[weak self] _ in self?.toggleSearchBarVisibility(true) }
        
        viewModel.searchText <~ searchBar.rac_text.producer.map(Optional.init)
        
        action = CocoaAction(viewModel.searchAction!) {[weak self] _ in self?.searchBar.text ?? "" }
        searchBar.addTarget(action, action: CocoaAction.selector, forControlEvents: .PrimaryActionTriggered)
        
        
        viewModel.searchAction.events.observe {_ in self.searchBar.resignFirstResponder()}
        //out
        viewModel.errorMessage.producer.ignoreNil()
            .on(event: {print($0)})
        .startWithNext(topInfoBarShowErrorMessage)
        
        mapView.rac_annotaions <~ viewModel.mapItems.producer.map{i in i.map {$0.placemark}}
        
        mapView.rac_regionAnimated <~ signalUserLocation()
            .map{MKCoordinateRegion(center: $0.coordinate, span: CONSTANT.MAP.DEFAULT_MARGIN)}
            .takeUntilReplacement(viewModel.mapViewRegion.producer.ignoreNil())
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) { }
    
    
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
        tablewViewHeight = tableView.heightAnchor.constraintEqualToConstant(0)
        tablewViewHeight.active = true
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
