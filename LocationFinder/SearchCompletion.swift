import Foundation
import UIKit

struct Completion {
    static func getSearchHintForInput(input: String) -> [String]
    {
        let d = UIApplication.sharedApplication().delegate as! AppDelegate
        return d.searchHistory.completion(input.characters)
            .map(String.init)
            .map{ input + $0 }
    }
}
