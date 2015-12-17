import UIKit
import MapKit
import ReactiveCocoa

class MapViewController: SearchBarTransitionSubVC, MKMapViewDelegate {
    let mapView = MKMapView()
    let tableView = TableViewWithIntrinsicSize()
    let topInfoBar = UIView()
    let topInfoBarText = UILabel()
    //let rangeSlider = UISlider()
    
    var viewModel: ViewModel!
    let locationManager = CLLocationManager()
    
    lazy var tableViewZeroHeightConstraint: NSLayoutConstraint = {
        return self.tableView.heightAnchor.constraintEqualToConstant(0)
    }()

    override func viewDidLoad() {
        
        view.addSubview(mapView)
        view.addSubview(tableView)
        view.addSubview(topInfoBar)
        topInfoBar.addSubview(topInfoBarText)
        //view.addSubview(rangeSlider)
        //setupRangeSlider(rangeSlider)
        
        super.viewDidLoad()

        
        //location auth stub
        locationManager.requestWhenInUseAuthorization()
        
        setupTopInfoBar()
        setupMapView()
        tableViewInit()
        bindViewModel()
    }
    
    override func setupSearchBarLayoutGuide(layoutGuide: UILayoutGuide) {
        super.setupSearchBarLayoutGuide(layoutGuide)
        layoutGuide.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        layoutGuide.topAnchor.constraintEqualToAnchor(tableView.topAnchor).active = true
        //and use default relationship between the layout and the search bar
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
        viewModel.mapVM.userLocation <~ signalUserLocation().map(Optional.init)
        
        //OUT
        //error message
        viewModel.errorMessage.producer
            .ignoreNil()
        .startWithNext(topInfoBarShowErrorMessage)
        
        //map annotations
        mapView.rac_annotaions <~ viewModel.mapVM.mapAnnotations.producer.map { $0 as [MKAnnotation] }
        
        //table view resize
        viewModel.mapVM.mapAnnotations.producer.startWithNext {[weak self] _ in
            self?.tableView.reloadData()
        }
        
        //map region changes
        //WTF
        //mapView.rac_regionAnimated <~ signalUserLocation() .map{MKCoordinateRegion(center: $0.coordinate, span: CONSTANT.MAP.DEFAULT_MARGIN)} .takeUntilReplacement(viewModel.mapVM.mapViewRegion.producer.ignoreNil())
        signalUserLocation() .map{MKCoordinateRegion(center: $0.coordinate, span: CONSTANT.MAP.DEFAULT_MARGIN)}.takeUntilReplacement(viewModel.mapVM.mapViewRegion.producer.ignoreNil()).startWithNext{[weak self] i in self?.mapView.setRegion(i, animated: true)}
        
        viewModel.isTableViewHidden.producer.startWithNext(setTableViewVisibilityAnimated)
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
    
    /*
    private func setupRangeSlider(rangeSlider: UISlider)
    {
        rangeSlider.translatesAutoresizingMaskIntoConstraints = false
        rangeSlider.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 8).active = true
        rangeSlider.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -8).active = true
        rangeSlider.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 8).active = true
        
        //rangeSlider.setThumbImage(UIImage.imageFromColorAndSize(UIColor.blackColor(), size: CGSize(width: 50, height: 20)), forState: .Normal)
        
        rangeSlider.tintColor = CONSTANT.COLOR_SCHEME.SLIDER.TINT
        rangeSlider.thumbTintColor = CONSTANT.COLOR_SCHEME.SLIDER.TINT
        
        rangeSlider.minimumValue = Float(Meters2DegreeAprox(100))
        rangeSlider.maximumValue = Float(Meters2DegreeAprox(10000))
        rangeSlider.value = Float(Degree2MetersAprox(CONSTANT.MAP.DEFAULT_MARGIN.latitudeDelta))
    }*/
    
    private func setupMapView()
    {
        //mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        mapView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        mapView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        mapView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    }

}
