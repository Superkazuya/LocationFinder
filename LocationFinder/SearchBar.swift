import Foundation
import UIKit


@IBDesignable class SearchBar : TintTextField {
    let tableViewToggleButton = ExpandButton(type: UIButtonType.Custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchBar(self)
        setupToggleButton(tableViewToggleButton)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSearchBar(self)
        setupToggleButton(tableViewToggleButton)
    }
    
    func setupSearchBar(searchBar: TintTextField)
    {
        searchBar.alpha = 1
        searchBar.setupTintColor(CONSTANT.COLOR_SCHEME.SEARCHBAR.TINT)
        searchBar.attributedPlaceholder = CONSTANT.SEARCHBAR.PLACEHOLDER_ATTR_TEXT
        searchBar.backgroundColor = UIColor.blackColor()
        searchBar.textAlignment = .Center
        searchBar.keyboardType = .Default
        searchBar.font = UIFont.systemFontOfSize(18)
        searchBar.clearButtonMode = .WhileEditing
    }
    
    private func setupToggleButton(button: ExpandButton)
    {
        addSubview(tableViewToggleButton)
        tableViewToggleButton.isArrowUpward = false
        tableViewToggleButton.translatesAutoresizingMaskIntoConstraints = false
        tableViewToggleButton.tintColor = tintColor
        tableViewToggleButton.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 8).active = true
        tableViewToggleButton.topAnchor.constraintGreaterThanOrEqualToAnchor(topAnchor, constant: 4).active = true
        tableViewToggleButton.heightAnchor.constraintEqualToAnchor(tableViewToggleButton.widthAnchor).active = true
        
        tableViewToggleButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    }
}