import Foundation
import UIKit

protocol ViewModelOwner: class{
    var viewModel: ViewModel! {get set}
}

class ViewControllerWithDarkStatusBar: ViewControllerWithKBLayoutGuide, HasSearchBarLayoutGuide {
    @IBOutlet weak var searchBar: SearchBar!
    var searchBarLayoutGuide: UILayoutGuide!
    
    @IBOutlet weak var statusBarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarView.backgroundColor = CONSTANT.COLOR_SCHEME.TOPINFOBAR.ERROR_BG
        searchBar.bottomAnchor.constraintLessThanOrEqualToAnchor(kbLayoutGuide.topAnchor).active = true
    }
    
    
    func setSearchBarVisibilityAnimated(isHidden: Bool)
    {
        let targetAlpha: CGFloat = isHidden ? 0 : 0.9

        UIView.animateWithDuration(0.3) {[weak self] in self?.searchBar.alpha = targetAlpha }
    }

}
