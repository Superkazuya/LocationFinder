
import Foundation
import UIKit

class ViewControllerWithDarkStatusBar: UIViewController{
    
    @IBOutlet weak var statusBarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarView.backgroundColor = CONSTANT.COLOR_SCHEME.TOPINFOBAR.ERROR_BG
    }
}