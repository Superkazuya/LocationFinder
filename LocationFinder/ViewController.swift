import UIKit
import MapKit
import ReactiveCocoa

class ViewController: ViewControllerWithKBLayoutGuide, MKMapViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var mapView: MKMapView!

    var topInfoBar = UIView()
    var topInfoBarText = UILabel()
    var tableView =  UITableView()
    var searchBar =  UISearchBar()
    
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
        
        searchBar.delegate = self
        searchBar.placeholder = "Enter a place here, e.g. Cafe"
        searchBar.keyboardType = UIKeyboardType.Default
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
    
    func topInfoBarShowErrorMessage(errorString: String)
    {
        topInfoBarText.text = errorString
        print(topInfoBar.frame)
        UIView.animateWithDuration(0.5, delay: 0, options: .BeginFromCurrentState,
            animations: { self.topInfoBar.alpha = 0.9 }) { _ in
            UIView.animateWithDuration(2, delay: 0.5, options: [], animations: { self.topInfoBar.alpha = 0 }, completion: nil)
        }
    }

    
    

    private func bindViewModel()
    {
        viewModel.userLocation <~ rac_signalForUserLocation()
            .map(Optional.init)
        
        viewModel.userLocation.producer
            .ignoreNil().startWithNext{b in
            let alpha:CGFloat = true ? 1:0
            UIView.animateWithDuration(0.3, delay: 0, options: .BeginFromCurrentState, animations: {[weak self] in self?.searchBar.alpha = alpha}, completion: nil)
        }
        
        viewModel.searchText <~ searchBar.rac_signalForSearchBarText().map(Optional.init)
        
        //action = CocoaAction(viewModel.searchAction!) {[weak self] _ in self?.searchBar.text ?? "" }
        searchBar.rac_bindAction(viewModel.searchAction) {[weak self] _ in self?.searchBar.text ?? "" }
        
        
        //out
        viewModel.errorMessage.producer.ignoreNil()
            .on(event: {print($0)})
        .startWithNext(topInfoBarShowErrorMessage)
        
        mapView.rac_annotaions <~ viewModel.mapItems.producer.map{i in i.map {$0.placemark}}
        mapView.rac_regionAnimated <~ rac_signalForUserLocation().map{MKCoordinateRegion(center: $0.coordinate, span: self.viewModel.searchRegionSpan.value)}.takeUntilReplacement(viewModel.mapViewRegion.producer.ignoreNil())
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) { }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) { }
    
    
    
    
    // MARK: UI Setups
    private func setupTopInfoBar()
    {
        topInfoBar.translatesAutoresizingMaskIntoConstraints = false
        topInfoBar.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        topInfoBar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        topInfoBar.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        //topInfoBar.heightAnchor.constraintEqualToConstant(44)
        
        topInfoBar.backgroundColor = UIColor.blackColor()
        topInfoBar.alpha = 0
        
        let textMargin: CGFloat = 8
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
