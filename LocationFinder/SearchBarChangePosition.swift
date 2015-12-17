import Foundation
import UIKit

struct SearchBarPositionChangeNotification {
    struct KEY {
        static let NAME = "SEARCHBAR_POSITION_CHANGE_NOTIFICATION"
        static let DURATION = "ANIMATION_DURATION"
        static let TARGET_HEIGHT = "TARGET_SEARCHBAR_HEIGHT"
    }
    let targetSearchBarHeight: CGFloat
    let animationDuration: Double?
    
    var dictionary: [NSObject: AnyObject] {
        var d = [NSObject: AnyObject]()
        d[KEY.TARGET_HEIGHT] = targetSearchBarHeight
        if let duration = animationDuration {
            d[KEY.DURATION] = duration
        }
        
        return d
    }
    
    init?(notification: NSNotification) {
        guard let h = notification.userInfo?[KEY.TARGET_HEIGHT],
        let n = h as? NSNumber else { return nil }
        targetSearchBarHeight = CGFloat(n)
        
        let d = notification.userInfo?[KEY.DURATION] as? NSNumber
        animationDuration = d?.doubleValue
    }
    
    init(targetHeight: CGFloat, duration: Double?)
    {
        targetSearchBarHeight = targetHeight
        animationDuration = duration
    }
    
    func send() {
        NSNotificationCenter.defaultCenter().postNotificationName(KEY.NAME, object: nil, userInfo: dictionary)
    }
}
