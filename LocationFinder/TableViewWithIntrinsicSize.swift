import UIKit

class TableViewWithIntrinsicSize: UITableView {
    override func reloadData() {
        invalidateIntrinsicContentSize()
        super.reloadData()
    }
    
    override func intrinsicContentSize() -> CGSize {
        layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: min(contentSize.height, CONSTANT.TABLEVIEW.DEFAULT_HEIGHT))
    }
}
