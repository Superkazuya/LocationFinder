import Foundation
import UIKit

class SearchBarTransitionSubVC: UIViewController, HasSearchBarLayoutGuide {
    
    var searchBarLayoutGuide: UILayoutGuide!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarLayoutGuide = UILayoutGuide()
        setupSearchBarLayoutGuide(searchBarLayoutGuide)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //needs further overriding
    //2 more constraints needed
    func setupSearchBarLayoutGuide(layoutGuide: UILayoutGuide)
    {
        view.addLayoutGuide(layoutGuide)
        layoutGuide.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        layoutGuide.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    }
    
    //modify this rather than overriding didMoveToParentViewController()
    func setupRelationForSearchBar(searchBar: SearchBar)
    {
        let c = searchBar.bottomAnchor.constraintEqualToAnchor(searchBarLayoutGuide.topAnchor)
        c.priority = 500
        c.active = true
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        
        guard let pvc = parent as? MainViewController else { return }
        
        setupRelationForSearchBar(pvc.searchBar)
        
        //search bar movement animated
        UIView.animateWithDuration(1, animations: {
            pvc.view.layoutIfNeeded()
            }, completion: {_ in })
    }
    
}