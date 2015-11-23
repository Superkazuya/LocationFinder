import UIKit

class TintTextField: UITextField {


    let tableViewToggleButton = ExpandButton(type: UIButtonType.Custom)
    var tintedClearImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    func setupTintColor(tintColor: UIColor) {
        clearButtonMode = UITextFieldViewMode.WhileEditing
        borderStyle = UITextBorderStyle.RoundedRect
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        layer.borderColor = tintColor.CGColor
        layer.borderWidth = 1.5
        backgroundColor = UIColor.clearColor()
        self.tintColor = tintColor
        textColor = tintColor
        
        addSubview(tableViewToggleButton)
        tableViewToggleButton.status = .Expanded
        tableViewToggleButton.translatesAutoresizingMaskIntoConstraints = false
        tableViewToggleButton.tintColor = tintColor
        tableViewToggleButton.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 8).active = true
        tableViewToggleButton.topAnchor.constraintGreaterThanOrEqualToAnchor(topAnchor, constant: 4).active = true
        tableViewToggleButton.heightAnchor.constraintEqualToAnchor(tableViewToggleButton.widthAnchor).active = true
        
        tableViewToggleButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    
    private func tintClearImage()
    {
        subviews.forEach { view in
            guard view.dynamicType == UIButton.self else { return }
            let button = view as! UIButton
            if let img = button.imageForState(.Highlighted) {
                if tintedClearImage == nil { tintedClearImage = tintCImage(img, color: tintColor) }
                button.setImage(tintedClearImage, forState: .Normal)
                button.setImage(tintedClearImage, forState: .Highlighted)
                
            }
        }
    }
    
    func tintCImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.drawAtPoint(CGPointZero, blendMode: CGBlendMode.Normal, alpha: 1.0)
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, .SourceIn)
        CGContextSetAlpha(context, 1.0)
        
        let rect = CGRectMake(
            CGPointZero.x,
            CGPointZero.y,
            image.size.width,
            image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
    
}
